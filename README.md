# Bolo 博客一键部署脚本

 此项目是对 [start-bolo-with-docker-compose](https://github.com/expoli/start-bolo-with-docker-compose) 的封装，支持交互式部署，一键式的傻瓜脚本。


## 支持的系统

`Ubuntu/Centos/Debian/Arch`

## 默认数据储存路径

/opt/bolo-blog

## 使用方法

**注意！因为默认容器会尝试创建数据库用户，所以输入用户名的时候避免输入`root` 否则会导致部署失败！！**

```
git clone https://github.com/expoli/start-bolo.git
cd start-bolo && chmod +x ./start-bolo.sh
./start-bolo.sh
```

```

  Bolo-blog 一键安装管理脚本 [v1.0.0]
	-- expoli | Bolo-blog/shell --
	
	 0. 升级脚本
	————————————
	 1. 安装 Docker 运行环境
	 2. 设置加速镜像源
	 3. 查看 docker 运行状态
	————————————
	 4. 启动 Docker
	 5. 停止 Docker
	 6. 重启 Docker
	————————————
	 7. 部署 Bolo-blog
	 8. 更新 Bolo-blog
	 9. 备份 Bolo-blog
	 10. 恢复 Bolo-blog
	————————————
	 q. 退出脚本
			

 当前状态: Docker 已安装 并 已启动

 请输入数字 [0-10]:

```
