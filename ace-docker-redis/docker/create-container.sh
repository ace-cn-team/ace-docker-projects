docker run \
--restart=always \
--net ace-network \
--ip 172.18.0.3 \
-d -p6379:6379 \
--name \
redis-common redis:rc-buster