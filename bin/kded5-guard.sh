while sleep 5
do
    [ $(lsof -U +c 15 2>/dev/null | grep kded5 | wc -l) -gt 30 ] && killall -v kded5
done
