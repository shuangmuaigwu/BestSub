const SERVER_PORT = 8080;
const SERVER_URL = `http://127.0.0.1:${SERVER_PORT}`;
const MAX_RETRY_ATTEMPTS = 30;
const RETRY_INTERVAL = 1000; // 1 second

let retryCount = 0;

async function checkServerHealth() {
    try {
        // Try to fetch the root page first
        const response = await fetch(`${SERVER_URL}`, {
            method: 'GET',
            mode: 'no-cors'
        });
        return true;
    } catch (error) {
        console.log('Server check failed:', error.message);
        return false;
    }
}

async function waitForServer() {
    console.log('等待后端服务启动...');
    
    while (retryCount < MAX_RETRY_ATTEMPTS) {
        const isHealthy = await checkServerHealth();
        
        if (isHealthy) {
            console.log('后端服务已就绪');
            return true;
        }
        
        retryCount++;
        console.log(`重试 ${retryCount}/${MAX_RETRY_ATTEMPTS}...`);
        await new Promise(resolve => setTimeout(resolve, RETRY_INTERVAL));
    }
    
    return false;
}

async function loadWebUI() {
    const loading = document.getElementById('loading');
    const error = document.getElementById('error');
    const errorMessage = document.getElementById('error-message');
    const container = document.getElementById('webview-container');
    
    try {
        const serverReady = await waitForServer();
        
        if (!serverReady) {
            throw new Error('后端服务启动超时。请检查:\n1. 端口 8080 是否被占用\n2. 是否有足够的权限运行程序\n3. 查看日志文件了解详细信息');
        }
        
        // 创建 iframe 加载 Web UI
        const iframe = document.createElement('iframe');
        iframe.src = SERVER_URL;
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.border = 'none';
        
        iframe.onload = () => {
            console.log('Web UI loaded successfully');
            loading.classList.add('hidden');
        };
        
        iframe.onerror = () => {
            throw new Error('无法加载 Web UI');
        };
        
        container.appendChild(iframe);
        
    } catch (err) {
        console.error('启动失败:', err);
        loading.classList.add('hidden');
        error.classList.add('show');
        errorMessage.textContent = err.message;
    }
}

// 当页面加载完成后，开始加载 Web UI
document.addEventListener('DOMContentLoaded', loadWebUI);
