Tutorial created by Validatrium (more info on our projects at [validatrium.com](http://validatrium.com))

## Steps:

1. [Prerequires](#Prerequires)
2. [Preparation](#preparation)
3. [Configuration](#Configuration)
4. [Sync from snapshot](#Sync-from-snapshot)
5. [Start axelard node](#Start-axelard-node)
6. [Working with keys](#Working-with-keys)
7. [Add usefull variables](#Add-usefull-variables)
8. [Start tofnd](#Start-tofnd)
9. [Start vald](#Start-vald)
10. [Additional links](#Additional-links)

##### Prerequires 
- Ubuntu 20.04 (tested on this OS)
- CPU: 16 cores
- RAM: 16GB
- 2TB+ drive

#### Preparation
```bash
# create user
adduser axelar
usermod -aG sudo axelar
su - axelar

# set required variables:
AXELARD_RELEASE=v0.26.5
TOFND_RELEASE=v0.10.1
CHAIN=axelar-testnet-lisbon-3
ACCOUNT=<your-node-name>

sudo apt install jq lz4

# create user
adduser axelar
usermod -aG sudo axelar
su - axelar

# install binaries 
wget https://github.com/axelarnetwork/axelar-core/releases/download/$AXELARD_RELEASE/axelard-linux-amd64-$AXELARD_RELEASE
wget https://github.com/axelarnetwork/tofnd/releases/download/$TOFND_RELEASE/tofnd-linux-amd64-$TOFND_RELEASE
mv axelard-linux-amd64-$AXELARD_RELEASE axelard
mv tofnd-linux-amd64-$TOFND_RELEASE tofnd

chmod +x axelard tofnd
sudo mv -t /usr/local/bin/ axelard tofnd

# check everything are installed
axelard version
tofnd --version
```
#### Configuration
```bash
# init home directory
axelard init $ACCOUNT --chain-id $CHAIN
# download configs
wget https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/configuration/config.toml -O $HOME/.axelar/config/config.toml
wget https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/configuration/app.toml -O $HOME/.axelar/config/app.toml
wget https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/resources/testnet/genesis.json -O $HOME/.axelar/config/genesis.json
wget https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/resources/testnet/seeds.toml -O $HOME/.axelar/config/seeds.toml

# set pruning options
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.axelar/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.axelar/config/app.toml 
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.axelar/config/app.toml 
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.axelar/config/app.toml

# set external ip to your config.json file
sed -i.bak 's/external_address = ""/external_address = "'"$(curl -s -4 ifconfig.co)"':26656"/g' $HOME/.axelar/config/config.toml
```
#### Sync from snapshot
```bash
URL=`curl -s -L https://quicksync.io/axelar.json | jq -r '.[] |select(.file=="axelartestnet-lisbon-3-pruned")|.url'`
echo $URL
cd $HOME/.axelar/
wget -O - $URL | lz4 -d | tar -xvf -
cd $HOME
```

##### Start Axelar node
```bash
sudo tee /etc/systemd/system/axelard-node.service > /dev/null <<EOF 
[Unit]
Description=axelar chain node
After=network-online.target 

[Service]
User=$USER
ExecStart=$(which axelard) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target 
EOF

sudo systemctl enable axelard-node
sudo systemctl start axelard-node

```

##### Working with keys
```bash
KEYRING=<enter your keyring here>
# create main wallet
axelard keys add $ACCOUNT
# create broadcaster 
axelard keys add broadcaster
# create tofnd
echo $KEYRING | tofnd -m create
# save tofnd mnemonic:
mv ~/.tofnd/export ~/.tofnd/import
cat ~/.tofnd/import

```

##### Add usefull variables 
```bash
ADDRESS=$(echo $KEYRING | axelard keys show -a $ACCOUNT)
VALIDATOR=$(echo $KEYRING | axelard keys show -a $ACCOUNT --bech val)
BROADCASTER=$(echo $KEYRING | axelard keys show -a broadcaster)

cat <<EOF >> $HOME/.bashrc
. <(axelard completion)
export CHAIN=$CHAIN
export ACCOUNT=$ACCOUNT
export ADDRESS=$ADDRESS
export VALIDATOR=$VALIDATOR
export BROADCASTER=$BROADCASTER
EOF
source $HOME/.bashrc

```

##### Start tofnd
```bash
sudo tee /etc/systemd/system/tofnd.service > /dev/null <<EOF 
[Unit]
Description=tofnd 
After=network-online.target 

[Service]
User=$USER
ExecStart=/bin/bash -c "echo $KEYRING | $(which tofnd) -m existing -d $HOME/.tofnd"
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target 
EOF

sudo systemctl enable tofnd
sudo systemctl start tofnd

```
##### Start Vald
```bash
sudo tee /etc/systemd/system/axelard-vald.service > /dev/null <<EOF 
[Unit]
Description=Vald daemon
# start after node&tofnd
After=network-online.target axelard-node.service tofnd.service

[Service]
User=axelar
# to ensure tofnd & chain node services are running
ExecStartPre=/bin/sleep 10
ExecStart=/usr/bin/bash -c 'echo $KEYRING | $(which axelard) vald-start \\
  --validator-addr $VALIDATOR \\
  --log_level debug \\
  --chain-id $CHAIN \\
  --from broadcaster'
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable axelard-vald
sudo systemctl start axelard-vald
```


## Additional links

#### [How to claim rewards and delegate them to your node via CLI](https://github.com/Validatrium/axelar/blob/main/docs/redelegate.axelar.md)
 
### Tutorial created by Validatrium (more info on our projects at [validatrium.com](http://validatrium.com))

If you have any additional questions regarding this tutorial, please join [Axelar official discord channel](https://discord.gg/rd93G625) and tag Validatrium members.
