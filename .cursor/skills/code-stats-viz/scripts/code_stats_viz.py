#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Code Statistics Visualization Script
生成交互式代码统计 HTML 仪表板。

脚本分析范围说明
----------------
• 分析了哪些后缀：
  所有被统计到的文件都会按后缀归类；file_extensions 中有的显示为语言名（如 .py→Python），
  没有的显示为 "Other (.后缀)"。行数只对已知文本类后缀进行读取统计。
  不参与统计的后缀见 SKIP_EXTENSIONS：engine/onnx/pt、图片视频音频、二进制与压缩包等。

• 分析了哪些目录：
  - git_only 时：git ls-files 列出的、路径中不包含「排除目录」且不在「子模块」下的文件所在目录。
  - 非 git_only 时：全目录 rglob，再排除子模块与排除目录下的文件所在目录。

• 排除了哪些目录：
  - 默认排除：DEFAULT_EXCLUDE_DIRS（.git, .cursor, 3rdparty, __pycache__, node_modules, venv 等）。
  - 始终排除：所有 git 子模块路径（如 3rdparty/Eigen）。
  - 可通过 --exclude-dir 追加，或 --no-default-excludes 仅用 --exclude-dir。

• 是否分析所有分支：
  否。文件列表来自当前 HEAD（git ls-files），提交统计默认仅当前分支。加 --all-branches 后提交统计含所有分支。

• 是否分析所有历史：
  默认仅最近 365 天的提交。加 --days 0 或 --all-history 可统计全部历史提交。

• 提交日历：
  使用 ECharts 日历热力图，范围为有提交数据的日期区间，不再截断条数。

• 目录过滤（已修复）：
  勾选「全部目录」时不再误过滤：此前用路径首段（如 sdk）与完整父路径比对，导致 sdk/ 下 C++ 等全部被隐藏。
  现按顶层目录（sdk、docs、assets…）勾选过滤；饼图/柱状图/表格按代码行数从高到低排序。

Usage:
    python code_stats_viz.py [--dir /path/to/project] [--output my.html]
    # 未指定 --output 时默认为「分析目录文件夹名」_code_stats.html（例: proj → proj_code_stats.html；分析 . 则为当前仓库文件夹名_code_stats.html）
    python code_stats_viz.py --no-default-excludes   # 仅排除 --exclude-dir
    python code_stats_viz.py --no-git-only          # 全目录扫描（含未跟踪）
    python code_stats_viz.py --all-branches --days 0  # 所有分支、全部历史提交
    python code_stats_viz.py --subdir sdk              # 只统计 sdk/ 下代码与对应提交日历
"""

import argparse
import subprocess
import json
import webbrowser
from pathlib import Path
from collections import defaultdict
from datetime import datetime, timedelta
import os
import sys

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>代码统计仪表板 - {project_name}</title>
    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #f5f7fa;
            padding: 20px;
            color: #2c3e50;
        }}
        
        .dashboard {{
            max-width: 1600px;
            margin: 0 auto;
        }}
        
        /* 头部样式 */
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        }}
        
        .header h1 {{
            font-size: 2.2em;
            margin-bottom: 10px;
        }}
        
        .header p {{
            opacity: 0.9;
            font-size: 1.1em;
        }}
        
        /* 统计卡片 */
        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }}
        
        .stat-card {{
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
            text-align: center;
        }}
        
        .stat-card:hover {{
            transform: translateY(-5px);
        }}
        
        .stat-card .stat-value {{
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }}
        
        .stat-card .stat-label {{
            color: #7f8c8d;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }}
        
        /* 过滤面板 */
        .filter-panel {{
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 25px;
            overflow: hidden;
        }}
        
        .filter-header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 20px;
            cursor: pointer;
            font-weight: bold;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}
        
        .filter-header .badge {{
            background: rgba(255,255,255,0.2);
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.9em;
        }}
        
        .filter-body {{
            padding: 20px;
            display: none;
        }}
        
        .filter-body.show {{
            display: block;
        }}
        
        .filter-sections {{
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }}
        
        .filter-section {{
            border-right: 1px solid #eee;
            padding-right: 20px;
        }}
        
        .filter-section:last-child {{
            border-right: none;
        }}
        
        .filter-section h4 {{
            margin-bottom: 15px;
            color: #34495e;
            font-size: 1.1em;
        }}
        
        .dir-tree, .file-types {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 8px;
            max-height: 200px;
            overflow-y: auto;
            padding: 5px;
        }}
        
        .dir-tree label, .file-types label {{
            display: flex;
            align-items: center;
            gap: 5px;
            padding: 5px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.2s;
        }}
        
        .dir-tree label:hover, .file-types label:hover {{
            background: #f5f5f5;
        }}
        
        .filter-actions {{
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }}
        
        .filter-actions button {{
            padding: 8px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s;
        }}
        
        .btn-primary {{
            background: #667eea;
            color: white;
        }}
        
        .btn-primary:hover {{
            background: #5a67d8;
        }}
        
        .btn-secondary {{
            background: #e2e8f0;
            color: #4a5568;
        }}
        
        .btn-secondary:hover {{
            background: #cbd5e0;
        }}
        
        .filter-indicator {{
            background: #e8f4fd;
            padding: 10px 20px;
            border-radius: 8px;
            margin: 10px 0;
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }}
        
        .badge {{
            background: #667eea;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.9em;
        }}
        
        /* 图表容器 */
        .chart-row {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 25px;
        }}
        
        .chart-container {{
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            height: 400px;
        }}
        
        .chart-container h3 {{
            margin-bottom: 15px;
            color: #34495e;
            font-size: 1.2em;
        }}
        
        /* 日历热力图 */
        .calendar-container {{
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 25px;
            height: 250px;
        }}
        
        /* 数据表格 */
        .table-container {{
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 25px;
            overflow-x: auto;
        }}
        
        table {{
            width: 100%;
            border-collapse: collapse;
        }}
        
        th {{
            background: #f7f9fc;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #34495e;
            cursor: pointer;
        }}
        
        th:hover {{
            background: #edf2f7;
        }}
        
        td {{
            padding: 10px 12px;
            border-bottom: 1px solid #e2e8f0;
        }}
        
        tr:hover {{
            background: #f7f9fc;
        }}
        
        .file-browser {{
            margin-top: 20px;
            border-top: 2px solid #e2e8f0;
            padding-top: 20px;
        }}
        
        .file-browser h4 {{
            margin-bottom: 15px;
            color: #34495e;
        }}
        
        .file-list {{
            max-height: 300px;
            overflow-y: auto;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
        }}
        
        .file-item {{
            display: flex;
            justify-content: space-between;
            padding: 8px 12px;
            border-bottom: 1px solid #e2e8f0;
        }}
        
        .file-item:hover {{
            background: #f7f9fc;
        }}
        
        .file-path {{
            font-family: monospace;
        }}
        
        .file-stats {{
            color: #718096;
            font-size: 0.9em;
        }}
        
        /* 响应式 */
        @media (max-width: 768px) {{
            .chart-row {{
                grid-template-columns: 1fr;
            }}
            
            .filter-sections {{
                grid-template-columns: 1fr;
            }}
        }}
        
        .footer {{
            text-align: center;
            padding: 20px;
            color: #718096;
            font-size: 0.9em;
        }}
    </style>
</head>
<body>
    <div class="dashboard">
        <!-- 头部 -->
        <div class="header">
            <h1>📊 {project_name} - 代码统计仪表板</h1>
            <p>生成时间: {generate_time} | 分析目录: {analyzed_dir} | {scope_note}</p>
        </div>
        
        <!-- 统计卡片 -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value">{total_files:,}</div>
                <div class="stat-label">总文件数</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{total_lines:,}</div>
                <div class="stat-label">总代码行</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{total_commits}</div>
                <div class="stat-label">总提交数</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{file_types_count}</div>
                <div class="stat-label">文件类型</div>
            </div>
        </div>
        
        <!-- 过滤面板 -->
        <div class="filter-panel">
            <div class="filter-header" onclick="toggleFilters()">
                <span>🔍 过滤选项</span>
                <span class="badge" id="activeFiltersCount">0 个过滤</span>
            </div>
            <div class="filter-body" id="filterBody">
                <div class="filter-sections">
                    <div class="filter-section">
                        <h4>📁 目录过滤</h4>
                        <div class="dir-tree" id="dirFilters">
                            <label><input type="checkbox" checked onchange="filterChanged()" data-dir="all"> 全部目录</label>
                            {directory_checkboxes}
                        </div>
                        <div style="margin-top: 10px;">
                            <input type="text" placeholder="排除目录(逗号分隔): node_modules,__pycache__" 
                                   id="excludeDirs" onchange="filterChanged()" value="node_modules,__pycache__,.git,venv">
                        </div>
                    </div>
                    
                    <div class="filter-section">
                        <h4>📄 文件类型</h4>
                        <div class="file-types" id="typeFilters">
                            <label><input type="checkbox" checked onchange="filterChanged()" data-ext="all"> 全部类型</label>
                            {filetype_checkboxes}
                        </div>
                    </div>
                    
                    <div class="filter-section">
                        <h4>⚙️ 高级过滤</h4>
                        <div style="margin-bottom: 10px;">
                            <label>最小行数: <input type="number" id="minLines" value="0" onchange="filterChanged()" style="width: 80px;"></label>
                        </div>
                        <div style="margin-bottom: 10px;">
                            <label>最大行数: <input type="number" id="maxLines" value="1000000" onchange="filterChanged()" style="width: 80px;"></label>
                        </div>
                        <div>
                            <label>文件名包含: <input type="text" id="nameFilter" onchange="filterChanged()" placeholder="例如: test"></label>
                        </div>
                    </div>
                </div>
                
                <div class="filter-actions">
                    <button class="btn-primary" onclick="applyFilters()">应用过滤</button>
                    <button class="btn-secondary" onclick="resetFilters()">重置</button>
                </div>
            </div>
        </div>
        
        <!-- 过滤指示器 -->
        <div class="filter-indicator" id="filterIndicator">
            <span>📁 已选择 <span id="selectedDirs">所有</span> 目录</span>
            <span>📄 已选择 <span id="selectedTypes">所有</span> 文件类型</span>
            <span>📊 显示 <span id="displayedFiles">0</span> 个文件 (<span id="displayedLines">0</span> 行)</span>
            <button class="btn-secondary" onclick="clearFilters()" style="margin-left: auto;">清除所有过滤 ✕</button>
        </div>
        
        <!-- 图表区域 -->
        <div class="chart-row">
            <div class="chart-container">
                <h3>📊 语言分布 (文件数)</h3>
                <div id="pieChart" style="height: 320px;"></div>
            </div>
            <div class="chart-container">
                <h3>📊 语言分布 (代码行)</h3>
                <div id="barChart" style="height: 320px;"></div>
            </div>
        </div>
        
        <!-- 日历热力图 -->
        <div class="calendar-container" style="height:280px">
            <h3>📅 提交活动日历 <span style="font-size:0.82em;font-weight:500;opacity:0.92;margin-left:8px">| 总提交数：{calendar_total_commits} | 工作天数：{calendar_commit_days}</span></h3>
            <div id="calendarChart" style="height:220px"></div>
        </div>
        
        <!-- 时间分析 -->
        <div class="chart-row">
            <div class="chart-container">
                <h3>⏰ 小时分布</h3>
                <div id="hourChart" style="height: 320px;"></div>
            </div>
            <div class="chart-container">
                <h3>📆 周分布</h3>
                <div id="weekChart" style="height: 320px;"></div>
            </div>
        </div>
        
        <!-- 数据表格 -->
        <div class="table-container">
            <h3>📋 详细统计</h3>
            <table id="statsTable">
                <thead>
                    <tr>
                        <th onclick="sortTable(0)">文件类型</th>
                        <th onclick="sortTable(1)">文件数</th>
                        <th onclick="sortTable(2)">代码行</th>
                        <th onclick="sortTable(3)">占比(文件)</th>
                        <th onclick="sortTable(4)">占比(行)</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
                    <!-- 动态生成 -->
                </tbody>
            </table>
        </div>
        
        <!-- 文件浏览器 -->
        <div class="table-container file-browser" id="fileBrowser" style="display: none;">
            <h4>📂 文件列表 - <span id="currentFileType"></span></h4>
            <div class="file-list" id="fileList">
                <!-- 动态生成 -->
            </div>
        </div>
        
        <!-- 底部 -->
        <div class="footer">
            由 Code Stats Visualizer 生成 | 数据仅供参考
        </div>
    </div>
    
    <script>
        // 原始数据
        const rawData = {json_data};
        let currentData = {{...rawData}};
        let filterState = {{
            segments: new Set((rawData.top_level_dirs || []).map(d => d.path)),
            fileTypes: new Set(rawData.file_types.map(t => t.ext)),
            excludeDirs: new Set(['node_modules', '__pycache__', '.git', 'venv']),
            minLines: 0,
            maxLines: 1000000,
            nameFilter: ''
        }};
        
        function toggleFilters() {{
            document.getElementById('filterBody').classList.toggle('show');
        }}
        
        function filterChanged() {{
            updateFilterState();
            updateFilterIndicator();
            applyFilters();
        }}
        
        function updateFilterState() {{
            filterState.segments.clear();
            document.querySelectorAll('#dirFilters input[type="checkbox"]:checked').forEach(cb => {{
                if (cb.dataset.dir !== 'all') {{
                    filterState.segments.add(cb.dataset.dir);
                }}
            }});
            filterState.fileTypes.clear();
            document.querySelectorAll('#typeFilters input[type="checkbox"]:checked').forEach(cb => {{
                if (cb.dataset.ext !== 'all') {{
                    filterState.fileTypes.add(cb.dataset.ext);
                }}
            }});
            
            // 更新排除目录
            filterState.excludeDirs = new Set(
                document.getElementById('excludeDirs').value.split(',').map(s => s.trim()).filter(s => s)
            );
            
            // 更新行数过滤
            filterState.minLines = parseInt(document.getElementById('minLines').value) || 0;
            filterState.maxLines = parseInt(document.getElementById('maxLines').value) || 1000000;
            filterState.nameFilter = document.getElementById('nameFilter').value.toLowerCase();
        }}
        
        function applyFilters() {{
            updateFilterState();
            
            // 过滤文件数据
            const dirAll = document.querySelector('#dirFilters input[data-dir="all"]')?.checked;
            const typeAll = document.querySelector('#typeFilters input[data-ext="all"]')?.checked;
            const filteredFiles = rawData.files.filter(file => {{
                if (!dirAll) {{
                    const seg = file.path.split('/')[0];
                    if (!filterState.segments.has(seg)) return false;
                }}
                for (let exclude of filterState.excludeDirs) {{
                    if (file.path.includes(exclude)) return false;
                }}
                if (!typeAll && filterState.fileTypes.size > 0) {{
                    if (!filterState.fileTypes.has(file.ext)) return false;
                }}
                
                // 行数过滤
                if (file.lines < filterState.minLines || file.lines > filterState.maxLines) return false;
                
                // 文件名过滤
                if (filterState.nameFilter && !file.path.toLowerCase().includes(filterState.nameFilter)) return false;
                
                return true;
            }});
            
            // 更新统计
            updateCharts(filteredFiles);
            updateTable(filteredFiles);
            updateFileCount(filteredFiles);
        }}
        
        function updateCharts(filteredFiles) {{
            // 按文件类型聚合
            const typeStats = {{}};
            filteredFiles.forEach(file => {{
                if (!typeStats[file.ext]) {{
                    typeStats[file.ext] = {{
                        name: file.name,
                        files: 0,
                        lines: 0
                    }};
                }}
                typeStats[file.ext].files++;
                typeStats[file.ext].lines += file.lines;
            }});
            
            const pairs = Object.keys(typeStats).map(t => ({{
                ext: t, name: typeStats[t].name, files: typeStats[t].files, lines: typeStats[t].lines
            }}));
            pairs.sort((a, b) => b.lines - a.lines);
            const typeNames = pairs.map(p => p.name);
            const fileCounts = pairs.map(p => p.files);
            const lineCounts = pairs.map(p => p.lines);
            updatePieChart(typeNames, fileCounts);
            updateBarChart(typeNames, lineCounts);
            
            // 更新日历图
            updateCalendarChart();
            
            // 更新时间分布图
            updateTimeCharts();
        }}
        
        function updatePieChart(types, counts) {{
            const chart = echarts.init(document.getElementById('pieChart'));
            chart.setOption({{
                tooltip: {{ trigger: 'item', formatter: '{{b}}: {{c}} ({{d}}%)' }},
                legend: {{ orient: 'vertical', left: 'left', top: 'center' }},
                series: [{{
                    type: 'pie',
                    radius: ['40%', '70%'],
                    avoidLabelOverlap: true,
                    itemStyle: {{
                        borderRadius: 10,
                        borderColor: '#fff',
                        borderWidth: 2
                    }},
                    label: {{ show: false }},
                    emphasis: {{ scale: true }},
                    data: types.map((t, i) => ({{ name: t, value: counts[i] }}))
                }}]
            }});
        }}
        
        function updateBarChart(types, counts) {{
            const chart = echarts.init(document.getElementById('barChart'));
            chart.setOption({{
                tooltip: {{ trigger: 'axis', axisPointer: {{ type: 'shadow' }} }},
                grid: {{ left: '10%', right: '5%', bottom: '15%', top: '10%' }},
                xAxis: {{
                    type: 'category',
                    data: types,
                    axisLabel: {{ rotate: 45, interval: 0 }}
                }},
                yAxis: {{ type: 'value', name: '代码行数' }},
                series: [{{
                    name: '代码行',
                    type: 'bar',
                    data: counts,
                    itemStyle: {{
                        color: '#667eea',
                        borderRadius: [4,4,0,0]
                    }},
                    label: {{
                        show: true,
                        position: 'top',
                        formatter: (p) => p.value.toLocaleString()
                    }}
                }}]
            }});
        }}
        
        function updateCalendarChart() {{
            const chart = echarts.init(document.getElementById('calendarChart'));
            const calData = rawData.calendar_data || [];
            const range = rawData.calendar_range && rawData.calendar_range.length === 2
                ? rawData.calendar_range
                : [new Date().getFullYear() + '-01-01', new Date().getFullYear() + '-12-31'];
            const counts = calData.map(d => d[1]);
            const maxVal = counts.length ? Math.max.apply(null, counts) : 1;
            chart.setOption({{
                tooltip: {{
                    trigger: 'item',
                    formatter: function (p) {{
                        if (!p || p.value == null) return '';
                        var v = p.value;
                        var date = Array.isArray(v) ? v[0] : (p.data && p.data[0]) || '';
                        var n = Array.isArray(v) ? v[1] : v;
                        return '<b>' + date + '</b><br/>提交次数：<b style="color:#c2410c">' + n + '</b>';
                    }}
                }},
                visualMap: {{
                    show: true,
                    type: 'continuous',
                    min: 0,
                    max: maxVal,
                    orient: 'horizontal',
                    left: '8%',
                    right: '8%',
                    bottom: 2,
                    height: 18,
                    calculable: true,
                    inRange: {{
                        color: [
                            '#dbeafe', '#93c5fd', '#60a5fa', '#38bdf8',
                            '#34d399', '#fbbf24', '#fb923c', '#f87171', '#dc2626', '#991b1b'
                        ]
                    }},
                    text: ['高', '低'],
                    textStyle: {{ fontSize: 11, color: '#475569' }}
                }},
                calendar: {{
                    range: range,
                    cellSize: ['auto', 16],
                    itemStyle: {{ borderWidth: 1, borderColor: '#fff' }},
                    dayLabel: {{ show: false }},
                    monthLabel: {{ show: true, margin: 8, color: '#334155' }},
                    yearLabel: {{ show: true, margin: 24 }}
                }},
                series: [{{
                    type: 'heatmap',
                    coordinateSystem: 'calendar',
                    data: calData,
                    itemStyle: {{
                        borderWidth: 1,
                        borderColor: 'rgba(255,255,255,0.85)',
                        borderRadius: 3
                    }},
                    emphasis: {{
                        itemStyle: {{ shadowBlur: 8, shadowColor: 'rgba(0,0,0,0.25)' }}
                    }}
                }}]
            }});
        }}
        
        function updateTimeCharts() {{
            // 小时分布图
            const hourChart = echarts.init(document.getElementById('hourChart'));
            hourChart.setOption({{
                tooltip: {{ trigger: 'axis' }},
                xAxis: {{
                    type: 'category',
                    data: Array.from({{length: 24}}, (_, i) => i + ':00')
                }},
                yAxis: {{ type: 'value' }},
                series: [{{
                    type: 'bar',
                    data: rawData.hourly_commits || Array(24).fill(0),
                    itemStyle: {{ color: '#48bb78' }}
                }}]
            }});
            
            // 周分布图
            const weekChart = echarts.init(document.getElementById('weekChart'));
            weekChart.setOption({{
                tooltip: {{ trigger: 'axis' }},
                xAxis: {{
                    type: 'category',
                    data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
                }},
                yAxis: {{ type: 'value' }},
                series: [{{
                    type: 'bar',
                    data: rawData.weekly_commits || Array(7).fill(0),
                    itemStyle: {{ color: '#f6ad55' }}
                }}]
            }});
        }}
        
        function updateTable(filteredFiles) {{
            // 聚合表格数据
            const typeStats = {{}};
            filteredFiles.forEach(file => {{
                if (!typeStats[file.ext]) {{
                    typeStats[file.ext] = {{
                        name: file.name,
                        files: 0,
                        lines: 0
                    }};
                }}
                typeStats[file.ext].files++;
                typeStats[file.ext].lines += file.lines;
            }});
            
            const totalFiles = filteredFiles.length;
            const totalLines = filteredFiles.reduce((sum, f) => sum + f.lines, 0);
            
            const rows = Object.keys(typeStats).map(ext => ({{
                ext, stat: typeStats[ext],
                linePct: totalLines ? (typeStats[ext].lines / totalLines) : 0
            }}));
            rows.sort((a, b) => b.stat.lines - a.stat.lines);
            let html = '';
            rows.forEach(({{ ext, stat }}) => {{
                const filePercent = ((stat.files / totalFiles) * 100).toFixed(1);
                const linePercent = ((stat.lines / totalLines) * 100).toFixed(1);
                html += `<tr>
                    <td>${{stat.name}}</td>
                    <td>${{stat.files}}</td>
                    <td>${{stat.lines.toLocaleString()}}</td>
                    <td>${{filePercent}}%</td>
                    <td>${{linePercent}}%</td>
                    <td><button onclick="showFiles('${{ext}}')" class="btn-secondary">查看文件</button></td>
                </tr>`;
            }});
            document.getElementById('tableBody').innerHTML = html;
        }}
        
        function updateFileCount(filteredFiles) {{
            const totalFiles = filteredFiles.length;
            const totalLines = filteredFiles.reduce((sum, f) => sum + f.lines, 0);
            document.getElementById('displayedFiles').textContent = totalFiles;
            document.getElementById('displayedLines').textContent = totalLines.toLocaleString();
            const da = document.querySelector('#dirFilters input[data-dir="all"]')?.checked;
            const ta = document.querySelector('#typeFilters input[data-ext="all"]')?.checked;
            const activeFilters = (!da && filterState.segments.size > 0 ? 1 : 0) +
                                 (!ta && filterState.fileTypes.size > 0 ? 1 : 0) +
                                 (filterState.minLines > 0 ? 1 : 0) +
                                 (filterState.maxLines < 1000000 ? 1 : 0) +
                                 (filterState.nameFilter ? 1 : 0);
            document.getElementById('activeFiltersCount').textContent = activeFilters + ' 个过滤';
        }}
        
        function showFiles(ext) {{
            const type = rawData.file_types.find(t => t.ext === ext);
            if (!type) return;
            
            const files = rawData.files.filter(f => f.ext === ext);
            const fileList = document.getElementById('fileList');
            let html = '';
            
            files.sort((a, b) => b.lines - a.lines).forEach(file => {{
                html += `<div class="file-item">
                    <span class="file-path">${{file.path}}</span>
                    <span class="file-stats">${{file.lines}} 行 | ${{(file.size/1024).toFixed(1)}} KB</span>
                </div>`;
            }});
            
            fileList.innerHTML = html;
            document.getElementById('currentFileType').textContent = type.name;
            document.getElementById('fileBrowser').style.display = 'block';
        }}
        
        function resetFilters() {{
            document.querySelectorAll('#dirFilters input[type="checkbox"]').forEach(cb => cb.checked = true);
            document.querySelectorAll('#typeFilters input[type="checkbox"]').forEach(cb => cb.checked = true);
            document.getElementById('excludeDirs').value = 'node_modules,__pycache__,.git,venv';
            document.getElementById('minLines').value = '0';
            document.getElementById('maxLines').value = '1000000';
            document.getElementById('nameFilter').value = '';
            filterChanged();
        }}
        
        function clearFilters() {{
            resetFilters();
        }}
        
        function sortTable(col) {{
            // 简单的表格排序
            const table = document.getElementById('statsTable');
            const tbody = document.getElementById('tableBody');
            const rows = Array.from(tbody.querySelectorAll('tr'));
            
            rows.sort((a, b) => {{
                const aVal = a.cells[col].textContent;
                const bVal = b.cells[col].textContent;
                if (col === 0) return aVal.localeCompare(bVal);
                return parseFloat(aVal) - parseFloat(bVal);
            }});
            
            tbody.innerHTML = '';
            rows.forEach(row => tbody.appendChild(row));
        }}
        
        // 初始化
        window.onload = function() {{
            applyFilters();
        }};
    </script>
</body>
</html>
"""


# 默认排除的目录（仅影响「目录过滤」与统计，可与 --exclude-dir 叠加）
DEFAULT_EXCLUDE_DIRS = frozenset({
    '.git', '.cursor', '.cursorGrowth', '.github', '3rdparty',
    '__pycache__', 'node_modules', 'dist', 'build', '.pytest_cache',
    '.mypy_cache', 'logs', 'uploads', 'temp', 'tmp', '.coverage',
    'htmlcov', '.tox', '.venv', 'venv', 'env', 'ENV', '.idea', 'idea'
})

# 不参与统计的后缀：模型、引擎、图片/视频/音频等二进制与媒体文件
SKIP_EXTENSIONS = frozenset({
    '.engine', '.onnx', '.pt', '.pth', '.pt.tar', '.bin', '.weights',
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.ico', '.svg',
    '.mp4', '.avi', '.mov', '.mkv', '.webm', '.wmv', '.flv', '.m4v',
    '.mp3', '.wav', '.ogg', '.flac', '.aac', '.m4a', '.wma',
    '.pdf', '.so', '.dll', '.dylib', '.dll.a', '.a', '.lib',
    '.exe', '.pyc', '.pyo', '.whl', '.egg', '.npy', '.npz',
    '.pkl', '.pickle', '.h5', '.hdf5', '.pb', '.tflite', '.caffemodel',
    '.zip', '.tar', '.gz', '.xz', '.7z', '.rar', '.bz2',
    '.ttf', '.woff', '.woff2', '.eot', '.otf',
    '.template',
})


def _normalize_analyze_prefix(prefix):
    if not prefix or not str(prefix).strip():
        return None
    p = str(prefix).replace('\\', '/').strip().strip('./')
    return p if p else None


class CodeStatsVisualizer:
    def __init__(
        self,
        root_path,
        git_only=True,
        exclude_dirs=None,
        git_all_branches=False,
        git_days=365,
        analyze_prefix=None,
    ):
        self.root_path = Path(root_path).resolve()
        self.git_only = git_only
        self.exclude_dirs = set(exclude_dirs) if exclude_dirs else set(DEFAULT_EXCLUDE_DIRS)
        self.git_all_branches = git_all_branches
        self.git_days = git_days  # 0 或 None 表示全部历史
        self.analyze_prefix = _normalize_analyze_prefix(analyze_prefix)
        
        self.file_extensions = {
            '.py': 'Python',
            '.js': 'JavaScript',
            '.ts': 'TypeScript',
            '.jsx': 'React',
            '.tsx': 'React TypeScript',
            '.vue': 'Vue.js',
            '.html': 'HTML',
            '.htm': 'HTML',
            '.css': 'CSS',
            '.scss': 'SCSS',
            '.sass': 'SASS',
            '.less': 'LESS',
            '.json': 'JSON',
            '.yaml': 'YAML',
            '.yml': 'YAML',
            '.md': 'Markdown',
            '.txt': 'Text',
            '.sh': 'Shell Script',
            '.bash': 'Shell Script',
            '.zsh': 'Shell Script',
            '.c': 'C',
            '.cpp': 'C++',
            '.cc': 'C++',
            '.cxx': 'C++',
            '.h': 'C/C++ Header',
            '.hpp': 'C++ Header',
            '.hxx': 'C++ Header',
            '.inl': 'C++ Inline',
            '.tcc': 'C++ Template',
            '.ipp': 'C++ Template',
            '.cmake': 'CMake',
            '.sql': 'SQL',
            '.xml': 'XML',
            '.svg': 'SVG',
            '.ini': 'INI',
            '.cfg': 'Config',
            '.conf': 'Config',
            '.toml': 'TOML',
            '.go': 'Go',
            '.rs': 'Rust',
            '.rb': 'Ruby',
            '.php': 'PHP',
            '.java': 'Java',
            '.kt': 'Kotlin',
            '.swift': 'Swift',
            '.dockerfile': 'Docker',
            '.dockerignore': 'Docker',
        }
        
    def get_git_tracked_files(self):
        """返回被 git 跟踪的文件的相对路径列表（仅当前仓库内）。非 git 目录返回空列表。"""
        try:
            r = subprocess.run(
                ['git', 'ls-files', '--cached'],
                cwd=self.root_path,
                capture_output=True,
                text=True,
                timeout=15,
            )
            if r.returncode != 0:
                return []
            return [line.strip() for line in r.stdout.splitlines() if line.strip()]
        except Exception:
            return []

    def get_git_submodule_paths(self):
        """返回子模块相对路径集合，用于排除子模块内文件。如 {'3rdparty/Eigen'}。"""
        out = set()
        try:
            r = subprocess.run(
                ['git', 'submodule', 'status', '--recursive'],
                cwd=self.root_path,
                capture_output=True,
                text=True,
                timeout=10,
            )
            if r.returncode != 0:
                return out
            for line in r.stdout.splitlines():
                line = line.strip()
                if not line:
                    continue
                # " abc123 path/to/submodule (optional-ref)" or "-abc path (not initialized)"
                parts = line.split()
                if len(parts) >= 2:
                    out.add(parts[1].replace('\\', '/'))
        except Exception:
            pass
        return out

    def _under_submodule(self, rel_path, submodule_paths):
        """rel_path 是否位于任一子模块下（含子模块根路径本身）。"""
        rel = rel_path.replace('\\', '/')
        for sm in submodule_paths:
            if rel == sm or rel.startswith(sm + '/'):
                return True
        return False

    def _skip_extension(self, file_path):
        """是否因后缀不参与统计而跳过（模型、二进制、媒体等）。"""
        name = file_path.name.lower()
        if name in ('dockerfile', '.dockerignore'):
            return False
        # 单后缀
        if file_path.suffix.lower() in SKIP_EXTENSIONS:
            return True
        # 多后缀如 .pt.tar
        for s in file_path.suffixes:
            if s.lower() in SKIP_EXTENSIONS:
                return True
        return False

    def should_exclude(self, path):
        """路径是否应排除：任一路径段在 exclude_dirs 中则排除。path 可为 Path 或相对路径字符串。"""
        if isinstance(path, str):
            parts = Path(path).parts
        else:
            parts = path.parts
        for part in parts:
            if part in self.exclude_dirs:
                return True
        return False
    
    def get_file_type(self, file_path):
        """Get file type based on extension"""
        suffix = file_path.suffix.lower()
        name = file_path.name.lower()
        
        # 处理特殊文件名
        if name == 'dockerfile':
            return '.dockerfile', 'Docker'
        if name == '.dockerignore':
            return '.dockerignore', 'Docker'
            
        return suffix, self.file_extensions.get(suffix, f'Other ({suffix})')
    
    def _under_analyze_prefix(self, rel_str):
        """仅统计路径前缀下的文件（--subdir）。"""
        if not self.analyze_prefix:
            return True
        r = rel_str.replace('\\', '/')
        p = self.analyze_prefix
        return r == p or r.startswith(p + '/')

    def _file_iter(self):
        """生成 (rel_path_str, full_path) 用于统计。不含子模块、排除目录、以及模型/二进制/媒体后缀。"""
        if self.git_only:
            submodule_paths = self.get_git_submodule_paths()
            for rel in self.get_git_tracked_files():
                rel_n = rel.replace('\\', '/')
                if not self._under_analyze_prefix(rel_n):
                    continue
                if self._under_submodule(rel, submodule_paths):
                    continue
                if self.should_exclude(rel):
                    continue
                full = self.root_path / rel
                if not full.is_file() or self._skip_extension(full):
                    continue
                yield rel_n, full
        else:
            submodule_paths = self.get_git_submodule_paths()
            base = self.root_path
            if self.analyze_prefix:
                base = self.root_path / self.analyze_prefix
                if not base.is_dir():
                    return
            for file_path in base.rglob('*'):
                if not file_path.is_file() or self._skip_extension(file_path):
                    continue
                try:
                    rel_path = file_path.relative_to(self.root_path)
                except ValueError:
                    continue
                rel_str = str(rel_path).replace('\\', '/')
                if not self._under_analyze_prefix(rel_str):
                    continue
                if self._under_submodule(rel_str, submodule_paths) or self.should_exclude(rel_path):
                    continue
                yield rel_str, file_path

    def collect_stats(self):
        """Collect all statistics（默认仅统计 git 跟踪且未在排除目录中的文件）"""
        stats = {
            'directories': defaultdict(lambda: {'files': 0, 'lines': 0}),
            'file_types': defaultdict(lambda: {'files': 0, 'lines': 0, 'name': ''}),
            'files': [],
            'total_files': 0,
            'total_lines': 0
        }
        for rel_str, file_path in self._file_iter():
            directory = str(Path(rel_str).parent) if '/' in rel_str else 'root'
            if directory == '.':
                directory = 'root'
            ext, type_name = self.get_file_type(file_path)
            lines = 0
            if ext in self.file_extensions or ext in ['.txt', '.md', '.cfg', '.conf', '.ini', '.toml', '.yaml', '.yml', '.json']:
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        lines = sum(1 for _ in f)
                except Exception:
                    pass
            size = file_path.stat().st_size
            stats['directories'][directory]['files'] += 1
            stats['directories'][directory]['lines'] += lines
            stats['file_types'][ext]['files'] += 1
            stats['file_types'][ext]['lines'] += lines
            stats['file_types'][ext]['name'] = type_name
            stats['files'].append({
                'path': rel_str,
                'ext': ext,
                'name': type_name,
                'lines': lines,
                'size': size,
                'directory': directory
            })
            stats['total_files'] += 1
            stats['total_lines'] += lines
        return stats
    
    def get_git_stats(self):
        """Get git statistics. 默认当前分支、最近 git_days 天；git_days<=0 为全部历史。"""
        stats = {
            'total_commits': 0,
            'hourly_commits': [0] * 24,
            'weekly_commits': [0] * 7,
            'calendar_data': [],
            'calendar_range': None,
            'commit_days': 0,
        }
        try:
            cmd = ['git', 'log', '--pretty=format:%cd', '--date=iso']
            if self.git_all_branches:
                cmd.append('--all')
            if self.git_days and self.git_days > 0:
                cmd.extend(['--since', f'{self.git_days} days ago'])
            if self.analyze_prefix:
                cmd.extend(['--', self.analyze_prefix])
            result = subprocess.run(
                cmd,
                cwd=self.root_path,
                capture_output=True,
                text=True,
                timeout=60,
            )
            if result.returncode != 0:
                return stats
            dates = []
            for line in result.stdout.strip().splitlines():
                line = line.strip()
                if not line:
                    continue
                try:
                    dt = datetime.strptime(line.split('+')[0].strip(), '%Y-%m-%d %H:%M:%S')
                    dates.append(dt)
                except ValueError:
                    continue
            stats['total_commits'] = len(dates)
            for dt in dates:
                stats['hourly_commits'][dt.hour] += 1
                stats['weekly_commits'][dt.weekday()] += 1
            daily_counts = defaultdict(int)
            for dt in dates:
                daily_counts[dt.strftime('%Y-%m-%d')] += 1
            stats['calendar_data'] = [[d, c] for d, c in sorted(daily_counts.items())]
            stats['commit_days'] = len(daily_counts)
            if stats['calendar_data']:
                first = stats['calendar_data'][0][0]
                last = stats['calendar_data'][-1][0]
                stats['calendar_range'] = [first, last]
        except Exception as e:
            print(f"Warning: Could not get git stats: {e}")
        return stats
    
    def generate_html(self, output_path):
        """Generate HTML dashboard"""
        print("Collecting statistics...")
        stats = self.collect_stats()
        git_stats = self.get_git_stats()
        
        seg_agg = defaultdict(lambda: {'files': 0, 'lines': 0})
        for f in stats['files']:
            seg = f['path'].split('/')[0] if '/' in f['path'] else 'root'
            seg_agg[seg]['files'] += 1
            seg_agg[seg]['lines'] += f['lines']
        top_level_dirs = [
            {'path': k, 'files': v['files'], 'lines': v['lines']}
            for k, v in sorted(seg_agg.items(), key=lambda x: -x[1]['lines'])
        ]
        file_types = [
            {'ext': ext, 'name': v['name'], 'files': v['files'], 'lines': v['lines']}
            for ext, v in sorted(stats['file_types'].items(), key=lambda x: x[1]['files'], reverse=True)
            if v['files'] > 0
        ]
        dir_checkboxes = '\n'.join([
            f'<label><input type="checkbox" checked onchange="filterChanged()" data-dir="{d["path"]}"> 📁 {d["path"]} ({d["lines"]:,} 行)</label>'
            for d in top_level_dirs
        ])
        type_checkboxes = '\n'.join([
            f'<label><input type="checkbox" checked onchange="filterChanged()" data-ext="{t["ext"]}"> {t["name"]}</label>'
            for t in file_types
        ])
        json_data = {
            'top_level_dirs': top_level_dirs,
            'file_types': file_types,
            'files': stats['files'],
            'hourly_commits': git_stats['hourly_commits'],
            'weekly_commits': git_stats['weekly_commits'],
            'calendar_data': git_stats['calendar_data'],
            'calendar_range': git_stats.get('calendar_range'),
        }
        
        scope_note = '范围: 仅 Git 跟踪文件' if self.git_only else '范围: 全目录扫描'
        if self.analyze_prefix:
            scope_note += f' | 子目录: {self.analyze_prefix}'
        html_content = HTML_TEMPLATE.format(
            project_name=self.root_path.name,
            generate_time=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            analyzed_dir=str(self.root_path),
            scope_note=scope_note,
            total_files=stats['total_files'],
            total_lines=stats['total_lines'],
            total_commits=git_stats['total_commits'],
            calendar_total_commits=git_stats['total_commits'],
            calendar_commit_days=git_stats.get('commit_days', 0),
            file_types_count=len(file_types),
            directory_checkboxes=dir_checkboxes,
            filetype_checkboxes=type_checkboxes,
            json_data=json.dumps(json_data, ensure_ascii=False)
        )
        
        # 写入文件
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print(f"✅ HTML dashboard generated: {output_path}")
        return output_path


def main():
    parser = argparse.ArgumentParser(
        description='Generate code statistics HTML dashboard (default: only git-tracked files)'
    )
    parser.add_argument(
        'path',
        nargs='?',
        default=None,
        metavar='DIR',
        help='项目根目录（与 --dir 二选一，例如: python scripts/code_stats_viz.py .）',
    )
    parser.add_argument('--dir', type=str, help='Directory to analyze (default: current directory)')
    parser.add_argument(
        '--output',
        type=str,
        default=None,
        metavar='FILE',
        help='输出 HTML 路径；默认不写则为「分析根目录文件夹名」_code_stats.html（写入当前工作目录）',
    )
    parser.add_argument('--open', action='store_true', help='Open in browser after generation')
    parser.add_argument(
        '--git-only',
        action='store_true',
        default=True,
        help='Only analyze git-tracked files (default: True)',
    )
    parser.add_argument(
        '--no-git-only',
        action='store_false',
        dest='git_only',
        help='Analyze all files under directory (filesystem walk)',
    )
    parser.add_argument(
        '--exclude-dir',
        action='append',
        default=[],
        metavar='DIR',
        help='Exclude directory from analysis (can repeat).',
    )
    parser.add_argument(
        '--no-default-excludes',
        action='store_true',
        help='Do not use default exclude list; only exclude dirs from --exclude-dir.',
    )
    parser.add_argument(
        '--all-branches',
        action='store_true',
        help='Include all branches in commit stats (git log --all).',
    )
    parser.add_argument(
        '--days',
        type=int,
        default=365,
        metavar='N',
        help='Only count commits in last N days (default: 365). Use 0 for all history.',
    )
    parser.add_argument(
        '--all-history',
        action='store_true',
        help='Same as --days 0: count all commits in history.',
    )
    parser.add_argument(
        '--subdir',
        type=str,
        default=None,
        metavar='PATH',
        help='仅分析该相对路径下的文件；提交日历也仅统计曾修改该路径下文件的提交。例: --subdir sdk 或 sdk/source',
    )
    args = parser.parse_args()

    root_arg = args.path or args.dir
    target_dir = Path(root_arg).resolve() if root_arg else Path.cwd()
    if not target_dir.exists():
        print(f"❌ Directory not found: {target_dir}")
        sys.exit(1)

    exclude_dirs = set() if args.no_default_excludes else set(DEFAULT_EXCLUDE_DIRS)
    for d in args.exclude_dir or []:
        exclude_dirs.add(d.strip().lstrip('./'))

    print(f"🔍 分析根目录: {target_dir}")
    print(f"   当前工作目录 (cwd): {Path.cwd()}")
    if args.git_only:
        print("   Mode: git-tracked files only (use --no-git-only for full filesystem)")
    else:
        print("   Mode: full filesystem walk")
    if exclude_dirs:
        print(f"   Excluded dirs: {', '.join(sorted(exclude_dirs)[:15])}{'...' if len(exclude_dirs) > 15 else ''}")
    if args.subdir:
        print(f"   仅子目录: {_normalize_analyze_prefix(args.subdir)}")

    git_days = 0 if args.all_history else args.days
    visualizer = CodeStatsVisualizer(
        target_dir,
        git_only=args.git_only,
        exclude_dirs=exclude_dirs,
        git_all_branches=args.all_branches,
        git_days=git_days,
        analyze_prefix=args.subdir,
    )
    out_file = args.output
    if out_file is None:
        prefix = target_dir.name or 'project'
        out_file = f'{prefix}_code_stats.html'
    output_path = visualizer.generate_html(out_file)
    
    # 打开浏览器
    if args.open:
        webbrowser.open(f'file://{output_path.absolute()}')
    
    print("✨ Done!")


if __name__ == '__main__':
    main()
