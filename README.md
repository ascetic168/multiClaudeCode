# Multi Claude Code Window Manager

[正體中文](README.zh-TW.md) | [简体中文](README.zh-CN.md)

Multi Claude Code Window Manager is a PowerShell script that allows you to manage multiple Claude Code instances in separate Windows Terminal windows. Each instance can be configured with different API endpoints, models, and startup prompts.

## Features

- Launch multiple Claude Code instances simultaneously in separate Windows Terminal tabs
- Configure different API endpoints, models, and authentication tokens for each instance
- Inject custom prompts automatically after startup
- Manage configurations through a JSON file
- Support for custom commands (e.g., `claude` or `ccr code`)

## Prerequisites

- Windows 10/11 with Windows Terminal installed
- PowerShell 5.1 or later
- Claude Code application installed and accessible from command line
- Windows Terminal should be installed (comes by default with Windows 11)

## Installation

1. Clone or download this repository
2. Ensure PowerShell execution policy allows running scripts:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. (Optional) Copy `mcc.ps1` to a directory in your PATH environment variable to run it from anywhere:

## Configuration

The script uses a JSON configuration file (by default located at `%APPDATA%\multiClaudeCode\config.json`) to define Claude Code instances.

### Creating a Configuration File

To create a new configuration file:
```powershell
.\mcc.ps1 -Create
```

### Configuration File Format

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

### Configuration Parameters

- `name`: The name of the configuration
- `ANTHROPIC_AUTH_TOKEN`: API key for authentication (optional)
- `ANTHROPIC_BASE_URL`: API endpoint URL (optional)
- `ANTHROPIC_MODEL`: Main model to use (optional)
- `ANTHROPIC_SMALL_FAST_MODEL`: Small/fast model to use (optional)
- `command`: Command to execute (default: `claude`)
- `prompt`: Optional prompt to inject after startup

## Usage

### Show Help

To display help information:
```powershell
.\mcc.ps1 -Help
```

### Start All Configurations

To start all Claude Code instances defined in the configuration file:
```powershell
.\mcc.ps1
```

### Start a Specific Configuration

To start a specific configuration by name:
```powershell
.\mcc.ps1 -Name "Claude-Default"
```

### Switch/Create Branch and Start

To switch to (or create) a git worktree for a branch and start its corresponding configuration:
```powershell
.\mcc.ps1 -Branch "feature-branch"
```
This command streamlines development on different features. It automatically manages a git worktree for the specified branch and then launches the configuration from your `config.json` that has the same name as the branch.

The worktree directory is created using the format `{projectName}_{branchName}` (e.g., `multiClaudeCode_feature-branch`) to avoid conflicts between different projects with the same branch names.

### Start by Index

To start a configuration by its index (1-based):
```powershell
.\mcc.ps1 -U 1
```

### List Configurations

To list all available configurations:
```powershell
.\mcc.ps1 -List
```

### Edit Configuration

To edit the configuration file:
```powershell
.\mcc.ps1 -Edit
```

### Create New Configuration

To create a new configuration file:
```powershell
.\mcc.ps1 -Create
```

### Specify Custom Configuration File

To use a custom configuration file path:
```powershell
.\mcc.ps1 -Config "C:\path\to\your\config.json"
```

## Examples

1. Show help information:
   ```powershell
   .\mcc.ps1 -Help
   ```

2. Start all configurations:
   ```powershell
   .\mcc.ps1
   ```

3. Start a specific configuration:
   ```powershell
   .\mcc.ps1 -Name "Claude-Default"
   ```

4. List all configurations:
   ```powershell
   .\mcc.ps1 -List
   ```

## Author

Charlie Chu (朱國棟) - charliechu1688@gmail.com

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.