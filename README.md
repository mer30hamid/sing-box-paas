Sing-Box + NGINX
----------------

### Variables:

- General Variables:

   * UUID = UUID - for example use an online UUID generator (mandatory)
   * VER = sing-box Core version (optional)
   * CORE_URL = sing-box Core URL - if set, VER must be set correctly (optional)
   * JDOMAIN = Joined DOMAIN for config generation (optional)
   
- Only for deployment in Iran:

   * IRAN_ACCESS = If "true", script removes all Iran related rules that block access from Iran (optional)
   * IRAN_DNS_RESOLVER = set an Iranian DNS for resolver (optional)
   * IRAN_DNS_ALL = set an Iranian DNS for all connections (optional)

   


### Configs:
use `cat log` to print configs.



## Github Actions

There is  `.github/workflows/docker.yml`  with workflow that:

* Builds Docker image and pushes to Docker Hub
* Uses multi-platform caching via GitHub Actions cache
* Tags with branch, version, and SHA prefixes

To use it, add these secrets to your GitHub repository:

1. Go to repository Settings → Secrets and variables → Actions
2. Add:
    *  DOCKER_USERNAME  - your Docker Hub username
    *  DOCKER_PASSWORD  - your Docker Hub password/token
    *  DOCKER_IMAGE_NAME  - desired image name (e.g.,  `singbox-paas`  or
    `username/singbox-paas` )


The workflow will push images tagged with:

*  branch-name  (e.g.,  main )
*  pr-number  for PRs
*  version  tags from version tags
*  branch-sha  format for branch commits
