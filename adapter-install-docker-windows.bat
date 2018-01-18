@ECHO OFF

REM Installation script for lingk adapter on windows

REM How to run
REM Give Full Control to adapter-install-docker-windows.bat
REM double-click - adapter-install-docker-windows.bat

SET "ADAPTER_FILE=lingksync.tar.gz"
SET "LDAP_FILE=lingkldap.tar.gz"
SET "DOCKER_FILE=docker-compose.yml"

ECHO "loading as docker image: %ADAPTER_FILE%"
docker load < ./downloaded/%ADAPTER_FILE%

ECHO "loading as docker image: %LDAP_FILE%"
docker load < ./downloaded/%LDAP_FILE%

ECHO "installing docker containers from loaded images using %DOCKER_FILE%"
docker-compose -f %DOCKER_FILE% up -d

ECHO "Installation ended"
