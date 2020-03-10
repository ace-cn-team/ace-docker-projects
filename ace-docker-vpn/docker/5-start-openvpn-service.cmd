docker run ^
--net ace-network ^
--ip 172.18.0.3 ^
--name openvpn ^
-v %~dp0../data/openvpn:/etc/openvpn ^
-d ^
-p 1194:1194/udp ^
-p 1194:1194/tcp ^
--privileged ^
kylemanna/openvpn:2.4