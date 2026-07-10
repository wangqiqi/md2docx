/**
 * Markdown to DOCX Converter - JavaScript 功能
 */

// 全局状态
let currentMode = 'editor'; // 'editor' 或 'features'
let previewCollapsed = false;

// 页面加载完成后的初始化
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    // 初始化事件监听器
    initializeEventListeners();

    // 初始化文件上传
    initializeFileUpload();
    initializeBatchConvert();

    // 初始化键盘快捷键
    initializeKeyboardShortcuts();

    console.log('🚀 Markdown to DOCX Converter 已初始化');
}

/**
 * 初始化工具提示
 */
function initializeTooltips() {
    const tooltipElements = document.querySelectorAll('.tooltip');

    tooltipElements.forEach(element => {
        element.addEventListener('mouseenter', showTooltip);
        element.addEventListener('mouseleave', hideTooltip);
    });
}

function showTooltip(event) {
    const tooltip = event.currentTarget.querySelector('.tooltiptext');
    if (tooltip) {
        tooltip.style.visibility = 'visible';
        tooltip.style.opacity = '1';
    }
}

function hideTooltip(event) {
    const tooltip = event.currentTarget.querySelector('.tooltiptext');
    if (tooltip) {
        tooltip.style.visibility = 'hidden';
        tooltip.style.opacity = '0';
    }
}

/**
 * 初始化表单验证
 */
function initializeFormValidation() {
    const forms = document.querySelectorAll('form');

    forms.forEach(form => {
        form.addEventListener('submit', function(event) {
            if (!validateForm(form)) {
                event.preventDefault();
            }
        });
    });
}

function validateForm(form) {
    let isValid = true;

    // 检查必填字段
    const requiredFields = form.querySelectorAll('[required]');
    requiredFields.forEach(field => {
        if (!field.value.trim()) {
            showFieldError(field, '此字段为必填项');
            isValid = false;
        } else {
            clearFieldError(field);
        }
    });

    // 检查文件大小
    const fileInput = form.querySelector('input[type="file"]');
    if (fileInput && fileInput.files.length > 0) {
        const file = fileInput.files[0];
        const maxSize = 16 * 1024 * 1024; // 16MB

        if (file.size > maxSize) {
            showFieldError(fileInput, '文件大小不能超过 16MB');
            isValid = false;
        } else {
            clearFieldError(fileInput);
        }
    }

    return isValid;
}

function showFieldError(field, message) {
    clearFieldError(field);

    const errorDiv = document.createElement('div');
    errorDiv.className = 'field-error';
    errorDiv.textContent = message;
    errorDiv.style.cssText = `
        color: #dc3545;
        font-size: 0.8rem;
        margin-top: 0.25rem;
        display: block;
    `;

    field.parentNode.appendChild(errorDiv);
    field.style.borderColor = '#dc3545';
}

function clearFieldError(field) {
    const existingError = field.parentNode.querySelector('.field-error');
    if (existingError) {
        existingError.remove();
    }
    field.style.borderColor = '';
}

/**
 * 初始化文件上传预览
 */
function initializeFileUpload() {
    const fileInputs = document.querySelectorAll('input[type="file"]');

    fileInputs.forEach(input => {
        input.addEventListener('change', handleFileSelect);
    });
}

function handleFileSelect(event) {
    if (event.target.id === 'batch-file-input') {
        return;
    }
    const file = event.target.files[0];
    if (!file) return;

    // 显示文件信息
    showFileInfo(file, event.target);

    // 如果是文本文件，尝试预览内容
    if (isTextFile(file)) {
        previewTextFile(file);
    }
}

/**
 * 初始化批量转换。
 */
function initializeBatchConvert() {
    const input = document.getElementById('batch-file-input');
    const selectButton = document.getElementById('batch-select-button');
    const convertButton = document.getElementById('batch-convert-button');
    if (!input || !selectButton || !convertButton) return;

    selectButton.addEventListener('click', () => input.click());
    input.addEventListener('change', renderBatchSelection);
    convertButton.addEventListener('click', convertBatch);
}

function renderBatchSelection() {
    const input = document.getElementById('batch-file-input');
    const panel = document.getElementById('batch-panel');
    const list = document.getElementById('batch-file-list');
    const summary = document.getElementById('batch-selection-summary');
    const convertButton = document.getElementById('batch-convert-button');
    const result = document.getElementById('batch-result');
    const files = Array.from(input.files);

    panel.hidden = false;
    result.hidden = true;
    list.replaceChildren();

    files.forEach(file => {
        const item = document.createElement('li');
        item.textContent = `${file.name} · ${formatFileSize(file.size)}`;
        list.appendChild(item);
    });

    summary.textContent = files.length
        ? `已选择 ${files.length} 个文件`
        : '请选择多个 Markdown 文件';
    convertButton.disabled = files.length === 0;
}

async function convertBatch() {
    const input = document.getElementById('batch-file-input');
    const button = document.getElementById('batch-convert-button');
    const files = Array.from(input.files);
    if (!files.length) {
        showBatchRequestError('E_CONTENT_EMPTY', '请先选择文件');
        return;
    }

    const progress = document.getElementById('batch-progress');
    const progressBar = document.getElementById('batch-progress-bar');
    const progressStatus = document.getElementById('batch-progress-status');
    const progressCount = document.getElementById('batch-progress-count');
    const restoreButton = showLoading(button);
    const formData = new FormData();
    files.forEach(file => formData.append('files', file));

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
    if (csrfToken) formData.append('csrf_token', csrfToken);

    progress.hidden = false;
    progressBar.max = files.length;
    progressBar.value = 0;
    progressStatus.textContent = '上传并转换中…';
    progressCount.textContent = `0/${files.length}`;

    try {
        const response = await fetch('/convert/batch', {
            method: 'POST',
            headers: {'X-CSRFToken': csrfToken},
            body: formData
        });
        if (!response.ok) {
            const error = await response.json().catch(() => ({
                code: 'E_CONVERT_FAILED',
                message: `请求失败（HTTP ${response.status}）`
            }));
            throw Object.assign(new Error(error.message), {code: error.code});
        }

        const blob = await response.blob();
        const summary = parseBatchHeader(response.headers.get('X-Batch-Summary'), {
            total: files.length,
            succeeded: files.length,
            failed: 0
        });
        const errors = parseBatchHeader(response.headers.get('X-Batch-Errors'), []);

        progressBar.value = summary.total;
        progressCount.textContent = `${summary.total}/${summary.total}`;
        progressStatus.textContent = '转换完成';
        downloadBatchZip(blob);
        renderBatchResult(summary, errors);
    } catch (error) {
        progressStatus.textContent = '转换失败';
        showBatchRequestError(error.code || 'E_CONVERT_FAILED', error.message);
    } finally {
        restoreButton();
    }
}

function parseBatchHeader(value, fallback) {
    if (!value) return fallback;
    try {
        return JSON.parse(decodeURIComponent(value));
    } catch (error) {
        console.warn('无法解析批量结果头:', error);
        return fallback;
    }
}

function downloadBatchZip(blob) {
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'batch_converted.zip';
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);
}

function renderBatchResult(summary, errors) {
    const result = document.getElementById('batch-result');
    result.replaceChildren();
    result.hidden = false;

    const heading = document.createElement('strong');
    heading.textContent = `完成：成功 ${summary.succeeded}，失败 ${summary.failed}`;
    result.appendChild(heading);

    if (errors.length) {
        const list = document.createElement('ul');
        errors.forEach(error => {
            const item = document.createElement('li');
            item.className = 'batch-error-item';
            item.textContent = `${error.filename} · [${error.code}] ${error.message}`;
            list.appendChild(item);
        });
        result.appendChild(list);
    }
}

function showBatchRequestError(code, message) {
    renderBatchResult(
        {succeeded: 0, failed: 1},
        [{filename: '批量请求', code, message}]
    );
}

function showFileInfo(file, inputElement) {
    // 移除现有的文件信息
    const existingInfo = inputElement.parentNode.querySelector('.file-info');
    if (existingInfo) {
        existingInfo.remove();
    }

    // 创建文件信息显示
    const infoDiv = document.createElement('div');
    infoDiv.className = 'file-info';
    infoDiv.innerHTML = `
        <small>
            <strong>${file.name}</strong> -
            ${(file.size / 1024 / 1024).toFixed(2)} MB -
            修改时间: ${new Date(file.lastModified).toLocaleDateString()}
        </small>
    `;

    inputElement.parentNode.appendChild(infoDiv);
}

function isTextFile(file) {
    const textTypes = [
        'text/plain',
        'text/markdown',
        'text/x-markdown'
    ];

    // 检查 MIME 类型
    if (textTypes.includes(file.type)) {
        return true;
    }

    // 检查文件扩展名
    const textExtensions = ['.md', '.markdown', '.txt'];
    const fileName = file.name.toLowerCase();

    return textExtensions.some(ext => fileName.endsWith(ext));
}

function previewTextFile(file) {
    const reader = new FileReader();

    reader.onload = function(e) {
        const content = e.target.result;

        // 显示预览（限制长度）
        const previewLength = 500;
        const preview = content.length > previewLength
            ? content.substring(0, previewLength) + '...'
            : content;

        showFilePreview(preview, file);
    };

    reader.readAsText(file);
}

function showFilePreview(content, file) {
    const previewDiv = document.createElement('div');
    previewDiv.className = 'file-preview';
    previewDiv.innerHTML = `
        <h4>文件预览</h4>
        <pre>${escapeHtml(content)}</pre>
    `;

    // 替换现有的预览
    const existingPreview = document.querySelector('.file-preview');
    if (existingPreview) {
        existingPreview.replaceWith(previewDiv);
    } else {
        // 添加到合适的位置
        const fileInput = document.querySelector('input[type="file"]');
        if (fileInput) {
            fileInput.parentNode.appendChild(previewDiv);
        }
    }
}

function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };

    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}

/**
 * 初始化键盘快捷键
 */
function initializeKeyboardShortcuts() {
    document.addEventListener('keydown', function(event) {
        // Ctrl/Cmd + Enter 提交表单
        if ((event.ctrlKey || event.metaKey) && event.key === 'Enter') {
            event.preventDefault();
            const submitBtn = document.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.click();
            }
        }

        // Escape 关闭模态框
        if (event.key === 'Escape') {
            const modals = document.querySelectorAll('.modal');
            modals.forEach(modal => {
                modal.style.display = 'none';
            });
        }
    });
}

/**
 * 工具函数
 */

// 显示加载状态
function showLoading(button) {
    const originalText = button.innerHTML;
    button.innerHTML = '<span class="loading"></span> 处理中...';
    button.disabled = true;

    // 保存原始文本以便恢复
    button._originalText = originalText;

    return () => {
        button.innerHTML = button._originalText;
        button.disabled = false;
    };
}

// 格式化文件大小
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// 防抖函数
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// 复制到剪贴板
async function copyToClipboard(text) {
    try {
        await navigator.clipboard.writeText(text);
        return true;
    } catch (err) {
        // 降级方案
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        try {
            document.execCommand('copy');
            return true;
        } catch (fallbackErr) {
            console.error('复制失败:', fallbackErr);
            return false;
        } finally {
            document.body.removeChild(textArea);
        }
    }
}

// 显示消息提示
function showMessage(message, type = 'info') {
    // 创建消息元素
    const messageDiv = document.createElement('div');
    messageDiv.className = `alert alert-${type}`;
    messageDiv.innerHTML = `
        <span class="icon">${getMessageIcon(type)}</span>
        ${message}
    `;

    // 添加到页面
    const container = document.querySelector('.container') || document.body;
    container.insertBefore(messageDiv, container.firstChild);

    // 自动消失
    setTimeout(() => {
        messageDiv.remove();
    }, 5000);
}

function getMessageIcon(type) {
    const icons = {
        'success': '✅',
        'error': '❌',
        'warning': '⚠️',
        'info': 'ℹ️'
    };
    return icons[type] || 'ℹ️';
}

/**
 * 初始化事件监听器
 */
function initializeEventListeners() {
    // Markdown输入变化时自动生成预览 - 添加更长的防抖延迟
    const markdownInput = document.getElementById('markdown-input');
    if (markdownInput) {
        markdownInput.addEventListener('input', debounce(generatePreview, 800)); // 增加到800ms
    }
}

/**
 * 初始化文件上传 - 合并到主初始化函数中
 */

/**
 * 处理文件上传
 */
function handleFileUpload(event) {
    const file = event.target.files[0];
    if (!file) return;

    // 验证文件类型
    if (!isValidFileType(file)) {
        showMessage('请上传 .md, .markdown 或 .txt 文件', 'error');
        return;
    }

    // 验证文件大小
    if (file.size > 16 * 1024 * 1024) {
        showMessage('文件大小不能超过 16MB', 'error');
        return;
    }

    // 读取文件内容
    const reader = new FileReader();
    reader.onload = function(e) {
        const content = e.target.result;
        document.getElementById('markdown-input').value = content;
        generatePreview();
        showMessage(`文件 "${file.name}" 已加载`, 'success');
    };
    reader.readAsText(file);
}

/**
 * 验证文件类型
 */
function isValidFileType(file) {
    const validTypes = ['text/plain', 'text/markdown', 'text/x-markdown'];
    const validExtensions = ['.md', '.markdown', '.txt'];

    // 检查 MIME 类型
    if (validTypes.includes(file.type)) {
        return true;
    }

    // 检查文件扩展名
    const fileName = file.name.toLowerCase();
    return validExtensions.some(ext => fileName.endsWith(ext));
}

/**
 * 清空输入内容
 */
function clearContent() {
    document.getElementById('markdown-input').value = '';
    document.getElementById('preview-content').innerHTML = `
        <div class="preview-placeholder">
            <span class="icon">👁️</span>
            <p>输入 Markdown 内容后将在此处显示预览</p>
        </div>
    `;
    showMessage('内容已清空', 'info');
}

/**
 * 切换预览面板
 */
function togglePreview() {
    const previewPanel = document.getElementById('preview-panel');
    const inputPanel = document.querySelector('.input-panel');

    previewCollapsed = !previewCollapsed;

    if (previewCollapsed) {
        previewPanel.classList.add('collapsed');
        // 让输入框占满宽度
        inputPanel.style.flex = '1';
    } else {
        previewPanel.classList.remove('collapsed');
        // 恢复原来的布局
        inputPanel.style.flex = '1';
    }
}

/**
 * 切换编辑模式和特性模式
 */
function toggleMode() {
    const editorMode = document.getElementById('editor-mode');
    const featuresMode = document.getElementById('features-mode');
    const toggleBtn = document.getElementById('features-toggle');

    if (currentMode === 'editor') {
        // 切换到特性模式
        editorMode.style.display = 'none';
        featuresMode.style.display = 'block';
        currentMode = 'features';

        if (toggleBtn) {
            toggleBtn.innerHTML = '<span class="icon">🚀</span> 开始使用';
        }
    } else {
        // 切换到编辑模式
        featuresMode.style.display = 'none';
        editorMode.style.display = 'block';
        currentMode = 'editor';

        if (toggleBtn) {
            toggleBtn.innerHTML = '<span class="icon">📋</span> 特性介绍';
        }
    }
}

/**
 * 生成实时预览 - 优化版本
 */
function generatePreview() {
    const markdownInput = document.getElementById('markdown-input');
    const previewContent = document.getElementById('preview-content');

    if (!markdownInput || !previewContent) return;

    const content = markdownInput.value.trim();

    if (!content) {
        previewContent.innerHTML = `
            <div class="preview-placeholder">
                <span class="icon">👁️</span>
                <p>输入 Markdown 内容后将在此处显示预览</p>
            </div>
        `;
        return;
    }

    // 显示加载状态
    previewContent.innerHTML = `
        <div class="preview-loading">
            <div class="loading-spinner"></div>
            <p>生成预览中...</p>
        </div>
    `;

    // 发送到后端生成预览 - 添加超时控制
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10秒超时

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
    const previewBody = 'markdown=' + encodeURIComponent(content)
        + (csrfToken ? '&csrf_token=' + encodeURIComponent(csrfToken) : '');

    fetch('/preview', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-CSRFToken': csrfToken,
        },
        body: previewBody,
        signal: controller.signal
    })
    .then(response => {
        clearTimeout(timeoutId);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        return response.text();
    })
    .then(html => {
        // 直接使用返回的HTML片段
        if (html.trim()) {
            previewContent.innerHTML = html;
        } else {
            previewContent.innerHTML = '<div class="preview-placeholder"><span class="icon">👁️</span><p>预览生成失败</p></div>';
        }
    })
    .catch(error => {
        clearTimeout(timeoutId);
        console.error('预览生成失败:', error);

        let errorMessage = '预览生成失败，请稍后重试';
        if (error.name === 'AbortError') {
            errorMessage = '预览生成超时，请重试';
        } else if (error.message.includes('HTTP')) {
            errorMessage = '服务器错误，请稍后重试';
        }

        previewContent.innerHTML = `<div class="preview-error"><span class="icon">❌</span><p>${errorMessage}</p></div>`;
    });
}

/**
 * 更新隐藏的表单字段
 */
function updateHiddenInput() {
    const markdownInput = document.getElementById('markdown-input');
    const hiddenInput = document.getElementById('hidden-markdown');

    if (markdownInput && hiddenInput) {
        hiddenInput.value = markdownInput.value;
    }
}

/**
 * 键盘快捷键
 */
function initializeKeyboardShortcuts() {
    document.addEventListener('keydown', function(event) {
        // Ctrl/Cmd + Enter 提交表单
        if ((event.ctrlKey || event.metaKey) && event.key === 'Enter') {
            event.preventDefault();
            updateHiddenInput();
            const submitBtn = document.querySelector('#convert-form button[type="submit"]');
            if (submitBtn) {
                submitBtn.click();
            }
        }

        // Ctrl/Cmd + Shift + P 切换预览
        if ((event.ctrlKey || event.metaKey) && event.shiftKey && event.key === 'P') {
            event.preventDefault();
            togglePreview();
        }

        // Ctrl/Cmd + Shift + F 切换模式
        if ((event.ctrlKey || event.metaKey) && event.shiftKey && event.key === 'F') {
            event.preventDefault();
            toggleMode();
        }
    });
}

// 导出功能供其他脚本使用
window.MD2DOCX = {
    showLoading,
    formatFileSize,
    debounce,
    copyToClipboard,
    showMessage,
    toggleMode,
    togglePreview,
    generatePreview,
    clearContent
};
