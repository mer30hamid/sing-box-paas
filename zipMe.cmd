del .\ok.zip
rem "%programfiles%\7-Zip\7z.exe" a -tzip -xr!.github -xr!.git -xr!docker-s3-bucket-master -xr!sing-box-templates-main -xr!README.md -xr!LICENSE -xr!envs.txt -xr!zipMe.cmd -xr!.gitignore ok.zip .
tar -a -c -f ok.zip Dockerfile config.template.json entrypoint.sh index.html nginx.template.conf