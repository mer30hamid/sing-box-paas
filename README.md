Sing-Box + NGINX - Liara version
----------------

Variables:
 * VER = sing-box version **important: must be set in DockerFile**
 * UUID = UUID (for example use an online UUID generator)
 * JDOMAIN = Joined DOMAIN (optional for config generation) for example: yourapp.liara.run
 * XPID = a random 8 character string (for example: ksfhwke) **important: must be set same in DockerFile and Environment variables**

Optional: for Iran server, uncomment line containing `# only for Iran` in DockerFile

use `cat /tmp/log` to print configs.