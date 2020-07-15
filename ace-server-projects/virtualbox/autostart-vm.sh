##
# 自动启动虚拟机
vboxmanage startvm "controller-1" -type headless
vboxmanage startvm "controller-2" -type headless
vboxmanage startvm "worker-1" -type headless
vboxmanage startvm "worker-2" -type headless
vboxmanage startvm "devops-server" -type headless
vboxmanage startvm "mysql8" -type headless
