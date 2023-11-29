Action=$1
case $Action in
            start)
                echo starting the payment;;
            stop)
                echo stopping the payment;;
            restart)
                echo restarting the payment;;
            *)
                echo -e "\e[33m valid options are start, stop, restart \e[0m"
                echo -e "\e[33m please run the script again \e[0m" ;;
esac
                
                
        