#!/usr/bin/env bash

function usage() {
    echo -e "This utility uses the '/dev/tcp' which is a system file that allows you to interact directly with the tcp protocol.\r\n"
    echo "Usage:"
    echo "  $(basename $0) [-m METHOD] [-b BODY] [-H HEADER] [-hD] URL"
    echo -e  "    -m METHOD \tThe http method to use (default GET)"
    echo -e  "    -b BODY \tThe request body"
    echo -e  "    -H HEADER \tAn HTTP header (can include multiple)"
    echo -e  "    -h \t\tPrints this message and exits"
    echo -e  "    -D \t\tEnable debug to see get a look at the recorded inputs"
    echo -e  "    URL \t\tThe url of the request (Required)"
    echo -e  "\r\nExample:"
    echo -e  "  $(basename $0) -m POST -H 'Content-Type: application/json' \\ \r\n  -b '{\"email\":\"user@example.com\",\"password\":\"password\"}' \\ \r\n  http:/example.com:3000/auth/login"
    exit
}
HOST=127.0.0.1
PORT=80
METHOD=GET
BODY=
DEBUG="off"
HEADERS=()
HEADERS+="Connection: close\r\n"
while getopts m:b:H:Dh option
do
case "${option}"
in
D)
    DEBUG="on"
    ;;
m)
    METHOD=${OPTARG^^}
    ;;
b)
    BODY="${OPTARG}"
    ;;
H)
    HEADERS+="${OPTARG}\r\n"
    ;;
*)
    usage
esac
done
shift $(( OPTIND - 1 ))
if [ -z "${1}" ]; then
    usage
fi
URL="${1#https://}"
URL="${URL#http://}"
HOST="${URL%%/*}"
URL="/${URL#*/}"
TPORT="${HOST##*:}"
if [ -z "${TPORT}" ]; then
    PORT="${TPORT}"
fi
HOST="${HOST%%:*}"
REQUEST="${METHOD} ${URL} HTTP/1.0\r\n"
for HEADER in "${HEADERS[@]}"; do
    REQUEST="${REQUEST}${HEADER}"
done

if [ ! -z "${BODY}" ]; then
    REQUEST="${REQUEST}Content-Length: ${#BODY}\r\n"
    REQUEST="${REQUEST}\r\n"
    REQUEST="${REQUEST}${BODY}"
else
    REQUEST="${REQUEST}\r\n"
fi

if [ "${DEBUG}" = "on" ]; then
    echo "Host: $HOST"
    echo "Port: $PORT"
    echo "-----------------------------"
    echo "- Request:                  -"
    echo "-----------------------------"
    echo -e "${REQUEST}"
    echo "-----------------------------"
    echo "- Response:                 -"
    echo "-----------------------------"
fi;


exec 5<>"/dev/tcp/${HOST}/${PORT}"
echo -e "${REQUEST}" >&5
cat <&5
echo
