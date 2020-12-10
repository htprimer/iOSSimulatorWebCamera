SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
RESPONSE="HTTP/1.1 200 OK\r\nConnection: keep-alive\r\n\r\n${2:-"hello"}\r\n"

while true
do
    REQUEST=$(echo -en "$RESPONSE" | nc -l 44446)
    PARAM=$(echo $REQUEST | grep "^GET")
    PARAM=${PARAM#*"?"}  #从左向右截取第一个问号后的字符窜
    PARAM=${PARAM%%" "*}  #从右向左截取最后一个空格后的字符串
    PARAM_NAME=${PARAM%%"="*}
    PARAM_VALUE=${PARAM#*"="}
    if [ $PARAM_NAME = 'cmd' ]
    then
        if [ $PARAM_VALUE = 'open' ]
        then
            echo "open $SHELL_FOLDER/camera.html"
            open $SHELL_FOLDER/camera.html
        elif [ $PARAM_VALUE = 'close' ]
        then
            echo "exit"
            exit 0 
        elif [ $PARAM_VALUE = 'active' ]
        then
            osascript -e 'tell application "Simulator" to activate'
        else
            $PARAM_VALUE
        fi
    fi
done