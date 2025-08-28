# Multi Claude Code 窗口管理器

[English](README.md) | [繁體中文](README.zh-TW.md)

Multi Claude Code 窗口管理器是一个 PowerShell 脚本，可让您在独立的 Windows Terminal 窗口中管理多个 Claude Code 实例。每个实例都可以配置不同的 API 端点、模型和启动提示。

## 功能特色

- 在独立的 Windows Terminal 标签页中同时启动多个 Claude Code 实例
- 为每个实例配置不同的 API 端点、模型和认证令牌
- 启动后自动注入自定义提示
- 通过 JSON 文件管理配置
- 支持自定义命令（例如 `claude` 或 `ccr code`）

## 系统需求

- 安装了 Windows Terminal 的 Windows 10/11
- PowerShell 5.1 或更新版本
- 已安装 Claude Code 应用程序且可从命令行访问
- 应安装 Windows Terminal（Windows 11 默认包含）

## 安装方式

1. 克隆或下载此仓库
2. 确保 PowerShell 执行策略允许运行脚本：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. （可选）将 `mcc.ps1` 复制到 PATH 环境变量中有指向到的目录，这样就可以在任意地方执行它：

## 配置说明

脚本使用 JSON 配置文件（默认位于 `%APPDATA%\multiClaudeCode\config.json`）来定义 Claude Code 实例。

### 创建配置文件

创建新的配置文件：
```powershell
.\mcc.ps1 -Create
```

### 配置文件格式

```json
{
  "configurations": [
    {
      "name": "Claude-Default",
      "ANTHROPIC_AUTH_TOKEN": "your-api-key-here",
      "ANTHROPIC_BASE_URL": "https://api.anthropic.com",
      "ANTHROPIC_MODEL": "claude-3-5-sonnet-20241022",
      "ANTHROPIC_SMALL_FAST_MODEL": "claude-3-haiku-20240307",
      "command": "claude",
      "prompt": "You will do nothing until an exactly command, and will always response in Chinese."
    }
  ]
}
```

### 配置参数说明

- `name`：配置名称
- `ANTHROPIC_AUTH_TOKEN`：用于认证的 API 密钥（可选）
- `ANTHROPIC_BASE_URL`：API 端点 URL（可选）
- `ANTHROPIC_MODEL`：要使用的主模型（可选）
- `ANTHROPIC_SMALL_FAST_MODEL`：要使用的小型/快速模型（可选）
- `command`：要执行的命令（默认：`claude`）
- `prompt`：启动后要注入的可选提示

## 使用方式

### 显示说明

显示说明信息：
```powershell
.\mcc.ps1 -Help
```

### 启动所有配置

启动配置文件中定义的所有 Claude Code 实例：
```powershell
.\mcc.ps1
```

### 启动特定配置

按名称启动特定配置：
```powershell
.\mcc.ps1 -Name "Claude-Default"
```

### 按索引启动

按索引（从 1 开始）启动配置：
```powershell
.\mcc.ps1 -U 1
```

### 列出配置

列出所有可用配置：
```powershell
.\mcc.ps1 -List
```

### 编辑配置

编辑配置文件：
```powershell
.\mcc.ps1 -Edit
```

### 创建新配置

创建新的配置文件：
```powershell
.\mcc.ps1 -Create
```

### 指定自定义配置文件

使用自定义配置文件路径：
```powershell
.\mcc.ps1 -Config "C:\path\to\your\config.json"
```

## 使用示例

1. 显示说明信息：
   ```powershell
   .\mcc.ps1 -Help
   ```

2. 启动所有配置：
   ```powershell
   .\mcc.ps1
   ```

3. 启动特定配置：
   ```powershell
   .\mcc.ps1 -Name "Claude-Default"
   ```

4. 列出所有配置：
   ```powershell
   .\mcc.ps1 -List
   ```

## 作者

Charlie Chu (朱国栋) - charliechu1688@gmail.com

## 授权

本项目采用 MIT 授权条款 - 详情请见 [LICENSE](LICENSE) 文件。