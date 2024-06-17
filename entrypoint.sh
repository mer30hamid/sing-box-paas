#!/bin/bash
mkdir -p /tmp/nginx/client_temp /tmp/cache/nginx /tmp/nginx/fastcgi_cache /tmp/nginx/fastcgi_temp /tmp/cache/nginx/uwsgi_temp /tmp/cache/nginx/scgi_temp /tmp/nginx/scgi_temp 
NGINX_DEFAULT_CONF="/tmp/nginx/conf.d/default.conf"
mkdir -p /tmp/nginx/conf.d/

if [[ ! -n "$VER" ]]; then
  VER=$(curl -Ls "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi

XPID=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8)
nx=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 4)
wget -O /tmp/$nx.tar.gz https://github.com/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-amd64.tar.gz
tar -xvf /tmp/$nx.tar.gz && rm -f /tmp/$nx.tar.gz
chmod a+x /tmp/sing-box-${VER}-linux-amd64/sing-box && mv /tmp/sing-box-${VER}-linux-amd64/sing-box /tmp/$XPID
rm -rf /tmp/sing-box-${VER}-linux-amd64



cp ./config.template.json /tmp/config.json
cp ./nginx.template.conf $NGINX_DEFAULT_CONF

if [[ ! -n "$DOH_ADDRESS" ]]; then
  DOH_ADDRESS="https://9.9.9.9/dns-query"
fi

sed -i "s/UUID/$UUID/g" /tmp/config.json
sed -i "s~DOH_ADDRESS~$DOH_ADDRESS~g" /tmp/config.json
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

cat >> /tmp/log << EOF
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
use cat /tmp/log to print configs

EOF

cat /tmp/log

nginx
/tmp/$XPID run -c /tmp/config.json
