#!/bin/bash/
Action=$1
case $Action in
            start)
                echo -e "\e[32m starting the payment \e[0m"
                exit 0
                ;;
            stop)
                echo -e "\e[31m stopping the payment \e[0m"
                exit 1
                ;;
            restart)
                echo -e "\e[33m restarting the payment \e[0m"
                exit 2
                ;;
            *)
                echo -e "\e[33m valid options are start, stop, restart \e[0m"
                echo -e "\e[33m please run the script again \e[0m" 
                exit 3
                ;;
esac
                
                
        