# 运行与测试

## 启动

在 `windows` 目录执行：

```bat
start_2008.bat
start_2016_2019_2022.bat
```

启动脚本会先停止已有的 `fluent-bit.exe` 进程，然后启动对应版本和 profile。

## 配置检查

启动脚本将控制台代码页设为 UTF-8（65001），同时设置 PowerShell 的控制台输出编码。2008 和现代 profile 共用此设置。修改后请关闭旧窗口并重新运行启动脚本；若中文显示为方框，请在终端中选择支持中文的字体。

```bat
start_2008.bat --check
start_2016_2019_2022.bat --check
```

`--check` 使用 Fluent Bit 的 dry-run 模式，不应连接后端发送日志。

启动脚本使用相对于 `windows` 配置目录的路径：现代 profile 位于上两级目录，Server 2008 的 1.8.15 目录位于上三级目录，不依赖固定盘符或固定用户名。

日志 HTTP 输出关闭了长连接（`net.keepalive Off`）。后端日志接口应返回简短的成功响应；如果响应体超过 Fluent Bit HTTP 客户端的缓冲限制，客户端会出现 `cannot increase buffer` 并将日志块放入 `storage_backlog` 持续重试。此时应让 `/api/v1/logs/windows` 返回简短的 `200` 响应，不要把大量日志内容回显给客户端。

## 本地文件

日志保存到 `local-logs\\`，文件名格式为 `windows_yyyyMMdd_HHmmss.jsonl` 或 `windows_2008_yyyyMMdd_HHmmss.jsonl`。每行是一条 JSON 记录，文件为 UTF-8（无 BOM）。HTTP 输出仍保留，因此本地文件和后端转发会同时发生。修改编码配置后需要重启 Fluent Bit，旧文件中的乱码无法自动恢复。

## 清理旧的本地缓存

执行对应脚本会停止 Fluent Bit、清空磁盘缓冲目录，并将日志转发起始时间点重置为清理时刻：脚本把每个 Windows Event Log 通道的 `winlog*.db` 读取断点写成清理时刻的最新 Record ID；`local-logs` 历史 JSONL 文件会保留。脚本会重建读取位置数据库，而不是留下空数据库。

```bat
clear_previous_logs_2008.bat
clear_previous_logs_2016_2019_2022.bat
```

两个脚本都会在重置完成后启动对应 profile，并只处理这个时间点之后新增的事件；已有的 `local-logs` 文件不会被删除。脚本需要 `sqlite3.exe` 在 PATH 中，用于写入 Fluent Bit 的 SQLite 读取位置数据库。

## 权限

读取 `Security` 通道通常需要管理员权限。生产环境运行前应确认服务账户拥有事件日志读取权限，并确认 `SERVER_HOST`、`SERVER_PORT` 和本地缓存目录可用。
