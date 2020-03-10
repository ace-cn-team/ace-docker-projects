docker run ^
--restart=always ^
--net ace-network ^
--ip 172.18.0.5 ^
-p 3306:3306 ^
-d ^
-e MYSQL_ROOT_PASSWORD=root ^
--name mysql8.0 ^
mysql:8.0.19