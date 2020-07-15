VBoxManage export devops-server -o "/home/virtualbox/images/devops-server-$(date "+%Y%m%d%H%M%S").ova" --options manifest --options nomacs
VBoxManage export controller-1 -o "/home/virtualbox/images/controller-1-$(date "+%Y%m%d%H%M%S").ova" --options manifest --options nomacs
VBoxManage export controller-1 -o "/home/virtualbox/images/controller-2-$(date "+%Y%m%d%H%M%S").ova" --options manifest --options nomacs
VBoxManage export worker-1 -o "/home/virtualbox/images/worker-1-$(date "+%Y%m%d%H%M%S").ova" --options manifest --options nomacs
VBoxManage export worker-2 -o "/home/virtualbox/images/worker-2-$(date "+%Y%m%d%H%M%S").ova" --options manifest --options nomacs
VBoxManage export mysql8 -o "/home/virtualbox/images/mysql8-$(date "+%Y%m%d%H%M%S").ova" --options manifest --options nomacs