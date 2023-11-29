Action=$1
case $Action in
            start)
                echo starting the payment;;
            stop)
                echo stopping the payment;;
            restart)
                echo restarting the payment;;
            *)
                echo valid options are start, stop, restart
                echo please run the script again;;
esac
                
                
        