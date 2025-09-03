# Multi Claude Code 視窗管理器

[English](README.md) | [简体中文](README.zh-CN.md)

Multi Claude Code 視窗管理器是一個 PowerShell 指令碼，可讓您在獨立的 Windows Terminal 視窗中管理多個 Claude Code 執行個體。每個執行個體都可以設定不同的 API 端點、模型和啟動提示。

## 功能特色

- 在獨立的 Windows Terminal 分頁中同時啟動多個 Claude Code 執行個體
- 為每個執行個體設定不同的 API 端點、模型和驗證金鑰
- 啟動後自動注入自訂提示
- 透過 JSON 檔案管理設定
- 支援自訂指令（例如 `claude` 或 `ccr code`）

## 系統需求

- 安裝了 Windows Terminal 的 Windows 10/11
- PowerShell 5.1 或更新版本
- 已安裝 Claude Code 應用程式且可從命令列存取
- 應安裝 Windows Terminal（Windows 11 預設包含）

## 安裝方式

1. 複製或下載此儲存庫
2. 確保 PowerShell 執行原則允許執行指令碼：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. （可選）將 `mcc.ps1` 複製到 PATH 環境變數中的目錄，以便從任何位置執行：

## 設定說明

指令碼使用 JSON 設定檔（預設位於 `%APPDATA%\multiClaudeCode\config.json`）來定義 Claude Code 執行個體。

### 建立設定檔

建立新的設定檔：
```powershell
.\mcc.ps1 -Create
```

### 設定檔格式

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

### 設定參數說明

- `name`：設定名稱
- `ANTHROPIC_AUTH_TOKEN`：用於驗證的 API 金鑰（可選）
- `ANTHROPIC_BASE_URL`：API 端點 URL（可選）
- `ANTHROPIC_MODEL`：要使用的主模型（可選）
- `ANTHROPIC_SMALL_FAST_MODEL`：要使用的小型/快速模型（可選）
- `command`：要執行的指令（預設：`claude`）
- `prompt`：啟動後要注入的可選提示

## 使用方式

### 顯示說明

顯示說明資訊：
```powershell
.\mcc.ps1 -Help
```

### 啟動所有設定

啟動設定檔中定義的所有 Claude Code 執行個體：
```powershell
.\mcc.ps1
```

### 啟動特定設定

按名稱啟動特定設定：
```powershell
.\mcc.ps1 -Name "Claude-Default"
```

### 切換/建立分支並啟動

切換到（或建立）一個 git worktree 分支並啟動其對應的設定：
```powershell
.\mcc.ps1 -Branch "feature-branch"
```
此指令透過自動管理指定分支的 git worktree，然後啟動 `config.json` 中具有相同名稱的設定，從而簡化不同功能的開發流程。

worktree 目錄使用 `{專案名稱}_{分支名稱}` 格式建立（例如 `multiClaudeCode_feature-branch`），以避免不同專案中相同分支名稱的衝突。

### 按索引啟動

按索引（從 1 開始）啟動設定：
```powershell
.\mcc.ps1 -U 1
```

### 列出設定

列出所有可用設定：
```powershell
.\mcc.ps1 -List
```

### 編輯設定

編輯設定檔：
```powershell
.\mcc.ps1 -Edit
```

### 建立新設定

建立新的設定檔：
```powershell
.\mcc.ps1 -Create
```

### 指定自訂設定檔

使用自訂設定檔路徑：
```powershell
.\mcc.ps1 -Config "C:\path\to\your\config.json"
```

## 使用範例

1. 顯示說明資訊：
   ```powershell
   .\mcc.ps1 -Help
   ```

2. 啟動所有設定：
   ```powershell
   .\mcc.ps1
   ```

3. 啟動特定設定：
   ```powershell
   .\mcc.ps1 -Name "Claude-Default"
   ```

4. 列出所有設定：
   ```powershell
   .\mcc.ps1 -List
   ```

## 作者

Charlie Chu (朱國棟) - charliechu1688@gmail.com

## 授權

本專案採用 MIT 授權條款 - 詳情請見 [LICENSE](LICENSE) 檔案。