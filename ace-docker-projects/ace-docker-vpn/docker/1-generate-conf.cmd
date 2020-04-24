docker run ^
-v %~dp0../data/openvpn:/etc/openvpn ^
--rm kylemanna/openvpn:2.4 ovpn_genconfig ^
-u udp://http://172.18.0.100