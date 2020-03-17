stop(){
  docker-compose -f ${ACE_DOCKER_BASE_DIR}/docker-compose.yml stop
}
remove(){
  docker-compose -f ${ACE_DOCKER_BASE_DIR}/docker-compose.yml rm
}
stop && remove