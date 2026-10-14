# Fluent Bit Windows 配置文档

本目录记录 Windows Server 2008、2016、2019 和 2022 的 Fluent Bit 配置、日志范围、版本兼容性和运行方式。

## 文档导航

- [日志范围与事件建议](log-scope.md)
- [版本兼容性](compatibility.md)
- [运行与测试](operations.md)

## 配置文件

| 目标系统 | 主配置 | 启动脚本 |
|---|---|---|
| Windows Server 2008 + Fluent Bit 1.8.15 | `../fluent-bit-2008.conf` | `../start_2008.bat` |
| Windows Server 2016/2019/2022 | `../fluent-bit.conf` | `../start_2016_2019_2022.bat` |

两个 profile 都会将 Windows 日志发送到后端，并在本地 `../local-logs/` 保存带时间戳的 JSONL 文件。

手动清理并重置转发时间点：Server 2008 使用 `../clear_previous_logs_2008.bat`，2016/2019/2022 使用 `../clear_previous_logs_2016_2019_2022.bat`。两个脚本都只保留 `../local-logs/` 历史 JSONL 文件。
