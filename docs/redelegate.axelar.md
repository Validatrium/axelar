Tutorial created by Validatrium (more info on our projects at [validatrium.com](http://validatrium.com))

NOTE: *If you're not running an active set validator, progress to step 3*

## Steps:

 1. [Check available rewards](#1-check-available-rewards)
 3. [Withdraw commision](#2-withdraw-commision)
 4. [Withdraw rewards](#3-withdraw-rewards)
 5. [Check balance](#4-check-balance)
 6. [Delegate from your node](#5-delegate-from-node)

## 1. Check available rewards
*this only works if you're running active set validator!*

Run the following command: 
```bash
axelard query distribution rewards <your-wallet-address> <your-validator-address> 
```
The output should be like: 
```bash
rewards:
- amount: "2599999.9999999" # so there are rewards available to withdraw
  denom: uaxl
```

## 2. Withdraw commision
*this only works if you're running active set validator!*

Run the following command: 
```bash
axelard tx distribution withdraw-rewards <your-validator-address> --chain-id <chain-id>  --from <your-wallet-address> --gas=auto  --commission  --yes
```

## 3. Withdraw rewards
*this only works if you're running active set validator!*

Run the following command: 
```bash
axelard tx distribution withdraw-all-rewards --from <your-wallet-address> --chain-id <chain-id> --yes
```

## 4. Check balance
Run the following command: 
```bash
axelard query bank balances <your-wallet-address>
```
The output  should be like: 
```bash
balances:
- amount: "99999999"
  denom: uaxl
pagination:
  next_key: null
  total: "0"    
```

## 5. Delegate from node: 
Run the following command:
```bash
# do not transfer all available balance, you should leave 0.3-0.5 coins for future transactions 
axelard tx staking delegate  <validator-address> <amount-coins-to-transfer> --from <your-key-alias>



# this is an example: 
# $VALIDATOR = axelarvaloper1....
axelard tx staking delegate $VALIDATOR 99949999uaxl --from mykey 
```

Tutorial created by Validatrium (more info on our projects at [validatrium.com](http://validatrium.com))

If you have any additional questions regarding this tutorial, please join [Axelar official discord channel](https://discord.gg/rd93G625) and tag Validatrium members.
