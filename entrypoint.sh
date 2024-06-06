#!/bin/bash
mkdir -p /tmp/nginx/client_temp /tmp/cache/nginx /tmp/nginx/fastcgi_cache /tmp/nginx/fastcgi_temp /tmp/cache/nginx/uwsgi_temp /tmp/cache/nginx/scgi_temp /tmp/nginx/scgi_temp 
# cd /tmp
# nx=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 4)
# xpid=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8)
NGINX_DEFAULT_CONF="/tmp/nginx/conf.d/default.conf"
mkdir -p /tmp/nginx/conf.d/

# if [[ ! -n "$VER" ]]; then 
#    VER=$(curl -Ls "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
# fi

# wget -O $nx.tar.gz https://github.com/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-amd64.tar.gz

# tar -xvf $nx.tar.gz && rm -f $nx.tar.gz
# chmod a+x sing-box-${VER}-linux-amd64/sing-box && mv sing-box-${VER}-linux-amd64/sing-box $xpid
# rm -rf sing-box-${VER}-linux-amd64

# wget -N https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db
# wget -N https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db

cp ./config.template.json /tmp/config.json
cp ./nginx.template.conf $NGINX_DEFAULT_CONF

if [[ ! -n "$WARPKEY" ]]; then
  WARPKEY="WARPKEY"
fi

if [[ ! -n "$WARPSERVER" ]]; then
  WARPSERVER="engage.cloudflareclient.com"
fi

if [[ ! -n "$WARPPORT" ]]; then
  WARPPORT="2408"
fi

sed -i "s/UUID/$UUID/g" /tmp/config.json
sed -i "s/WARPKEY/$WARPKEY/g" /tmp/config.json
sed -i "s/WARPSERVER/$WARPSERVER/g" /tmp/config.json
sed -i "s/WARPPORT/$WARPPORT/g" /tmp/config.json
sed -i "s/UUID/$UUID/g" $NGINX_DEFAULT_CONF

# cat config.json | base64 > config
# rm -f config.json

# Generate configs

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
vless="vless://${UUID}@${JDOMAIN}:443?encryption=none&security=tls&sni=$JDOMAIN&type=ws&host=${JDOMAIN}&path=/$UUID-vl#vless_${JDOMAIN}"
trojan="trojan://${UUID}@${JDOMAIN}:443?security=tls&type=ws&host=${JDOMAIN}&path=/$UUID-tr&sni=$JDOMAIN#trojan_${JDOMAIN}"

cat > /tmp/log << EOF
----------------------------------------------------------------
1：Vmess+ws+tls
${vmess}

----------------------------------------------------------------
2：Vless+ws+tls
${vless}

----------------------------------------------------------------
3：Trojan+ws+tls
${trojan}

----------------------------------------------------------------
use cat /tmp/log to print configs
EOF
 
cat /tmp/log

nginx
/$XPID run -c /tmp/config.json
