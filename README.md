# Market-Cap-Evolution_OS-project

This is my project created as part of an Operating Systems course. 
It offers to send you a notification every hour on Telegram from a bot, to keep you updated with the marketcap of the top 10 Cryptocurrencies. 

I am scrapping the datas of https://www.stelareum.io/ in order to get all the infos I need. You can use this script to receive all the infos directly in a Telegram message. You also get a Daily Statistic of the 24h evolution, and the marketcap proportion mean of each cryptocurrency. 

You can host this script on your machine, or on any remote server. 

Don't forget to change your Bot Token <YOURBOTTOKEN> and the Chat ID <YOURCHATID> of the conversation you want to receive the message on. 
Make the script executable with the chmod command. 
Use a cronjob to make it run every hour : 

0 */1 * * * <Path to your script>

You're done ! Enjoy the spam from your bot.