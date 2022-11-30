#!/bin/bash

# Get data from website, select only the currencies lines
website=$(curl "https://www.stelareum.io/" | grep -Poz '<tr id="currency_[A-Z]+">(.|\n)+?</tr>' | tr '\n' ' ') 
website="${website//"</tr>"/$'</tr>\n'}"

# Creation of the files, containing the messages to be sent
date=$(date)
echo -e "Market Cap of Top 10 Cryptocurrencies : \n$date" >/home/ubuntu/project/list.txt
echo -e "Daily Market Cap Evolution of Top 10 Cryptocurrencies : \n$date" >/home/ubuntu/project/evolution.txt
URL="https://api.telegram.org/bot<YOURBOTTOKEN>/sendMessage"
declare totalmc="0"
echo -e "$website" >/home/ubuntu/project/website.txt
website=$(head -n 10 /home/ubuntu/project/website.txt)

# Get the infos for each top 10 crypto-currencies, and calculate the total market cap for our stats 
echo "$website" | while read line; do
        marketcap=$(echo "$line" | grep -Po '(supply.*>)\K([\d.,B]+)(?=</span)')
        raccourci=$(echo "$line" | grep -Po '(?<=title">).*?(?=</p>)')
        nom=$(echo "$line" | grep -Po '(?<=media-table-desc">).*?(?=</p>)')
        echo "$nom ($raccourci) : $marketcap\$" >>/home/ubuntu/project/list.txt

        value=$(echo "$marketcap" | sed 's/[.].*//')
        totalmc=`echo "scale=2; $totalmc+$value" | bc -l`
        echo $totalmc >/home/ubuntu/project/totalmc.txt

        # Evolution on the last 24h
        time=$(date +"%H:%M")
        if [ $time == '20:00' ]
                then
                percenthistory=$(echo "$line" | grep -Po '(percent_history.*>)\K([\d.%-]+)(?=</span)')
                echo "$nom ($raccourci) : $percenthistory" >> /home/ubuntu/project/evolution.txt
        fi
done

totalmc=$(head -n 1 /home/ubuntu/project/totalmc.txt)
textmessage=$(head -n 12 /home/ubuntu/project/list.txt) 
proportioncalc=$(tail -n 10 /home/ubuntu/project/list.txt)
echo -e "Market Cap Proportion (between the 1O first) : \nTotal of the Top 10 Market Cap : $totalmc">>/home/ubuntu/project/proportion.txt
echo "Raccourcis">/home/ubuntu/project/raccourcis.txt

# Calculation of the proportion of marketcap of each Cryptocurrency (between the 10 first), each hour
echo "$proportioncalc" | while read line; do
        mc=$(echo "$line" | grep -Po '( : )\K([\d.]+)(?=B)')
        mc=`echo "scale=2; $mc*100" | bc -l `
        part=`echo "scale=2; $mc/$totalmc" | bc -l `
        rac=$(echo "$line" | grep -Po '\([a-zA-Z]+\)')
        echo "$rac : $part%">>/home/ubuntu/project/proportion.txt
        echo $rac>>/home/ubuntu/project/raccourcis.txt
done

# Message that is sent every hour
echo $textmessage >> /home/ubuntu/project/data.txt # Data collection
curl -s -X POST $URL --data "text=$textmessage" --data "chat_id=<YOURCHATID>"
echo -e "\nMessage sent, check your Telegram"

# Daily Stat
time=$(date +"%H:%M")
if [ $time == '20:00' ]
        then

        # Last 24h evolution message
        evolutionmessage=$(head -n 11 /home/ubuntu/project/evolution.txt)
        curl -s -X POST $URL --data "text=$evolutionmessage" --data "chat_id=<YOURCHATID>"
        echo -e "\nMessage sent, check your Telegram"

        # We calculate the mean of the marketcap proportion of each Cryptocurrency
        prop=$(head -n 500 /home/ubuntu/project/proportion.txt)
        raccourcis=$(tail -n 10 /home/ubuntu/project/raccourcis.txt)
        echo -e "[DAILY STAT]\nMarket Cap Proportion Mean (between the 10 first Cryptocurrencies):">/home/ubuntu/project/mean.txt
        echo "$raccourcis" | while read line; do
                >temp.txt
                tes=$(echo "$prop" | grep "$line" | grep -Po "\K([\d.]+)")
                my_array=($(echo $tes | tr " " "\n"))
                for i in "${my_array[@]}"; do
                        echo "$i">>temp.txt
                done
                number=$(wc -l "temp.txt")
                number=$(echo $number | grep -Po '([\d]+)')
                array=$(head -n $number /home/ubuntu/project/temp.txt)
                declare sum="0"
                echo "$array" | while read line; do
                        sum=`echo "scale=2; $line+$sum" | bc -l`
                        echo $sum >/home/ubuntu/project/sum.txt
                done
                sum=$(head -n 1 /home/ubuntu/project/sum.txt)
                mean=`echo "scale=2; $sum/$number" | bc -l`
                echo "$line : $mean%">>/home/ubuntu/project/mean.txt
        done

        # Daily Stat, market cap proportion mean message 
        dailymessage==$(head -n 12 /home/ubuntu/project/mean.txt)
        curl -s -X POST $URL --data "text=$dailymessage" --data "chat_id=<YOURCHATID>"
        echo -e "\nMessage sent, check your Telegram"
        echo "">/home/ubuntu/project/proportion.txt
fi