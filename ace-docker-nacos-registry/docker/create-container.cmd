docker run ^
--restart=always ^
--net ace-network ^
--ip 172.18.0.4 ^
-d ^
--env MODE=standalone ^
-p8848:8848 ^
--name nacos-registry ^
nacos/nacos-server:1.1.4