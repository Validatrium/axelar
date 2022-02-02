Tutorial created by Validatrium (more info on our projects at [validatrium.com](http://validatrium.com))

**NOTE:** *all wallet keys and mnemonics generated in this guide are fake, you should use your own.*

*keep your mnemonic phrases safe and never provide them to anyone!*

## Steps:

 1. [Prerequires (minimal, off docs)](#1-prerequires-minimal-off-docs)
 2. [Open Port requirements (default settings)](#2-open-port-requirements-default-settings)
 3. [About this guide](#3-about-this-guide)
    - [snapshot download link](#snapshot-download-link)
 4. [Install](#4-install)
    - [preparation](#preparation)
    - [working with keys](#working-with-keys)
    - [start tofnd](#start-tofnd)
    - [setup&run validator](#setuprun-validator)
 5. [Additional links](#5-additional-links)

## This guide works only with currently latest update:
`git: v0.9, core: v0.13.2, tofnd: v0.8.2`

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
This is manual setup with binaries. It's different than official installer.
There are 3 processess need to be running: 
tofnd, axelard node, axelard validator.
For all of them I create service file


### snapshot download link
`wget https://snap.validatrium.club/axelar/201066.data.tar.gz` # current snap size is 30GB

## 4. Install

#### preparation
```bash
# install jq 
sudo apt install jq

# download repository ( need to grap configs )
git clone https://github.com/axelarnetwork/axelarate-community.git 
cd axelarate-community
git checkout v0.9.1

# download binaries
curl  "https://axelar-releases.s3.us-east-2.amazonaws.com/axelard/v0.13.2/axelard-linux-amd64-v0.13.2" -o /usr/local/bin/axelard
curl -s --fail https://axelar-releases.s3.us-east-2.amazonaws.com/tofnd/v0.8.2/tofnd-linux-amd64-v0.8.2 -o /usr/local/bin/tofnd
chmod +x /usr/local/bin/axelard
chmod +x /usr/local/bin/tofnd

# insert usefull variables 
## replace <node-name> with your value
echo 'export ACCOUNT=<node-name>' >> $HOME/.bashrc
echo 'export CHAIN=axelar-testnet-lisbon-2' >> $HOME/.bashrc
source $HOME/.bashrc

axelard init $ACCOUNT --chain-id $CHAIN

# download genesis file
curl -s --fail https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json -o $HOME/.axelar/config/genesis.json
# download latest seeds
curl -s --fail https://axelar-testnet.s3.us-east-2.amazonaws.com/seeds.txt -o $HOME/.axelar/config/seeds.txt
# copy default settings from official repo
cp axelarate-community/join/config.toml $HOME/.axelar/config/  
cp axelarate-community/join/app.toml $HOME/.axelar/config/

# enter seeds to your config.json file
# will be replaced by 'sed' later
cat $HOME/.axelar/config/seeds.txt
nano $HOME/.axelar/config/config.json # paste seeds inside

# enter 'external_address="<your-external-ip:26656>"' 

# snapshot height=201066
# download 
wget https://snap.validatrium.club/axelar/201066.data.tar.gz
# remove old data
rm -rf $HOME/.axelar/data
# extract all
tar -xf 201066.data.tar.gz -C $HOME/.axelar

# create service file: 
cat > /etc/systemd/system/axelar-node.service << EOF
[Unit]
Description=axelard-node
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/axelard start
Restart=always
RestartSec=3
LimitNOFILE=16384
MemoryMax=8G
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF


systemctl enable axelar-node.service
systemctl start axelar-node

# check axelar-node logs:
journalctl -u axelar-node -f
```
####  Working with keys: 
```bash
# create main key:
axelard keys add $ACCOUNT

## example of output. Save it! ## this key is just generated. It's absolutely useless. 
- name: Test2
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
cat > /etc/systemd/system/tofnd.service << EOF
[Unit]
Description=tofnd
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/bin/sh -c 'echo <tofnd password> | tofnd -m existing -d $HOME/.axelar/.tofnd'
Restart=always
RestartSec=3
LimitNOFILE=16384
MemoryMax=4G
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

systemctl enable tofnd.service 
systemctl start tofnd.service
```


#### Setup&Run validator
```bash
# copy 'broadcaster' key to validator
axelard keys add broadcaster --recover --home $HOME/.axelar/.vald  --keyring-backend test   # insert a mnemonic from first account you created

# copy configs: 
cp $HOME/.axelar/config/config.toml $HOME/.axelar/.vald/config/config.toml
cp $HOME/.axelar/config/app.toml $HOME/.axelar/.vald/config/app.toml
cp $HOME/.axelar/config/genesis.json $HOME/.axelar/.vald/config/genesis.json

cat > /etc/systemd/system/axelard-val.service << EOF
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

systemctl enable axelard-val.service
systemctl start axelard-val.service

```

```
#### !! TODO !! 
- script optimization :)
 ```

## 5. Additional links

#### [How to claim rewards and delegate them to your node via CLI](https://gist.github.com/Validatrium/faf63de0dda2298c4d00349d1612c548)
 
### Tutorial created by Validatrium (more info on our projects at [validatrium.com](http://validatrium.com))

If you have any additional questions regarding this tutorial, please join [Axelar official discord channel](https://discord.gg/rd93G625) and tag Validatrium members.
