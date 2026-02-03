# BestSub 桌面应用

这是 BestSub 的桌面版本，使用 Tauri 框架构建。

## 系统要求

在构建桌面应用之前，请确保已安装以下依赖：

### 通用要求
- Node.js (>= 16)
- Rust (>= 1.70)
- Go (>= 1.24) - 用于构建后端

### Linux 额外要求
```bash
sudo apt update
sudo apt install libwebkit2gtk-4.1-dev \
  build-essential \
  curl \
  wget \
  file \
  libssl-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev
```

### macOS 额外要求
```bash
xcode-select --install
```

### Windows 额外要求
- 安装 Microsoft Visual Studio C++ Build Tools
- 安装 WebView2 (Windows 10/11 通常已预装)

## 构建步骤

### 1. 构建 Go 后端

首先，需要构建 BestSub 的 Go 后端：

```bash
# 在项目根目录下
cd /path/to/BestSub
go build -o bestsub ./cmd/bestsub
```

在 Windows 上：
```bash
go build -o bestsub.exe ./cmd/bestsub
```

### 2. 将后端二进制文件复制到 desktop 目录

```bash
# Linux/macOS
cp bestsub desktop/

# Windows
copy bestsub.exe desktop\
```

### 3. 安装 Node 依赖

```bash
cd desktop
npm install
```

### 4. 开发模式运行

在开发模式下，可以快速测试应用：

```bash
npm run dev
```

注意：开发模式下，需要确保 Go 后端已经在运行。

### 5. 构建生产版本

构建完整的桌面应用安装包：

```bash
npm run build
```

构建完成后，安装包将位于 `desktop/src-tauri/target/release/bundle/` 目录下。

## 目录结构

```
desktop/
├── src/                    # 前端资源
│   ├── index.html         # 主 HTML 文件
│   └── main.js            # 主 JavaScript 文件
├── src-tauri/             # Tauri Rust 代码
│   ├── src/
│   │   └── main.rs        # Rust 主文件
│   ├── icons/             # 应用图标
│   ├── Cargo.toml         # Rust 依赖配置
│   └── tauri.conf.json    # Tauri 配置文件
├── package.json           # Node.js 依赖配置
└── README.md             # 本文件
```

## 配置说明

### 端口配置

默认情况下，BestSub 后端服务运行在 `8080` 端口。如果需要修改端口，请：

1. 修改后端的配置文件 `config.json`
2. 修改 `desktop/src/main.js` 中的 `SERVER_PORT` 常量

### 应用图标

应用图标位于 `desktop/src-tauri/icons/` 目录。如果需要自定义图标：

1. 准备一个 512x512 或更大的 PNG/SVG 图标
2. 运行以下命令生成所有需要的图标：

```bash
cd desktop
npx @tauri-apps/cli icon path/to/your/icon.png
```

## 常见问题

### 1. 构建失败：找不到 webkit2gtk

在 Linux 上，确保已安装 webkit2gtk 开发库：

```bash
sudo apt install libwebkit2gtk-4.1-dev
```

### 2. 后端服务无法启动

确保：
- Go 后端已正确编译
- 二进制文件已复制到 `desktop/` 目录
- 端口 8080 未被占用

### 3. Windows 上构建失败

确保已安装：
- Microsoft Visual Studio C++ Build Tools
- WebView2 Runtime

### 4. 图标显示不正确

重新生成图标：

```bash
cd desktop
npx @tauri-apps/cli icon src-tauri/icons/icon.svg
```

## 发布

构建完成后，可以在以下位置找到安装包：

- **Windows**: `desktop/src-tauri/target/release/bundle/msi/BestSub_1.0.0_x64_en-US.msi`
- **macOS**: `desktop/src-tauri/target/release/bundle/dmg/BestSub_1.0.0_x64.dmg`
- **Linux**:
  - DEB: `desktop/src-tauri/target/release/bundle/deb/bestsub_1.0.0_amd64.deb`
  - AppImage: `desktop/src-tauri/target/release/bundle/appimage/bestsub_1.0.0_amd64.AppImage`

## 许可证

与 BestSub 主项目相同的许可证。
