/**
 * Markdown to DOCX Converter - JavaScript 功能
 */

// 页面加载完成后的初始化
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    // 初始化工具提示
    initializeTooltips();

    // 初始化表单验证
    initializeFormValidation();

    // 初始化文件上传预览
    initializeFileUpload();

    // 初始化快捷键
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
    const file = event.target.files[0];
    if (!file) return;

    // 显示文件信息
    showFileInfo(file, event.target);

    // 如果是文本文件，尝试预览内容
    if (isTextFile(file)) {
        previewTextFile(file);
    }
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

// 导出功能供其他脚本使用
window.MD2DOCX = {
    showLoading,
    formatFileSize,
    debounce,
    copyToClipboard,
    showMessage
};
