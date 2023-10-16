#!/bin/bash
apt-get update && apt-get install -y wget #net-tools
nx=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 4)
xpid=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8)

if [[ ! -n "$ver" ]]; then
  ver=$(curl -Ls "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi

wget -O $nx.tar.gz https://github.com/SagerNet/sing-box/releases/download/v${ver}/sing-box-${ver}-linux-amd64.tar.gz

tar -xvf $nx.tar.gz && rm -f $nx.tar.gz
chmod a+x sing-box-${ver}-linux-amd64/sing-box && mv sing-box-${ver}-linux-amd64/sing-box $xpid
rm -rf sing-box-${ver}-linux-amd64

wget -N https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db
wget -N https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db

cp ./config.template.json ./config.json
cp /etc/nginx/nginx.template.conf /etc/nginx/nginx.conf

if [[ ! -n "$WARPKEY" ]]; then
  WARPKEY="WARPKEY"
fi

if [[ ! -n "$WARPSERVER" ]]; then
  WARPSERVER="engage.cloudflareclient.com"
fi

if [[ ! -n "$WARPPORT" ]]; then
  WARPPORT="2408"
fi

sed -i "s/UUID/$UUID/g" ./config.json
sed -i "s/WARPKEY/$WARPKEY/g" ./config.json
sed -i "s/WARPSERVER/$WARPSERVER/g" ./config.json
sed -i "s/WARPPORT/$WARPPORT/g" ./config.json
sed -i "s/UUID/$UUID/g" /etc/nginx/nginx.conf

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

cat > log << EOF
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
use cat log to print configs
EOF
 
cat log

nginx
./$xpid run -c config.json
