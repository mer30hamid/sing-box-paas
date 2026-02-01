#!/bin/bash
NGINX_DEFAULT_CONF="/etc/nginx/conf.d/default.conf"

if [[ ! -n "$VER" ]]; then
  VER=$(curl -Ls "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && VER=${VER:1}
fi

XPID=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8)
nx=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 4)
# wget -O $nx.tar.gz https://github.com/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-amd64.tar.gz
wget -O $nx.tar.gz https://140.82.112.3/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-amd64.tar.gz --no-check-certificate
tar -xvf $nx.tar.gz && rm -f $nx.tar.gz
chmod a+x sing-box-${VER}-linux-amd64/sing-box && mv sing-box-${VER}-linux-amd64/sing-box $XPID
rm -rf sing-box-${VER}-linux-amd64



cp ./config.template.json config.json
cp ./nginx.template.conf $NGINX_DEFAULT_CONF

if [[ ! -n "$DOH_ADDRESS" ]]; then
  DOH_ADDRESS="https://9.9.9.9/dns-query"
fi

sed -i "s/UUID/$UUID/g" config.json
sed -i "s~DOH_ADDRESS~$DOH_ADDRESS~g" config.json
sed -i "s/UUID/$UUID/g" $NGINX_DEFAULT_CONF

if [[ ! -n "$JDOMAIN" ]]; then
  JDOMAIN=$(curl -s4m6 ip.sb -k)
fi

vmess="vmess://$(echo -n "\
{\
\"v\": \"2\",\
\"ps\": \"vmess_${JDOMAIN}\",\
\"add\": \"${JDOMAIN}\",\
\"port\": \"443\",\
\"id\": \"$UUID\",\
\"aid\": \"0\",\
\"net\": \"ws\",\
\"type\": \"none\",\
\"host\": \"${JDOMAIN}\",\
\"path\": \"/$UUID-vm\",\
\"tls\": \"tls\",\
\"sni\": \"${JDOMAIN}\"\
}"\
    | base64 -w 0)" 
vless="vless://${UUID}@${JDOMAIN}:443?encryption=none&security=tls&sni=$JDOMAIN&type=ws&host=${JDOMAIN}&path=/$UUID-vl#vless-${JDOMAIN}"
trojan="trojan://${UUID}@${JDOMAIN}:443?security=tls&type=ws&host=${JDOMAIN}&path=/$UUID-tr&sni=$JDOMAIN#trojan-${JDOMAIN}"

cat >> log << EOF
Normal configs:
----------------------------------------------------------------
Vmess+ws+tls
${vmess}

----------------------------------------------------------------
Vless+ws+tls
${vless}

----------------------------------------------------------------
Trojan+ws+tls
${trojan}

----------------------------------------------------------------
use cat log to print configs

EOF

cat log

nginx
./$XPID run -c ./config.json
