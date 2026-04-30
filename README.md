Sing-Box + NGINX
----------------

Variables:
 * UUID = UUID - for example use an online UUID generator (mandatory)
 * VER = sing-box Core version (optional)
 * CORE_URL= sing-box Core URL - overrides VER (optional)
 * JDOMAIN = Joined DOMAIN for config generation (optional)
 * DOH_ADDRESS = DNS over HTTPS or "DOH" Address (otional)

use `cat log` to print configs.



## Github Actions

There is  .github/workflows/docker.yml  with workflow that:

* Triggers on push/PR to main/master
* Builds Docker image and pushes to Docker Hub
* Uses multi-platform caching via GitHub Actions cache
* Tags with branch, version, and SHA prefixes

To use it, add these secrets to your GitHub repository:

1. Go to repository Settings → Secrets and variables → Actions
2. Add:
    *  DOCKER_USERNAME  - your Docker Hub username
    *  DOCKER_PASSWORD  - your Docker Hub password/token
    *  DOCKER_IMAGE_NAME  - desired image name (e.g.,  singbox-paas  or
    username/singbox-paas )


The workflow will push images tagged with:

*  branch-name  (e.g.,  main )
*  pr-number  for PRs
*  version  tags from version tags
*  branch-sha  format for branch commits
