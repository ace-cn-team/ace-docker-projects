VBoxManage export devops-server -o /home/virtualbox/images/devops-server.ova --options manifest --options nomacs
VBoxManage export controller-1 -o /home/virtualbox/images/controller-1.ova --options manifest --options nomacs
VBoxManage export worker-1 -o /home/virtualbox/images/worker-1.ova --options manifest --options nomacs
VBoxManage export worker-2 -o /home/virtualbox/images/worker-2.ova --options manifest --options nomacs