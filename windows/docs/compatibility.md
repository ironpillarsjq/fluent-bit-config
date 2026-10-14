# 版本兼容性

| 系统 | Fluent Bit | 推荐 profile | 通道 |
|---|---|---|---|
| Windows Server 2008 | 1.8.15 | `fluent-bit-2008.conf` | System、Security、Application |
| Windows Server 2016 | 现代版本 | `fluent-bit.conf` | System、Security、Application、PowerShell Operational、Sysmon Operational |
| Windows Server 2019 | 现代版本 | `fluent-bit.conf` | System、Security、Application、PowerShell Operational、Sysmon Operational |
| Windows Server 2022 | 现代版本 | `fluent-bit.conf` | System、Security、Application、PowerShell Operational、Sysmon Operational |

Server 2008 不应直接使用现代 profile。PowerShell Operational 和 Sysmon 通道可能不存在，Fluent Bit 1.8 也不能依赖新版本的缺失通道忽略参数。

两个 profile 使用 1.8 可用的 `winlog` 输入插件和基础参数：`Channels`、`DB`、`Interval_Sec`、`Use_ANSI`。当前将 `Use_ANSI` 设置为 `false`，让事件文本按 UTF-8 输出；在中文 Windows 上设置为 `true` 可能触发代码页转换并产生乱码。不要在 1.8 配置中改用新版本专用的 `winevtlog` 参数。

## Fluent Bit 安装路径

- Server 2008 / Fluent Bit 1.8.15：`C:\Users\ironp\Desktop\fluent-bit-1.8.15-win64`
- Server 2016/2019/2022：`C:\Users\ironp\Desktop\fluent-bit`

路径由对应启动脚本中的 `FB_INSTALL_HOME` 控制。
