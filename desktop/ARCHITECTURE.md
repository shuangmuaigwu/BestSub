# BestSub 桌面应用架构说明

## 概述

BestSub 桌面应用使用 Tauri 框架构建，将原有的 Web 应用封装成原生桌面应用。Tauri 是一个轻量级的桌面应用框架，使用 Rust 构建后端，支持使用任何前端框架。

## 架构组件

### 1. Tauri Shell (Rust)
- **位置**: `desktop/src-tauri/src/main.rs`
- **功能**: 
  - 创建应用窗口
  - 管理 Go 后端进程
  - 提供系统级 API
- **技术**: Rust + Tauri 2.x

### 2. Go 后端服务
- **位置**: 项目根目录的 `cmd/bestsub`
- **功能**: 
  - 提供 HTTP API
  - 处理订阅转换逻辑
  - 管理数据库
- **端口**: 默认 8080
- **启动方式**: 作为子进程由 Tauri 管理

### 3. 前端界面
- **位置**: `desktop/src/`
- **功能**: 
  - 加载和显示后端 Web UI
  - 处理启动状态和错误提示
  - 通过 iframe 嵌入后端界面
- **技术**: HTML + JavaScript

## 工作流程

```
用户启动应用
    ↓
Tauri 窗口创建
    ↓
启动 Go 后端进程 (端口 8080)
    ↓
前端轮询检查后端就绪
    ↓
iframe 加载 http://127.0.0.1:8080
    ↓
显示 BestSub Web UI
```

## 目录结构

```
desktop/
├── src/                       # 前端源码
│   ├── index.html            # 主 HTML (加载器)
│   └── main.js               # 启动逻辑
├── src-tauri/                # Tauri Rust 项目
│   ├── src/
│   │   └── main.rs          # Rust 主程序
│   ├── icons/               # 应用图标
│   ├── Cargo.toml           # Rust 依赖
│   ├── tauri.conf.json      # Tauri 配置
│   └── build.rs             # 构建脚本
├── package.json             # Node.js 配置
├── build.sh                 # Linux/macOS 构建脚本
├── build.bat                # Windows 构建脚本
├── dev.sh                   # 开发模式启动脚本
└── README.md                # 使用文档
```

## 配置文件说明

### tauri.conf.json

关键配置项：

```json
{
  "bundle": {
    "resources": {
      "../bestsub": "./"  // 将 Go 二进制文件打包为资源
    }
  },
  "app": {
    "windows": [{
      "width": 1200,    // 窗口宽度
      "height": 800,    // 窗口高度
      "minWidth": 800,  // 最小宽度
      "minHeight": 600  // 最小高度
    }]
  }
}
```

### package.json

NPM 脚本：
- `npm run dev`: 开发模式
- `npm run build`: 构建生产版本

## 开发模式

### 启动开发环境

```bash
cd desktop
npm run dev
```

开发模式下：
- 支持热重载
- 自动打开开发者工具
- 实时查看日志

### 调试技巧

1. **查看 Rust 日志**:
   ```bash
   # 设置环境变量启用详细日志
   RUST_LOG=debug npm run dev
   ```

2. **查看 Go 后端日志**:
   - 日志文件位于项目根目录的 `log/` 文件夹

3. **浏览器开发者工具**:
   - 在开发模式下自动打开
   - 可以调试前端 JavaScript 代码

## 生产构建

### 构建流程

1. **构建 Go 后端**:
   ```bash
   cd /path/to/BestSub
   go build -o bestsub ./cmd/bestsub
   cp bestsub desktop/
   ```

2. **构建 Tauri 应用**:
   ```bash
   cd desktop
   npm run build
   ```

### 构建产物

构建完成后，安装包位于 `desktop/src-tauri/target/release/bundle/`:

- **Windows**: `msi/*.msi`
- **macOS**: `dmg/*.dmg`
- **Linux**: 
  - `deb/*.deb`
  - `appimage/*.AppImage`

## 自定义配置

### 修改端口

如果需要修改后端端口（默认 8080）：

1. 修改后端配置文件 `config.json`:
   ```json
   {
     "server": {
       "port": 9090  // 修改为新端口
     }
   }
   ```

2. 修改前端代码 `desktop/src/main.js`:
   ```javascript
   const SERVER_PORT = 9090;  // 修改为新端口
   ```

### 自定义窗口大小

修改 `desktop/src-tauri/tauri.conf.json`:

```json
{
  "app": {
    "windows": [{
      "width": 1600,     // 自定义宽度
      "height": 1000,    // 自定义高度
      "minWidth": 1000,  // 自定义最小宽度
      "minHeight": 700   // 自定义最小高度
    }]
  }
}
```

### 更换应用图标

1. 准备一个 1024x1024 的 PNG 或 SVG 图标
2. 运行图标生成命令:
   ```bash
   cd desktop
   npx @tauri-apps/cli icon /path/to/your/icon.png
   ```

## 常见问题

### Q1: 后端进程没有自动启动

**原因**: 二进制文件路径不正确或权限不足

**解决**:
1. 确认 `bestsub` 文件在 `desktop/` 目录下
2. 检查文件执行权限: `chmod +x desktop/bestsub`
3. 查看 Tauri 日志确认具体错误

### Q2: 端口被占用

**现象**: 应用启动后一直显示"启动中"

**解决**:
1. 检查端口 8080 是否被占用:
   ```bash
   # Linux/macOS
   lsof -i :8080
   
   # Windows
   netstat -ano | findstr :8080
   ```
2. 关闭占用端口的进程或修改配置使用其他端口

### Q3: 构建失败

**Linux 相关错误**:
```bash
sudo apt install libwebkit2gtk-4.1-dev \
  build-essential \
  libssl-dev \
  libayatana-appindicator3-dev
```

**Windows 相关错误**:
- 安装 Visual Studio Build Tools
- 安装 WebView2 Runtime

### Q4: 窗口显示空白

**原因**: 后端服务未能成功启动或前端无法连接

**调试步骤**:
1. 手动启动 Go 后端测试: `./bestsub`
2. 在浏览器访问 `http://localhost:8080` 确认服务正常
3. 检查防火墙设置

## 性能优化

### 减小应用体积

1. **Go 后端**:
   ```bash
   # 使用 -ldflags 减小二进制大小
   go build -ldflags="-s -w" -o bestsub ./cmd/bestsub
   ```

2. **使用 UPX 压缩** (可选):
   ```bash
   upx --best --lzma bestsub
   ```

### 启动速度优化

1. 预编译后端
2. 优化资源加载
3. 使用更快的轮询间隔（权衡准确性）

## 发布清单

发布前检查：

- [ ] 更新版本号（package.json, tauri.conf.json, Cargo.toml）
- [ ] 测试所有目标平台
- [ ] 更新 CHANGELOG
- [ ] 准备发布说明
- [ ] 生成应用签名（Windows 和 macOS）
- [ ] 测试安装包

## 技术栈

- **Tauri**: 2.2.x
- **Rust**: 1.70+
- **Go**: 1.24+
- **Node.js**: 16+

## 参考资源

- [Tauri 官方文档](https://tauri.app/v2/guides/)
- [BestSub 主项目](https://github.com/bestruirui/BestSub)
- [Tauri API 参考](https://tauri.app/v2/api/js/)
