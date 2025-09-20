[[GitBash是什么？]]

GitBash运行以下命令：

ssh-keygen -t rsa -C "xxxxx@xxxxx.com"

| 命令片段                   | 作用说明                                     |
| ---------------------- | ---------------------------------------- |
| `ssh-keygen`           | 核心工具：SSH协议内置的“密钥生成器”，负责创建、管理、转换SSH密钥对    |
| `-t rsa`               | 指定密钥算法：`-t`（type，类型）参数指定用 **RSA算法** 生成密钥 |
| `-C "xxxxx@xxxxx.com"` | 添加备注信息：`-C`（comment，注释）参数给密钥加“标签”，方便后续识别 |
Windows的OpenSSH也支持ssh-keygen，但是也许你的Windows版本没下载。下载GitBash，GitBash一定支持这个命令。



