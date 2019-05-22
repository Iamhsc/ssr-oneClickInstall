os="system"
# user=$(env | grep USER | cut -d "=" -f 2)
# 检查系统
check_os() {
    # 若存在/etc/redhat-release文件，则为真
	if [[ -f /etc/redhat-release ]]; then
        os="centos"
    # /etc/issue存在debian(不区分大小写),则为真 不显示/etc/issue内容
    elif cat /etc/issue | grep -Eqi "debian"; then
        os="debian"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        os="ubuntu"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        os="centos"
    elif cat /proc/version | grep -Eqi "debian"; then
        os="debian"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        os="ubuntu"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        os="centos"
    fi
    echo "检测系统完成"
}
install_dependency(){
        case $os in
            'ubuntu'|'debian')
            apt-get -y update
            apt-get -y install python python-dev python-setuptools openssl libssl-dev curl wget unzip gcc git vim
            ;;
            'centos')
            yum update -y nss curl libcurl
            yum install -y python python-devel python-setuptools openssl openssl-devel curl wget unzip gcc git vim
        esac
}

write_config(){
    echo '{
    "local_address": "127.0.0.1",
    "local_port": 1080,

    "server": "0.0.0.0",
    "server_ipv6": "::",
    "server_port": 443,

    "password": "Zhenai96944826",
    "method": "aes-256-cfb",
    "protocol": "auth_aes128_sha1",
    "protocol_param": "",
    "obfs": "tls1.2_ticket_auth",
    "obfs_param": "",

    "speed_limit_per_con": 0,
    "speed_limit_per_user": 0,

    "additional_ports" : {}, // only works under multi-user mode
    "additional_ports_only" : false, // only works under multi-user mode
    "timeout": 120,
    "udp_timeout": 60,
    "dns_ipv6": false,
    "connect_verbose_info": 0,
    "redirect": "",
    "fast_open": false
}' | cat > user-config.json
    echo "user-config.json配置写入成功"
}

install_ssr(){
    check_os
    install_dependency
    cd /
    git clone https://github.com/ShadowsocksR-Live/shadowsocksr.git
    if [[ -d /shadowsocksr ]]; then
        cd /shadowsocksr
        bash initcfg.sh    
        echo "ssr初始化完成"    
        write_config
        cd /shadowsocksr/shadowsocks
        ./logrun.sh
        echo "ssr运行完成"
        firewall_set
    else 
        echo "shadowsocksr下载失败" 
        exit 1
    fi
}

firewall_set(){
    firewall-cmd --permanent --zone=public --add-port=443/tcp
    firewall-cmd --permanent --zone=public --add-port=443/udp
    firewall-cmd --reload
    echo "防火墙开启成功"
}

main() {
    install_ssr
    exit 0
}

main

