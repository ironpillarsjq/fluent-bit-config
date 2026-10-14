param(
    [Parameter(Mandatory = $true)]
    [string]$DbRoot
)

$ErrorActionPreference = 'Stop'

$sqlite = Get-Command sqlite3.exe -ErrorAction SilentlyContinue
if (-not $sqlite) {
    throw 'sqlite3.exe was not found in PATH. Install SQLite or add sqlite3.exe to PATH before cleaning checkpoints.'
}

$channels = @(
    @{ File = 'winlog.db';             Channel = 'System' },
    @{ File = 'winlog_security.db';    Channel = 'Security' },
    @{ File = 'winlog_application.db'; Channel = 'Application' },
    @{ File = 'winlog_powershell.db';  Channel = 'Microsoft-Windows-PowerShell/Operational' },
    @{ File = 'winlog_sysmon.db';      Channel = 'Microsoft-Windows-Sysmon/Operational' }
)

$now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$successCount = 0

foreach ($item in $channels) {
    try {
        $xmlText = (& wevtutil.exe qe $item.Channel /c:1 /rd:true /f:xml 2>$null) -join "`n"
        if ([string]::IsNullOrWhiteSpace($xmlText)) {
            Write-Host "[INFO] Channel unavailable or empty, skipping: $($item.Channel)"
            continue
        }

        $event = [xml]$xmlText
        $recordId = [int64]$event.Event.System.EventRecordID
        $db = Join-Path $DbRoot $item.File
        $sql = "CREATE TABLE IF NOT EXISTS in_winlog_channels (name TEXT PRIMARY KEY, record_number INTEGER, time_written INTEGER, created INTEGER); DELETE FROM in_winlog_channels; INSERT INTO in_winlog_channels(name, record_number, time_written, created) VALUES ('$($item.Channel.Replace("'", "''"))', $recordId, $now, $now);"
        & $sqlite.Source $db $sql | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "sqlite3 failed for $db" }
        Write-Host "[SUCCESS] $($item.Channel): baseline Record ID $recordId"
        $successCount++
    }
    catch {
        Write-Host "[WARN] Could not baseline $($item.Channel): $($_.Exception.Message)"
    }
}

if ($successCount -eq 0) {
    throw 'No Windows Event Log channel baseline was created; refusing to continue.'
}
