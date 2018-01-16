HOSTPUBIP=`hostname`
while [ 1 -eq 1 ]
do

SKMIN=`ps -eaf | grep -i minergate-cli | grep -iv grep |wc -l`
        if [ $SKMIN -lt 1 ]
        then
                echo "`date` ====== miner is not running so starting up " >> /skminer/log/miner_log_check.txt
                minergate-cli -user iamsachinrajput@gmail.com -xmr 4 2>> /skminer/log/miner_log_check.txt >> /skminer/log/miner_log_check.txt &
                #minergate-cli -user iamsachinrajput@gmail.com -dsh 4 &
                sleep 60
                HRATE=`tail /skminer/log/miner_log_check.txt | grep -i H/s | tail -1 | awk '{print int($(NF-1))}'`
                echo "SUBJECT:Miner is started in $HOSTPUBIP at rate of $HRATE per second " |sendmail iamsachinrajput@gmail.com
        else
                sleep 90
                HRATE=`tail /skminer/log/miner_log_check.txt | grep -i H/s | tail -1 | awk '{print int($(NF-1))}'`

                        if [ $HRATE -gt 2 ]
                        then
                                echo " `date` ===== running good at rate of $HRATE " >> /skminer/log/miner_log_good.txt

                        else
                                echo " `date` ===== not good speed at rate of $HRATE ; so we will reboot `hostname` " >> /skminer/log/miner_log_bad.txt
                                #(echo "$HOSTPUBIP will be rebooted \n logs are below \n";cat /skminer/log/miner_log_bad.txt /skminer/log/miner_log_good.txt /skminer/log/miner_log_check.txt ) |sendmail -v iamsachinrajput@gmail.com
                                (echo "SUBJECT:mail 1 Miner will be stopped in $HOSTPUBIP due to low speed = $HRATE";echo "FROM:iamsachinrajput@gmail.com";echo "$HOSTPUBIP will be rebooted \n logs are below \n";echo " ========================= ";tail -5 /skminer/log/miner_log_check.txt ;echo "======================= \n"; tail -10 /skminer/log/miner_log_good.txt;echo "================== \n" ; tail -10 /skminer/log/miner_log_bad.txt;echo "==================== \n\n" ;cat /skminer/log/miner_log_bad.txt /skminer/log/miner_log_good.txt /skminer/log/miner_log_check.txt ) |sendmail -v iamsachinrajput@gmail.com

#(echo "SUBJECT: mail2 Miner will be stopped in $HOSTPUBIP due to low speed = $HRATE" ; cat /skminer/log/miner_log_bad.txt /skminer/log/miner_log_good.txt /skminer/log/miner_log_check.txt ) |sendmail iamsachinrajput@gmail.com

sleep 60
init 0
                                exit
                        fi

        fi
done
