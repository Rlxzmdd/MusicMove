# MusicMove

**MusicMove** 是一个 Linux 脚本工具项目，能够自动化地在指定目录中查找特定格式的音乐文件，并根据用户配置的规则移动或转换这些文件。本工具适用于需要批量处理 `.mp3`、`.flac` 和 `.ncm` 文件的用户，具备文件夹结构保留和自动定时执行功能。

## 功能概述
- **支持的格式**：处理 `.mp3`、`.flac` 文件的移动，以及 `.ncm` 文件的解密与移动。
- **递归操作**：支持层次遍历待检测目录，保留原文件夹结构，确保输出文件夹中的目录结构与原目录一致。
- **批量处理**：对于 `.ncm` 文件，通过 `ncmdump` 工具进行批量解密与转换。
- **日志记录**：每次执行都会生成统计日志，并支持通过 `rsyslog` 配置将日志输出至系统日志。
- **定时执行**：使用 `cron` 实现每 5 分钟自动运行脚本。

## 先决条件
1. **ncmdump 工具**：需要预先安装 `ncmdump` 以处理 `.ncm` 文件。或在github下载该项目：https://github.com/taurusxin/ncmdump
2. **rsyslog**：确保系统中已安装 `rsyslog` 并正确配置日志输出位置。

## 目录结构
假设 `MusicMove` 项目存放在 `/vol1/1000/AppData/MusicMove` 路径下，基本目录结构如下：
```
/vol1/1000/AppData/MusicMove/
|– MusicMusicMove.sh               # 主脚本文件
|– ncmdump               # ncmdump 工具路径
```

## 使用说明
### 1. 脚本参数说明
`MusicMove.sh` 脚本支持以下参数：
- `-s`：待检测目录路径
- `-o`：输出目录路径
- `-n`：`ncmdump` 工具的调用路径
- `-d`：是否删除源文件 (`true` 或 `false`)

### 2. 脚本执行示例
在命令行中运行以下命令以执行 `MusicMove.sh` 脚本，自动移动和处理音乐文件：

```bash
./MusicMove.sh -s "/vol4/1000/Music/Cache" -o "/vol4/1000/Music/Netease" -n "/vol1/1000/AppData/MusicMove/ncmdump" -d "true"
```

### 3. 配置定时任务
要每五分钟执行一次 `MusicMove.sh`，可以通过 `cron` 配置定时任务：

```bash
crontab -e
```

在 `crontab` 文件中添加以下行：

```bash
*/5 * * * * /vol1/1000/AppData/MusicMove/MusicMove.sh -s "/vol4/1000/Music/Cache" -o "/vol4/1000/Music/Netease" -n "/vol1/1000/AppData/MusicMove/ncmdump" -d "true" >> /var/log/move.log 2>&1
```

此配置将每五分钟自动运行脚本，并将输出重定向至 `/var/log/move.log`。

### 4. 使用 rsyslog 查看日志
1. 配置 `rsyslog`：编辑 `/etc/rsyslog.conf`，使脚本的日志信息展示到fnos的日志套件。
```bash
if ($programname == 'MusicMove' ) then {
  $OMUxSockSocket  /run/trim_eventlogger/sys_eventlogger
  :omuxsock:;syslogfmt
  stop
}
```
2. 查看日志：通过以下命令查看脚本生成的日志内容。

```bash
# 实时查看日志
tail -f /var/log/syslog | grep "MusicMove"

# 查看特定日志条目
journalctl | grep "MusicMove"
```

## 输出示例
每次执行 `MusicMove.sh` 脚本，将生成一行统计日志，包含以下信息：

- **待检测目录中的总文件数**
- **.mp3 文件数**
- **.flac 文件数**
- **.ncm 文件数**

日志示例：

```
待检测目录中的总文件数: 87, mp3 文件数: 20, flac 文件数: 2, ncm 文件数: 65
```

## 注意事项
- **路径配置**：务必确保所有路径都使用绝对路径，避免脚本执行过程中路径解析问题。
- **权限问题**：脚本和日志文件应具有合适的文件权限，确保 `cron` 和 `rsyslog` 能正常访问。
- **删除源文件**：在 `-d true` 设置下，源文件将被删除，请谨慎使用。

## 贡献
欢迎提交 Issue 和 Pull Request！如需帮助或建议，请联系项目维护者。

## 许可
该项目遵循 MIT 许可证。
