docker run ^
--name dns-dnsmasq ^
-d ^
--net ace-network ^
--ip 172.18.0.2 ^
-p 53:53/udp ^
-p 53:53/tcp ^
-p 10001:8080 ^
-v %~dp0dnsmasq.conf:/etc/dnsmasq.conf ^
-e "HTTP_USER=admin" ^
-e "HTTP_PASS=admin" ^
--restart always ^
jpillora/dnsmasq:1