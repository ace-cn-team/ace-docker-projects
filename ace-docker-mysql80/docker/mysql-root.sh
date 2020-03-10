#进入mysql：
mysql -uroot -proot
#授权：
GRANT ALL ON *.* TO 'root'@'%';
#刷新权限：
flush privileges;
#更新加密规则：
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password' PASSWORD EXPIRE NEVER;
#更新root用户密码：
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
#刷新权限：
flush privileges;