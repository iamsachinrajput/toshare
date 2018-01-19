HOSTPUBIP=`ec2metadata --public-hostname|awk '{print $2}'`
AWS_account_owner=` ec2metadata |awk '/public-keys:/{print $NF}'|sed 's/..$//'`
echo "" > /skminer/log/miner_log_bad.txt 
echo "" > /skminer/log/miner_log_good.txt 
echo "" > /skminer/log/miner_log_check.txt
while [ 1 -eq 1 ]
do

SKMIN=`ps -eaf | grep -i minergate-cli | grep -iv grep |wc -l`
        if [ $SKMIN -lt 1 ]
        then
                echo "`date` ====== miner is not running so starting up " >> /skminer/log/miner_log_check.txt
                minergate-cli -user iamsachinrajput@gmail.com -xmr 4 2>> /skminer/log/miner_log_check.txt >> /skminer/log/miner_log_check.txt &
                #minergate-cli -user iamsachinrajput@gmail.com -dsh 4 2>> /skminer/log/miner_log_check.txt >> /skminer/log/miner_log_check.txt &
                #minergate-cli -user iamsachinrajput@gmail.com -dsh 4 &
                sleep 90
                HRATE=`tail /skminer/log/miner_log_check.txt | grep -i H/s | tail -1 | awk '{print int($(NF-1))}'`
                (echo "SUBJECT:$HRATE SKMINER-SKRAJ $AWS_account_owner $HOSTPUBIP started at $HRATE /s ";uptime ; echo "====== " ; cat /skminer/log/miner_log_check.txt)  |sendmail iamsachinrajput@gmail.com
                echo " mail sent for startup " >> /skminer/log/miner_log_check.txt
        else
                sleep 90
                HRATE=`tail /skminer/log/miner_log_check.txt | grep -i H/s | tail -1 | awk '{print int($(NF-1))}'`

                        if [ $HRATE -gt 1 ]
                        then
                                echo " `date` ===== running good at rate of $HRATE " >> /skminer/log/miner_log_good.txt

                        else
                                echo " `date` ===== not good speed at rate of $HRATE ; so we will reboot `hostname` " >> /skminer/log/miner_log_bad.txt
                                #(echo "$HOSTPUBIP will be rebooted \n logs are below \n";uptime ; cat /skminer/log/miner_log_bad.txt /skminer/log/miner_log_good.txt /skminer/log/miner_log_check.txt ) |sendmail -v iamsachinrajput@gmail.com
                                (echo "SUBJECT:$HRATE SKMINER-SKRAJ $AWS_account_owner stop $HOSTPUBIP due to $HRATE /s " ; echo "BODY:$HOSTPUBIP will be rebooted \n logs are below \n";uptime ; echo " ========================= ";tail -5 /skminer/log/miner_log_check.txt ;echo "======================= \n"; tail -10 /skminer/log/miner_log_good.txt;echo "================== \n" ; tail -10 /skminer/log/miner_log_bad.txt;echo "==================== \n\n" ;cat /skminer/log/miner_log_bad.txt /skminer/log/miner_log_good.txt /skminer/log/miner_log_check.txt ) |sendmail -v iamsachinrajput@gmail.com

#(echo "SUBJECT: mail2 Miner will be stopped in $HOSTPUBIP due to low speed = $HRATE" ; cat /skminer/log/miner_log_bad.txt /skminer/log/miner_log_good.txt /skminer/log/miner_log_check.txt ) |sendmail iamsachinrajput@gmail.com

sleep 60
init 0
                                exit
                        fi

        fi
done
