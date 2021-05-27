#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu/Arch
#	Description: bolo blog start
#	Version: 1.0.2
#	Author: expoli
#	Blog: http://expoli.tech
#   created 2021.04.09
#   email me@expoli.tech
#=================================================

SH_VERSION="1.0.2"
BINARY_FILES_PLACE="/usr/bin"
DOCKER_DAEMON_JSON="/etc/docker/daemon.json"
BOLO_INSTALL_DIR="/opt/bolo-blog"
BOLO_ENV_CONFIG_FILE="bolo-env.env"
BOLO_DOCKER_COMPOSE_CONFIG_FILE="docker-compose.yaml"

BASEPATH=$(cd `dirname $0`; pwd)

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#检查系统
Check_sys() {
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "arch"; then
		release="arch"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "arch"; then
		release="arch"
	fi
	bit=$(uname -m)
}
# 安装依赖
Installation_dependency() {
	if [[ ${release} == "centos" ]]; then
		sudo yum -y update
		sudo yum remove -y docker \
			docker-client \
			docker-client-latest \
			docker-common \
			docker-latest \
			docker-latest-logrotate \
			docker-logrotate \
			docker-engine
		sudo yum install -y yum-utils \
			device-mapper-persistent-data \
			lvm2
		sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
		sudo yum install -y docker-ce \
			docker-ce-cli \
			containerd.io \
			git \
			zip \
			unzip
	elif [ ${release} == "debian" ]; then
		# Uninstall old versions
		sudo apt-get update -y
		sudo apt-get remove -y docker \
			docker-engine \
			docker.io \
			containerd \
			runc

		# SET UP THE REPOSITORY
		sudo apt-get install -y \
			apt-transport-https \
			ca-certificates \
			curl \
			gnupg \
			lsb-release
		# Add Docker’s official GPG key
		curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		echo \
			"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

		# INSTALL DOCKER ENGINE
		sudo apt-get update -y
		sudo apt-get install -y \
			docker-ce \
			docker-ce-cli \
			containerd.io \
			git \
			zip \
			unzip

	elif [ ${release} == "ubuntu" ]; then
		sudo apt-get update -y
		sudo apt-get remove -y docker \
			docker-engine \
			docker.io \
			containerd \
			runc
		sudo apt-get install -y \
			apt-transport-https \
			ca-certificates \
			curl \
			gnupg \
			lsb-release
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		echo \
			"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
		sudo apt-get update -y
		sudo apt-get install -y \
			docker-ce \
			docker-ce-cli \
			containerd.io \
			git \
			zip \
			unzip

	elif [ ${release} == "arch" ]; then
		sudo pacman -Syu --noconfirm
		sudo pacman -S \
			docker \
			git \
			zip \
			unzip \
			--noconfirm
	fi
}
# 设置容器加速源为 docker 中国
Set_Docker_Fast_Mirrors() {
	# https://www.daocloud.io/mirror
	curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
	Restart_Docker
}
# 安装
Install_Docker() {
	# [[ -e "${BINARY_FILES_PLACE}/docker" ]] && echo -e "${Error} 检测到 Docker 已安装 ! 请卸载现有版本再进行安装!" && exit 1
	echo -e "${Info} 开始安装/配置 依赖..."
	Installation_dependency
	echo -e "${Info} 所有步骤 安装完毕."
	# docker info
	echo -e "${Info} 开启守护进程,设置为开机启动并开始启动..."
	Start_Docker
}
# 启动 Docker
Start_Docker() {
	sudo systemctl enable docker
	sudo systemctl start docker
	sudo systemctl status docker
}
# 停止
Stop_Docker() {
	sudo systemctl stop docker
}
# 重启
Restart_Docker() {
	sudo systemctl daemon-reload
	sudo systemctl restart docker
}
# 卸载Docker
Uninstall_Docker() {
	if [[ ${release} == "centos" ]]; then
		sudo yum remove -y docker \
			docker-client \
			docker-client-latest \
			docker-common \
			docker-latest \
			docker-latest-logrotate \
			docker-logrotate \
			docker-engine
	elif [[ ${release} == "debian" ]]; then
		sudo apt-get remove -y docker-ce \
			docker-ce-cli \
			containerd.io
	elif [[ ${release} == "ubuntu" ]]; then
		sudo apt-get remove -y docker-ce \
			docker-ce-cli \
			containerd.io
	elif [[${release} == "arch" ]]; then
		sudo pacman -Rs docker docker-compose --noconfirm
	fi
}
# 更新Docker
Update_Docker() {
	if [[ ${release} == "centos" ]]; then
		sudo yum update -y docker*
		sudo yum info docker*
	elif [[ ${release} == "debian" ]]; then
		sudo apt-get update
		sudo apt-get upgrade -y docker
		sudo apt show docker
	elif [[ ${release} == "ubuntu" ]]; then
		sudo apt-get update
		sudo apt-get upgrade -y docker
		sudo apt show docker
	elif [[ ${release} == "arch" ]]; then
		sudo pacman -Syu --noconfirm
	fi
}
# 安装docker-compose
Install_Docker_compose() {
	if [[ ${release} == "centos" ]]; then
		sudo yum install -y docker-compose
	elif [[ ${release} == "debian" ]]; then
		sudo apt-get install -y docker-compose
	elif [[ ${release} == "ubuntu" ]]; then
		sudo apt-get install -y docker-compose
	elif [[ ${release} == "arch" ]]; then
		sudo pacman -S docker-compose --noconfirm
	else
		sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		sudo chmod +x /usr/local/bin/docker-compose
		docker-compose --version
	fi
}
# 查看 docker 的运行状态
View_Docker_Status() {
	Check_pid_server
	sudo systemctl status docker
}
# 查看 docker 的PID
Check_pid_server() {
	PID=$(ps -ef | grep "docker" | grep -v grep | grep -v ".sh" | grep -v "init.d" | grep -v "service" | awk '{print $2}')
}
# 脚本升级
Update_Shell() {
	# sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/expoli/Docker-install-menu-bash/master/install_docker.sh"|grep 'SH_VERSION="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 Github !" && exit 0
	wget -N --no-check-certificate "https://raw.githubusercontent.com/expoli/Docker-install-menu-bash/master/install_docker.sh" && chmod +x install_docker.sh
	echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
}
# 检测部署目录
Check_install_dir() {
	if [[ -d ${BOLO_INSTALL_DIR} ]]; then
		read -e -p "${BOLO_INSTALL_DIR} 已经存在，是否强制部署？(y/n)" next
		case "$next" in
		y)
			rm ${BOLO_INSTALL_DIR} -rf
			;;
		n)
			echo -e "${Tip} ${BOLO_INSTALL_DIR} 已经存在，部署程序正常退出！"
			echo -e "${Error} 如果想强行部署，请删除${BOLO_INSTALL_DIR}文件夹" && exit 0
			;;
		*)
			echo "回车确认！"
			;;
		esac
	fi
}
# 获取 bolo docker-compose 文件
Get_bolo_docker_compose_repo() {
	if [[ -d ${BOLO_INSTALL_DIR} ]]; then
		echo -e "${Tip} ${BOLO_INSTALL_DIR} 已经存在，部署程序正常退出！"
		echo -e "${Error} 如果想强行部署，请删除${BOLO_INSTALL_DIR}文件夹" && exit 0
	fi
	git clone https://gitee.com/expoli/start-bolo-with-docker-compose ${BOLO_INSTALL_DIR}
}
# 设置用户关键信息
Set_important_config() {
	echo "-------------------------------------------------------------------"
	read -e -p "请输入数据库ROOT账户密码:" db_root_password
	read -e -p "请输入Bolo-blog所使用的数据库名：" bolo_blog_db
	read -e -p "请输入Bolo-blog所用数据库用户名：" bolo_blog_db_user
	read -e -p "请输入Bolo-blog所用数据库密码：" bolo_blog_db_passwd
	read -e -p "请输入接受Let's Encrypt证书更新信息的邮箱：" user_email
	read -e -p "请输入Bolo-blog的域名：" bolo_blog_domain
	echo "-------------------------------------------------------------------"
}
# 输出用户关键信息
Print_important_config() {
	echo "-------------------------------------------------------------------"
	echo -e " 所设置的配置信息如下，请再次确认！"
	echo -e ${Tip} 数据库ROOT账户密码: ${db_root_password}
	echo -e ${Tip} Bolo 所使用的数据库名: ${bolo_blog_db}
	echo -e ${Tip} Bolo 数据库用户名: ${bolo_blog_db_user}
	echo -e ${Tip} Bolo 数据库密码: ${bolo_blog_db_passwd}
	echo -e ${Tip} 用户邮箱: ${user_email}
	echo -e ${Tip} 博客域名: ${bolo_blog_domain}

	read -e -p "是否继续？ (y/n)" next
	case "$next" in
	y)
		echo "-------------------------------------------------------------------"
		;;
	n)
		echo -e "${Info} 取消输入，请重新运行该脚本！"
		exit 0
		;;
	*)
		echo "回车确认！"
		;;
	esac
}
# 将配置信息写入文件
Write_config_to_file() {
	echo "-------------------------------------------------------------------"
	if [[ -f ${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE}} ]]; then
		echo -e "${Tip} 正在备份原始配置文件..."
		cp "${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE} ${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE}_back"
		echo -e "${Tip} 原始配置文件已备份完成..."
	fi

	sed -i "s/MYSQL_ROOT_PASSWORD=new_root_password/MYSQL_ROOT_PASSWORD=${db_root_password}/g" "${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE}"
	sed -i "s/MYSQL_USER=bolo/MYSQL_USER=${bolo_blog_db_user}/g" "${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE}"
	sed -i "s/MYSQL_DATABASE=bolo/MYSQL_DATABASE=${bolo_blog_db}/g" "${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE}"
	sed -i "s/MYSQL_PASSWORD=bolo123456/MYSQL_PASSWORD=${bolo_blog_db_passwd}/g" "${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE}"

	sed -i "s/JDBC_USERNAME=bolo/JDBC_USERNAME=${bolo_blog_db_user}/g" "${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE}"
	sed -i "s/JDBC_PASSWORD=bolo123456/JDBC_PASSWORD=${bolo_blog_db_passwd}/g" "${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE}"
	sed -i "s/JDBC_URL=jdbc:mysql:\/\/db:3306\/bolo/JDBC_URL=jdbc:mysql:\/\/db:3306\/${bolo_blog_db}/g" "${BOLO_INSTALL_DIR}/${BOLO_ENV_CONFIG_FILE}"

	sed -i "s/me@example.org/${user_email}/g" "${BOLO_INSTALL_DIR}/${BOLO_DOCKER_COMPOSE_CONFIG_FILE}"
	sed -i "s/blog.example.org/${bolo_blog_domain}/g" "${BOLO_INSTALL_DIR}/${BOLO_DOCKER_COMPOSE_CONFIG_FILE}"
	echo "-------------------------------------------------------------------"
}
# 拉取镜像并启动Bolo
Start_bolo_use_docker_compose() {
	echo "-------------------------------------------------------------------"
	cd ${BOLO_INSTALL_DIR} && docker-compose pull
	cd ${BOLO_INSTALL_DIR} && docker-compose down && docker-compose up -d
}
# 重启博客
Restart_Bolo_blog(){
	echo "-------------------------------------------------------------------"
	cd ${BOLO_INSTALL_DIR} && docker-compose restart
}
# Deploy Bolo
Deply_bolo(){
	echo "-------------------------------------------------------------------"
	Check_install_dir
	Set_important_config
	Print_important_config
	Get_bolo_docker_compose_repo
	Write_config_to_file
	Start_bolo_use_docker_compose
	echo "等待数据库初次初始化完成........."
	sleep 16s
	echo "正在重启博客......"
	sleep 10s
	Restart_Bolo_blog
}
# 博客备份
Backup_blog() {
	echo "-------------------------------------------------------------------"
	cd ${BOLO_INSTALL_DIR} && docker-compose down
	time=$(date "+%Y_%m_%d_%H_%M_%S")
	cd ${BASEPATH}
	zip -r Bolo_blog_back_up_${time}.zip ${BOLO_INSTALL_DIR}
	echo -e "${Tip} 备份完成，文件路径为 ${PWD}/Bolo_blog_back_up_${time}.zip 请妥善保管"
	exit 0
}
# 恢复备份
Restore_blog(){
	echo "-------------------------------------------------------------------"
	echo -e "${Tip} 请确保该脚本目录下只有一个 Bolo_blog_back_up_${time}.zip 格式的压缩包！！"
	cd ${BASEPATH}
	back_up_file=$(ls -t ${PWD} | grep "Bolo_blog_back_up_" | head -n 1)
	unzip ${back_up_file} -d /
}
# 主菜单
menu_server() {
	echo && echo -e "  Bolo-blog 一键安装管理脚本 ${Red_font_prefix}[v${SH_VERSION}]${Font_color_suffix}
	-- expoli | Bolo-blog/shell --
	
	${Green_font_prefix} 0.${Font_color_suffix} 升级脚本
	————————————
	${Green_font_prefix} 1.${Font_color_suffix} 安装 Docker 运行环境
	${Green_font_prefix} 2.${Font_color_suffix} 设置加速镜像源
	${Green_font_prefix} 3.${Font_color_suffix} 查看 docker 运行状态
	————————————
	${Green_font_prefix} 4.${Font_color_suffix} 启动 Docker
	${Green_font_prefix} 5.${Font_color_suffix} 停止 Docker
	${Green_font_prefix} 6.${Font_color_suffix} 重启 Docker
	————————————
	${Green_font_prefix} 7.${Font_color_suffix} 部署 Bolo-blog
	${Green_font_prefix} 8.${Font_color_suffix} 更新 Bolo-blog
	${Green_font_prefix} 9.${Font_color_suffix} 备份 Bolo-blog
	${Green_font_prefix} 10.${Font_color_suffix} 恢复 Bolo-blog
	${Green_font_prefix} 11.${Font_color_suffix} 重启 Bolo-blog
	————————————
	${Green_font_prefix} q.${Font_color_suffix} 退出脚本
			" && echo
	if [[ -e "${BINARY_FILES_PLACE}/docker" ]]; then
		Check_pid_server
		if [[ ! -z "${PID}" ]]; then
			echo -e " 当前状态: Docker ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
		else
			echo -e " 当前状态: Docker ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
		fi
	else
		echo -e " 当前状态: Docker ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
	echo
	read -e -p " 请输入数字 [0-10]:" num
	case "$num" in
	0)
		Update_Shell
		;;
	1)
		Install_Docker
		Install_Docker_compose
		;;
	2)
		Set_Docker_Fast_Mirrors
		;;
	3)
		View_Docker_Status
		;;
	4)
		Start_Docker
		;;
	5)
		Stop_Docker
		;;
	6)
		Restart_Docker
		;;
	7)
		Deply_bolo
		;;
	8)
		Start_bolo_use_docker_compose
		;;
	9)
		Backup_blog
		;;
	10)
		Restore_blog
		;;
	11)
		Restart_Bolo_blog
		;;
	q)
		exit 0
		;;
	*)
		echo "请输入正确数字 [0-10]"
		;;
	esac
}
Check_sys
menu_server
