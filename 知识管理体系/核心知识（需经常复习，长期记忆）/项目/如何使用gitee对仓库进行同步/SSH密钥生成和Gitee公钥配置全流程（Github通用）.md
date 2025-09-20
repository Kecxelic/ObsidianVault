# 1、GitBash密钥创建
[[怎么通过GitBash创建SSH秘钥？]]


# 2、Gitee添加公钥

![[Pasted image 20250920163014.png]]

# 3、Git Bash终端验证是否添加成功

GitBash运行

ssh -T git@gitee.com

1. **-T**：这是 ssh 命令的一个 “参数选项”，全称是 “Disable pseudo-tty allocation”，意思是 “不分配伪终端”。简单说，就是告诉 ssh：这次连接只用来 “验证”，不用弹出像平时登录服务器那样的命令行操作界面，避免不必要的资源占用，专注于完成连接测试。
2. **git@gitee.com**：这是 “远程服务器的身份标识”，格式为 “用户名 @服务器地址”。其中，“git” 是 Gitee 服务器上专门用于处理 Git 代码仓库操作的默认用户名（所有用户连接 Gitee 的 Git 服务，都用这个固定用户名）；“[gitee.com](https://gitee.com/)” 是 Gitee 的官方服务器地址，代表要连接的是 Gitee 的远程服务器。