docker run ^
-v %~dp0../data/openvpn:/etc/openvpn ^
--rm kylemanna/openvpn:2.4 ovpn_genconfig ^
-u udp://172.18.0.100

docker run -v %~dp0../data/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 ovpn_initpki

docker run -v %~dp0../data/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 easyrsa build-client-full caspar nopass

docker run -v %~dp0../data/openvpn:/etc/openvpn --rm kylemanna/openvpn:2.4 ovpn_getclient caspar > %~dp0../data/openvpn/caspar.ovpn