for fn in `ls ../../daemon/*.pid`
	do
	if ! [ -d dumps ]
	then
		mkdir dumps
	fi
	#Следующая строка работает, только если у нас ../../daemon/*.pid, потому что хардкодюшки
	SCHEME=`echo "$fn" | cut -d '/' -f 4 | cut -d '.' -f 1`
	echo $SCHEME
	PID=`cat "$fn"`
	echo $PID
	TEST=`ps -fp "$PID" | grep 'rvec'`
	if [ -z "$TEST" ]
	then
		echo PID не вектора!
	else
		case $1 in
		2)
			PARAMETERS="-F -l"
			;;
		3)
			PARAMETERS=-F
			;;
		*)
			PARAMETERS=-l
			;;
		esac
		echo "$PARAMETERS"

		FILENAME="$SCHEME"_stack_"$(date +%Y-%m-%d_%H:%M:%S)"
		/opt/java/bin/jstack $PARAMETERS $PID > dumps/$FILENAME.txt 2> dumps/$FILENAME.err
		cat dumps/"$FILENAME".err
	fi
done
