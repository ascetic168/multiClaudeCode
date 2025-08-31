param(
    [switch]$Help,
    [switch]$List,
    [switch]$Edit,
    [switch]$Create,
    [string]$Config,
    [string]$Branch,
    [string]$Name,
    [int]$U
)

$defaultConfigPath = "$env:APPDATA\multiClaudeCode\config.json"

function Show-Help {
    Write-Host "mcc - Multi Claude Code Window Manager"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\mcc.ps1                          Start all configurations (default)"
    Write-Host "  .\mcc.ps1 -Help                    Show help information"
    Write-Host "  .\mcc.ps1 -List                    List all available configurations"
    Write-Host "  .\mcc.ps1 -Edit                    Edit configuration file"
    Write-Host "  .\mcc.ps1 -Create                  Create new configuration file"
    Write-Host "  .\mcc.ps1 -Config [path]           Specify configuration file path"
    Write-Host "  .\mcc.ps1 -Branch [name]           Switch/create worktree and execute specified configuration"
    Write-Host "  .\mcc.ps1 -Name [name]             Execute specified configuration"
    Write-Host "  .\mcc.ps1 -U [index]               Execute configuration by index (1-based)"
    Write-Host ""
    Write-Host "Configuration file format:"
    Write-Host "  The configuration file (config.json) contains an array of configurations."
    Write-Host "  Each configuration supports the following properties:"
    Write-Host "    - name: Window title"
    Write-Host "    - ANTHROPIC_AUTH_TOKEN: API key"
    Write-Host "    - ANTHROPIC_BASE_URL: API endpoint"
    Write-Host "    - ANTHROPIC_MODEL: Model name"
    Write-Host "    - ANTHROPIC_SMALL_FAST_MODEL: Small/fast model name"
    Write-Host "    - command: Command to execute (default: 'claude')"
    Write-Host "    - prompt: Optional prompt to inject after startup"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\mcc.ps1                          # Start all configurations"
    Write-Host "  .\mcc.ps1 -Name 'Claude-Default'   # Start specific configuration"
    Write-Host "  .\mcc.ps1 -U 2                      # Start second configuration by index"
    Write-Host "  .\mcc.ps1 -Config 'C:\my-config.json' -Name 'Custom'"
}

function Get-ConfigPath {
    param([string]$CustomPath)
    if ($CustomPath) {
        return $CustomPath
    }
    return $defaultConfigPath
}

function Ensure-ConfigDirectory {
    param([string]$ConfigPath)
    $configDir = Split-Path -Parent $ConfigPath
    if (!(Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
}

function Test-ConfigExists {
    param([string]$ConfigPath)
    return Test-Path $ConfigPath
}

function Get-DefaultConfig {
    return @{
        configurations = @(
            @{
                name = "Claude-Default"
                ANTHROPIC_AUTH_TOKEN = ""
                ANTHROPIC_BASE_URL = ""
                ANTHROPIC_MODEL = ""
                ANTHROPIC_SMALL_FAST_MODEL = ""
                command = "claude"
                prompt = "Do nothing until I give further instructions. Always respond in Chinese."
            },
            @{
                name = "DeepSeek-Default"
                ANTHROPIC_AUTH_TOKEN = "your-api-key-here"
                ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic"
                ANTHROPIC_MODEL = "deepseek-chat"
                ANTHROPIC_SMALL_FAST_MODEL = "deepseek-chat"
                command = "claude"
                prompt = "Review project, give a short summary. Always respond in Chinese."
            }
        )
    }
}

function Create-Config {
    param([string]$ConfigPath)
    
    Ensure-ConfigDirectory -ConfigPath $ConfigPath
    
    if (Test-ConfigExists -ConfigPath $ConfigPath) {
        $response = Read-Host "Configuration file exists. Overwrite? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Operation cancelled"
            return
        }
    }
    
    $defaultConfig = Get-DefaultConfig
    $configJson = $defaultConfig | ConvertTo-Json -Depth 3
    Set-Content -Path $ConfigPath -Value $configJson -Encoding UTF8
    
    Write-Host "Configuration file created: $ConfigPath"
}

function Read-Config {
    param([string]$ConfigPath)
    
    if (!(Test-ConfigExists -ConfigPath $ConfigPath)) {
        Write-Host "Configuration file not found: $ConfigPath"
        Write-Host "Creating default configuration..."
        Create-Config -ConfigPath $ConfigPath
        Write-Host "Please edit the configuration file to add your API keys."
        return $null
    }
    
    try {
        $configContent = Get-Content -Path $ConfigPath -Raw -Encoding UTF8
        return $configContent | ConvertFrom-Json
    }
    catch {
        Write-Error "Cannot read configuration file: $($_.Exception.Message)"
        return $null
    }
}

function Show-ConfigList {
    param([string]$ConfigPath)
    
    $config = Read-Config -ConfigPath $ConfigPath
    if ($null -eq $config) {
        return
    }
    
    Write-Host "Available configurations:"
    Write-Host "Configuration file path: $ConfigPath"
    Write-Host ""
    
    foreach ($conf in $config.configurations) {
        Write-Host "Name: $($conf.name)"
        Write-Host "  Model: $($conf.ANTHROPIC_MODEL)"
        Write-Host "  API Endpoint: $($conf.ANTHROPIC_BASE_URL)"
        if ($conf.prompt) {
            $promptPreview = $conf.prompt.Substring(0, [Math]::Min(50, $conf.prompt.Length))
            Write-Host "  Default Prompt: $promptPreview..."
        }
        Write-Host ""
    }
}

function Edit-Config {
    param([string]$ConfigPath)
    
    if (!(Test-ConfigExists -ConfigPath $ConfigPath)) {
        Write-Host "Configuration file not found. Creating new one..."
        Create-Config -ConfigPath $ConfigPath
    }
    
    # Try to use VS Code first, then notepad as fallback
    if (Get-Command "code" -ErrorAction SilentlyContinue) {
        Start-Process -FilePath "code" -ArgumentList $ConfigPath -Wait
    } else {
        Start-Process -FilePath "notepad.exe" -ArgumentList $ConfigPath -Wait
    }
}

function Start-ClaudeWindow {
    param($Configuration)
    
    try {
        Write-Host "Starting window: $($Configuration.name)"
        
        # Create a temporary script file to avoid quoting issues
        $tempScript = "$env:TEMP\claude_start_$([guid]::NewGuid().ToString().Substring(0,8)).ps1"
        
        # Use the command from configuration or default to 'claude'
        $commandToExecute = if ($Configuration.command) { $Configuration.command } else { "claude" }
        
        $scriptContent = @"
Import-Module PSReadLine -ErrorAction SilentlyContinue
Set-Location '$((Get-Location).Path)'
$(if ($Configuration.ANTHROPIC_AUTH_TOKEN) { "`$env:ANTHROPIC_AUTH_TOKEN = '$($Configuration.ANTHROPIC_AUTH_TOKEN)'" })
$(if ($Configuration.ANTHROPIC_BASE_URL) { "`$env:ANTHROPIC_BASE_URL = '$($Configuration.ANTHROPIC_BASE_URL)'" })
$(if ($Configuration.ANTHROPIC_MODEL) { "`$env:ANTHROPIC_MODEL = '$($Configuration.ANTHROPIC_MODEL)'" })
$(if ($Configuration.ANTHROPIC_SMALL_FAST_MODEL) { "`$env:ANTHROPIC_SMALL_FAST_MODEL = '$($Configuration.ANTHROPIC_SMALL_FAST_MODEL)'" })
cls
$commandToExecute
"@
        
        Set-Content -Path $tempScript -Value $scriptContent -Encoding UTF8
        
        # Start Windows Terminal with the temporary script and bypass execution policy
        # Use -w 0 parameter to target the first window
        Start-Process -FilePath "wt.exe" -ArgumentList "-w", "0", "new-tab", "--title", $Configuration.name, "powershell.exe", "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $tempScript
        
        if ($Configuration.prompt) {
            Start-Sleep -Seconds 1
            Send-Prompt -Prompt $Configuration.prompt
            # Clean up temp script after a delay
            Start-Job -ScriptBlock { 
                param($scriptPath)
                Start-Sleep -Seconds 10
                Remove-Item $scriptPath -ErrorAction SilentlyContinue
            } -ArgumentList $tempScript | Out-Null
        } else {
            # Clean up temp script after a delay
            Start-Job -ScriptBlock { 
                param($scriptPath)
                Start-Sleep -Seconds 10
                Remove-Item $scriptPath -ErrorAction SilentlyContinue
            } -ArgumentList $tempScript | Out-Null
        }
        
        Write-Host "Window started: $($Configuration.name)"
    }
    catch {
        Write-Error "Error starting window: $($_.Exception.Message)"
    }
}

function Send-Prompt {
    param([string]$Prompt)
    
    try {
        # Use clipboard to avoid encoding issues with SendKeys
        Set-Clipboard -Value $Prompt
        
        Add-Type -AssemblyName System.Windows.Forms
        Start-Sleep -Seconds 2
        
        # Send Ctrl+V to paste from clipboard
        [System.Windows.Forms.SendKeys]::SendWait('^v')
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        
        Write-Host "Prompt injected via clipboard"
    }
    catch {
        Write-Warning "Cannot inject prompt: $($_.Exception.Message)"
    }
}

function Start-Configuration {
    param([string]$ConfigPath, [string]$ConfigName)
    
    $config = Read-Config -ConfigPath $ConfigPath
    if ($null -eq $config) {
        return
    }
    
    $targetConfig = $config.configurations | Where-Object { $_.name -eq $ConfigName }
    if ($null -eq $targetConfig) {
        Write-Error "Configuration not found: '$ConfigName'"
        Write-Host "Available configurations:"
        foreach ($conf in $config.configurations) {
            Write-Host "  - $($conf.name)"
        }
        return
    }
    
    Start-ClaudeWindow -Configuration $targetConfig
}

function Start-ConfigurationByIndex {
    param([string]$ConfigPath, [int]$Index)
    
    $config = Read-Config -ConfigPath $ConfigPath
    if ($null -eq $config) {
        return
    }
    
    if ($Index -lt 1 -or $Index -gt $config.configurations.Count) {
        Write-Error "Index out of range: $Index (valid range: 1-$($config.configurations.Count))"
        Write-Host "Available configurations:"
        for ($i = 0; $i -lt $config.configurations.Count; $i++) {
            Write-Host "  $($i + 1)) $($config.configurations[$i].name)"
        }
        return
    }
    
    $targetConfig = $config.configurations[$Index - 1]
    Start-ClaudeWindow -Configuration $targetConfig
}

function Start-AllConfigurations {
    param([string]$ConfigPath)
    
    $config = Read-Config -ConfigPath $ConfigPath
    if ($null -eq $config) {
        return
    }
    
    Write-Host "Starting all configurations..."
    Write-Host ""
    
    foreach ($conf in $config.configurations) {
        Write-Host "Starting: $($conf.name)"
        Start-ClaudeWindow -Configuration $conf
        Start-Sleep -Seconds 1  # Small delay between windows
    }
    
    Write-Host ""
    Write-Host "All windows started successfully!"
}

# Main logic
$configPath = Get-ConfigPath -CustomPath $Config

if ($Help) {
    Show-Help
}
elseif ($List) {
    if (!(Test-ConfigExists -ConfigPath $configPath)) {
        Write-Host "Configuration file not found. Creating default configuration..."
        Create-Config -ConfigPath $configPath
        Write-Host "Configuration created. Opening for editing..."
        Edit-Config -ConfigPath $configPath
    } else {
        Show-ConfigList -ConfigPath $configPath
    }
}
elseif ($Edit) {
    Edit-Config -ConfigPath $configPath
}
elseif ($Create) {
    Create-Config -ConfigPath $configPath
}
elseif ($Branch) {
    $worktreePath = Join-Path (Get-Location).Path "..\$Branch"
    
    if (Test-Path $worktreePath) {
        Write-Host "Directory for branch '$Branch' exists. Switching..."
        try {
            Set-Location $worktreePath
            Write-Host "Switched to directory: $(Get-Location)"
            git switch $Branch
        } catch {
            Write-Error "Failed to switch to worktree or branch '$Branch'. Error: $_"
            return
        }
    } else {
        Write-Host "Directory '$worktreePath' not found."
        
        # Prune stale worktrees first to prevent errors from leftover git metadata.
        Write-Host "Running 'git worktree prune' to clean up stale references..."
        try {
            git worktree prune
        } catch {
            Write-Warning "Could not run 'git worktree prune'. This may cause issues if there are stale worktree references. Error: $_"
        }

        # Check if branch exists, suppressing command output
        git rev-parse --verify --quiet $Branch *> $null 2> $null
        
        if ($LASTEXITCODE -eq 0) {
            # Branch exists, but directory doesn't. Create worktree from existing branch.
            Write-Host "Branch '$Branch' already exists. Creating worktree from existing branch..."
            try {
                git worktree add ../$Branch $Branch
                Set-Location ../$Branch
                Write-Host "Successfully created and switched to new worktree: $(Get-Location)"
            } catch {
                Write-Error "Failed to create worktree from existing branch '$Branch'. Error: $_"
                return
            }
        } else {
            # Branch does not exist. Create a new branch and worktree.
            Write-Host "Branch '$Branch' not found. Creating new branch and git worktree..."
            try {
                git worktree add -B $Branch ../$Branch
                Set-Location ../$Branch
                Write-Host "Successfully created and switched to new worktree: $(Get-Location)"
            } catch {
                Write-Error "Failed to create worktree and new branch '$Branch'. Error: $_"
                return
            }
        }
    }

    # After switching to the worktree, execute the equivalent of the -Name logic
    $currentConfigPath = Get-ConfigPath -CustomPath $Config # Re-evaluate config path after changing directory
    if (!(Test-ConfigExists -ConfigPath $currentConfigPath)) {
        Write-Host "Configuration file not found. Creating default configuration..."
        Create-Config -ConfigPath $currentConfigPath
        Write-Host "Configuration created. Please edit the file to add your API keys and then run the command again."
        Edit-Config -ConfigPath $currentConfigPath
    } else {
        Start-Configuration -ConfigPath $currentConfigPath -ConfigName $Branch
    }
}
elseif ($Name) {
    if (!(Test-ConfigExists -ConfigPath $configPath)) {
        Write-Host "Configuration file not found. Creating default configuration..."
        Create-Config -ConfigPath $configPath
        Write-Host "Configuration created. Please edit the file to add your API keys and then run the command again."
        Edit-Config -ConfigPath $configPath
    } else {
        Start-Configuration -ConfigPath $configPath -ConfigName $Name
    }
}
elseif ($U) {
    if (!(Test-ConfigExists -ConfigPath $configPath)) {
        Write-Host "Configuration file not found. Creating default configuration..."
        Create-Config -ConfigPath $configPath
        Write-Host "Configuration created. Please edit the file to add your API keys and then run the command again."
        Edit-Config -ConfigPath $configPath
    } else {
        Start-ConfigurationByIndex -ConfigPath $configPath -Index $U
    }
}
else {
    # No specific parameters - start all configurations
    if (!(Test-ConfigExists -ConfigPath $configPath)) {
        Write-Host "Configuration file not found. Creating default configuration..."
        Create-Config -ConfigPath $configPath
        Write-Host "Configuration created. Please edit the file to add your API keys and then run the command again."
        Edit-Config -ConfigPath $configPath
    } else {
        Start-AllConfigurations -ConfigPath $configPath
    }
}