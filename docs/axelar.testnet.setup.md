Tutorial created by Validatrium (more info on our projects at [validatrium.com](http://validatrium.com))

**NOTE:** *all wallet keys and mnemonics generated in this guide are fake, you should use your own.*

*keep your mnemonic phrases safe and never provide them to anyone!*

## Steps:

 1. [Prerequires (minimal, off docs)](#1-prerequires-minimal-off-docs)
 2. [Open Port requirements (default settings)](#2-open-port-requirements-default-settings)
 3. [About this guide](#3-about-this-guide)
    - [snapshots download link](#snapshots-link)
 4. [Install](#4-install)
    - [preparation](#preparation)
    - [working with keys](#working-with-keys)
    - [start tofnd](#start-tofnd)
    - [setup&run validator](#setuprun-validator)
 5. [Additional links](#5-additional-links)

## This guide works only with currently latest update:
`git: v0.9, core: v0.17.0, tofnd: v0.8.2`

### 1. Prerequires (minimal, off docs): 
- Ubuntu 20.04 (tested on this OS)
- CPU: 16 cores
- RAM: 16GB
- 2TB+ drive

### 2. Open Port requirements (default settings):
```bash
# tofnd 
50051/tcp - external 
# axelard
6060/tcp - local
26656/tcp - external
26657/tcp - external
9090/tcp6 - external
9091/tcp6 - external
26660/tcp6 - external
1317/tcp6 - external
```

### 3. about this guide: 
This is manual setup with binaries. It's different than official auto-installer.
There are 3 processess need to be running: 
tofnd, axelard node, axelard validator.
For all of them I create service file


### snapshots link
https://quicksync.io/networks/axelar.html

## 4. Install

#### preparation
```bash
# install jq 
sudo apt install jq lz4
# create custom sudo user
adduser axelar
usermod -aG sudo axelar
su - axelar

# download repository ( need to grab configs )
git clone https://github.com/axelarnetwork/axelarate-community.git 

# download binaries
sudo curl  "https://axelar-releases.s3.us-east-2.amazonaws.com/axelard/v0.17.0/axelard-linux-amd64-v0.17.0" -o /usr/local/bin/axelard
sudo curl -s --fail https://axelar-releases.s3.us-east-2.amazonaws.com/tofnd/v0.8.2/tofnd-linux-amd64-v0.8.2 -o /usr/local/bin/tofnd
sudo chmod +x /usr/local/bin/axelard
sudo chmod +x /usr/local/bin/tofnd

# insert usefull variables 
## replace <node-name> with your value
echo 'export ACCOUNT=<node-name>' >> $HOME/.bashrc
echo 'export CHAIN=axelar-testnet-lisbon-3' >> $HOME/.bashrc
source $HOME/.bashrc

axelard init $ACCOUNT --chain-id $CHAIN

# download genesis file
curl -s --fail https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json -o $HOME/.axelar/config/genesis.json
# download latest seeds
curl -s --fail https://axelar-testnet.s3.us-east-2.amazonaws.com/seeds.txt -o $HOME/.axelar/config/seeds.txt
# copy recomended settings from official repo
cp axelarate-community/configuration/config.toml $HOME/.axelar/config/  
cp axelarate-community/configuration/app.toml $HOME/.axelar/config/

# enter seeds to your config.json file
sed -i.bak 's/seeds = \"\"/seeds = \"'$(cat $HOME/.axelar/config/seeds.txt)'\"/g' $HOME/.axelar/config/config.toml

# set external ip to your config.json file
sed -i.bak 's/external_address = \"\"/external_address = \"'"$(curl -4 ifconfig.co)"':26656\"/g' $HOME/.axelar/config/config.toml


# download latest snapshot from https://quicksync.io/networks/axelar.html
# in my case it will be:
wget https://dl2.quicksync.io/axelartestnet-lisbon-3-pruned.20220209.0750.tar.lz4
# remove old data
rm -rf $HOME/.axelar/data
# extract all
lz4 -dc --no-sparse axelartestnet-lisbon-3-pruned.20220209.0750.tar.lz4 | tar xfC - $HOME/.axelar/
chown $USER:$USER $HOME/.axelar/data -R


# create service file: 
sudo bash -c 'cat > /etc/systemd/system/axelard-node.service << EOF
[Unit]
Description=axelard-node
After=network-online.target

[Service]
User=axelar
ExecStart=/usr/local/bin/axelard start
Restart=always
RestartSec=3
LimitNOFILE=16384
MemoryMax=8G
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl enable axelard-node.service
sudo systemctl start axelard-node

# check axelar-node logs:
journalctl -u axelard-node -f
```
####  Working with keys: 
```bash
# create main key:
axelard keys add $ACCOUNT

## example of output. Save it! ## this key is just generated. It's absolutely useless. 
- name: Test
  type: local
  address: axelar1f2fkstrhn0rg60fg2d6epk3t4pjcwhp9850mc3
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"A7UGGaxobO/uEsIKxIctqKSvHBz1lFwq5AjwarEle7lh"}'
  mnemonic: ""


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

	brand cost notable stand robot token illegal roast soccer gentle sign business protect emerge occur balcony wire music ill math minimum home rally pause
######

# create 1 more key 
axelard keys add broadcaster 

## example of output. Save it! ## this key is just generated. It's absolutely useless. 
# ============
- name: broadcaster
  type: local
  address: axelar1urzr89ngaq3s9gcy5xgurj0dxmt8hcphssnac5
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"Agr4A5tou0TpicPRR8Oc91+Zd20rmSFdtSr2sJo3XnZK"}'
  mnemonic: ""
 
**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

pottery dinosaur tobacco series spawn lumber connect video cry powder island large point journey thank main someone remove youth amused nurse mad lift use
# ==============

# save some useful variables: 
## replace <value> with your value :D 
echo 'export ADDRESS=<insert-wallet-addr>' >> $HOME/.bashrc
echo 'export BROADCASTER=<insert-broadcater-add>' >> $HOME/.bashrc
source $HOME/.bashrc
# use to get it axelard keys show $ACCOUNT -a --bech val
echo 'export VALIDATOR=<insert-validator-addr>' >> $HOME/.bashrc 
source $HOME/.bashrc

## create tofnd key: 
tofnd -m create -d $HOME/.axelar/.tofnd
mv $HOME/.axelar/.tofnd/export $HOME/.axelar/.tofnd/import

#### SAY TOFND MNEMONIC !!! ### 
cat $HOME/.axelar/.tofnd/import
```

#### start tofnd
```bash
# replace <tofnd password> with your password
sudo bash -c "cat > /etc/systemd/system/tofnd.service << EOF
[Unit]
Description=tofnd
After=network-online.target

[Service]
User=axelar
ExecStart=/usr/bin/sh -c 'echo <tofnd password> | tofnd -m existing -d $HOME/.axelar/.tofnd'
Restart=always
RestartSec=3
LimitNOFILE=16384
MemoryMax=4G
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl enable tofnd.service 
sudo systemctl start tofnd.service
# you can check logs by running:
journalctl -u tofnd -f
```


#### Setup&Run validator
```bash
# copy 'broadcaster' key to validator
axelard keys add broadcaster --recover --home $HOME/.axelar/.vald  --keyring-backend test   # insert a mnemonic from broadcaster account you created

# copy configs: 
cp $HOME/.axelar/config/config.toml $HOME/.axelar/.vald/config/config.toml
cp $HOME/.axelar/config/app.toml $HOME/.axelar/.vald/config/app.toml
cp $HOME/.axelar/config/genesis.json $HOME/.axelar/.vald/config/genesis.json

cat > axelard-val.service << EOF
[Unit]
Description=axelard-val
After=network-online.target

[Service]
User=$USER
ExecStart=axelard vald-start --tofnd-host localhost --node http://localhost:26657 --home $HOME/.axelar/.vald --validator-addr $VALIDATOR --log_level debug --chain-id $CHAIN --keyring-backend test
Restart=always
RestartSec=3
LimitNOFILE=16384
MemoryMax=4G
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

sudo mv axelard-val.service /etc/systemd/system

sudo systemctl enable axelard-val.service
sudo systemctl start axelard-val.service
# you can check logs by running: 
journalctl -u axelard-val -f
```

## 5. Additional links

#### [How to claim rewards and delegate them to your node via CLI](https://github.com/Validatrium/axelar/blob/main/docs/redelegate.axelar.md)
 
### Tutorial created by Validatrium (more info on our projects at [validatrium.com](http://validatrium.com))

If you have any additional questions regarding this tutorial, please join [Axelar official discord channel](https://discord.gg/rd93G625) and tag Validatrium members.
