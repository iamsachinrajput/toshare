HOSTPUBIP=`ec2metadata --public-hostname|awk '{print $2}'`
AWS_account_owner=` ec2metadata |awk '/public-keys:/{print $NF}'|sed 's/..$//'`
apt-get install sendmail 

#echo "" > /var/log/minerd.log
#echo "" > /var/log/ccminerd.log
echo "" > /skminer/log/miner_log_check.txt
echo "" > /skminer/log/miner_log_good.txt
echo "" > /skminer/log/miner_log_bad.txt
skmail_counter=0

while [ 1 -eq 1 ]
do

SKMIN=`ps -eaf | grep -i tail..f..var.log.*inerd.log | grep -iv grep |wc -l`
        if [ $SKMIN -lt 1 ]
        then
                echo "`date` ====== miner is not running so starting up " >> /skminer/log/miner_log_check.txt
                /etc/init.d/minerd restart
                /etc/init.d/ccminerd restart
        tail -f /var/log/*minerd.log  >> /skminer/log/miner_log_check.txt &
                #minergate-cli -user iamsachinrajput@gmail.com -xmr 8 2>> /skminer/log/miner_log_check.txt >> /skminer/log/miner_log_check.txt &
                #minergate-cli -user iamsachinrajput@gmail.com -dsh 8 2>> /skminer/log/miner_log_check.txt >> /skminer/log/miner_log_check.txt &
                #minergate-cli -user iamsachinrajput@gmail.com -bcn 8 2>> /skminer/log/miner_log_check.txt >> /skminer/log/miner_log_check.txt &
                #minergate-cli -user iamsachinrajput@gmail.com -dsh 8 &
                sleep 90
                HRATE=`tail /skminer/log/miner_log_check.txt | grep -i cpuminer|grep -i H/s | tail -1 | awk '{print int($(NF-5))}'`
                (echo "SUBJECT:$HRATE SKMINER-SKRAJ $AWS_account_owner $HOSTPUBIP started at $HRATE /s ";uptime ; echo "====== " ; cat /skminer/log/miner_log_check.txt)  |sendmail iamsachinrajput@gmail.com
                echo " mail sent for startup " >> /skminer/log/miner_log_check.txt

        else
                sleep 60
                HRATE=`tail /skminer/log/miner_log_check.txt | grep -i cpuminer|grep -i H/s | tail -1 | awk '{print int($(NF-5))}'`

                        if [ $HRATE -gt 1 ]
                        then
                                echo " `date` ===== running good at rate of $HRATE " >> /skminer/log/miner_log_good.txt
                                
                                if [ $skmail_counter -lt 60 ] 
                                then
                                        skmail_counter=`echo $skmail_counter|awk '{print $1 +1 }'`
                                else
                                        (echo "SUBJECT:$HRATE SKMINER-SKRAJ $AWS_account_owner $HOSTPUBIP running good at $HRATE /s ";uptime ; echo "=== good share === " ; cat /skminer/log/miner_log_good.txt ;echo "===== all logs ==== "; cat /skminer/log/miner_log_check.txt)  |sendmail iamsachinrajput@gmail.com
                echo "`date` mail sent for running good with rate $HRATE h/s " >> /skminer/log/miner_log_check.txt  
                                skmail_counter=0
                                fi 
                                
                                

                        else
                                echo " `date` ===== not good speed at rate of $HRATE ; so we will reboot `hostname` " >> /skminer/log/miner_log_bad.txt
                                #(echo "$HOSTPUBIP will be rebooted \n logs are below \n";uptime ; cat /skminer/log/miner_log_bad.txt /skminer/log/miner_log_good.txt /skminer/log/miner_log_check.txt ) |sendmail -v iamsachinrajput@gmail.com
                                (echo "SUBJECT:$HRATE SKMINER-SKRAJ $AWS_account_owner stop $HOSTPUBIP due to $HRATE /s " ; echo "BODY:$HOSTPUBIP will be rebooted \n logs are below \n" ; echo " ======= ` uptime ` ======= Few last full logs =============== ";tail -5 /skminer/log/miner_log_check.txt ;echo "=========  last 10 good logs ============== \n"; tail -10 /skminer/log/miner_log_good.txt;echo "======= last bad logs =========== \n" ; tail -10 /skminer/log/miner_log_bad.txt;echo "========= all logs good and full =========== \n\n" ; cat /skminer/log/miner_log_good.txt /skminer/log/miner_log_check.txt ) |sendmail -v iamsachinrajput@gmail.com

#(echo "SUBJECT: mail2 Miner will be stopped in $HOSTPUBIP due to low speed = $HRATE" ; cat /skminer/log/miner_log_bad.txt /skminer/log/miner_log_good.txt /skminer/log/miner_log_check.txt ) |sendmail iamsachinrajput@gmail.com

                                sleep 60
                                init 6
                                exit
                        fi

        fi
done
