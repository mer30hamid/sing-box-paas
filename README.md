Sing-Box + NGINX - Liara version
----------------

Variables:
 * VER = sing-box version **important: must be set in DockerFile**
 * UUID = UUID (for example use an online UUID generator)
 * JDOMAIN = Joined DOMAIN (optional for config generation) for example: yourapp.liara.run
 * XPID = a random short string (for example: ksfhwke) **important: must be set same in DockerFile and Environment variables**
 * WARPKEY = wireguard base64 key (optional, if set, configs will be generated) **Important: you must use base64 version, for example you can find it inside the `wg-config.conf` file)
 * WARPSERVER = warp server (optional)
 * WARPPORT = warp port (optional)
 * DOH_ADDRESS = DNS over HTTPS (DOH) Address (otional)
 * OUTBOUND = outbound part as json (optional)

You can either buy an WARP+ Unlimited license or get a free WARP+ license from this telegram bot: https://t.me/generatewarpplusbot

use `cat /tmp/log` to print configs.