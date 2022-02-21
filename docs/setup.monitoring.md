# Setup Telegram Monitoring for Axelar Node

## Notifications you will recieve with this config
- free disk space is less than 20% and 10% *(low disk space notification)*
- height is not changing (network connection error notification)
- axelard process is not running (node down notification)
- axelard-vald process is not running (validator not signing blocks notification)
- tofnd is not running (tofn-daemon not running notification)


## Prerequires 

- root account on server
- telegram bot token
- reciever telegram id

## Setup

### Create telegram bot

In this guide we won't focus on creating telegram.
You can follow [this instruction](https://marketplace.creatio.com/sites/marketplace/files/app-guide/Instructions._Telegram_bot_1.pdf)

### Get reciever telegram id
Follow [this guide](https://www.wikihow.com/Know-Chat-ID-on-Telegram-on-Android#:~:text=Locate%20%22Chat.%22%20It's%20about,Last%20Name%2C%20and%20your%20Username.&text=Note%20the%20number%20next%20to,is%20your%20personal%20Chat%20ID) to get your telegram id: 

### How to Setup monitoring
```bash
# install required packeges: 
apt install -y monit jq

# important this to run this command from root home dir
cd /root 
git clone https://github.com/Validatrium/axelar.git
cd axelar

echo include '/root/axelar/conf/*' >> /etc/monit/monitrc

## IF YOU HAVE A DIFFERENT RPC PORT (edit 'height.sh' file, to recieve height notifications)
#replace with your rpc address: (example: localhost:26657)
RPC="localhost:26657"

# edit telegram.conf, replacce with your values to recieve alerts
TOKEN=<TOKEN>
CHATID=<YOUR-ID>

# check if you setup telegram notifications correctly: 
bin/sendtelegram -m 'hi there!' -c telegram.conf
# restart monitoring tool
service monit restart
```

### you can also find more monit docs [here](https://mmonit.com/monit/documentation/monit.html)
