# 日志范围与事件建议

## 当前采集范围

现代 profile `fluent-bit.conf` 转发以下通道的全部事件：

| 通道 | 标签 | `log_source` |
|---|---|---|
| `System` | `windows.system` | `system` |
| `Security` | `windows.security` | `security` |
| `Application` | `windows.application` | `application` |
| `Microsoft-Windows-PowerShell/Operational` | `windows.powershell` | `powershell` |
| `Microsoft-Windows-Sysmon/Operational` | `windows.sysmon` | `sysmon` |

Server 2008 profile 只采集 `System`、`Security` 和 `Application`，避免依赖不一定存在的 PowerShell Operational 和 Sysmon 通道。

所有 Windows 日志都会增加 `client_id=${HOSTNAME}`，通过 HTTP POST 发送到 `${SERVER_HOST}:${SERVER_PORT}/api/v1/logs/windows`。不使用 EventID 过滤。

每次启动还会发送心跳到 `/api/v1/heartbeat`。为兼容 Fluent Bit 1.8.15，心跳频率为每秒一次。

## 建议关注的 Security 事件

- 登录与提权：4624、4625、4634、4647、4648、4672、4776；域环境增加 4768、4769、4771。
- 进程与权限：4688、4673、4674、4704、4705。建议启用“在进程创建事件中包含命令行”。
- 账号和组变更：4720、4722、4725、4726、4724、4738、4728、4729、4732、4733、4756、4757、4739。
- 持久化和清理：4697、4698–4702、4719、1102、4616、4657、4670。

## PowerShell 与 Sysmon

PowerShell Operational 建议启用 Script Block Logging，以产生完整的 4104 事件。Sysmon 可补充进程创建、网络连接、进程访问、文件、注册表、WMI 和 DNS 等审计信息。Sysmon 规则应按设备用途调优，避免日志量过大。
