# stakingTest

## Requirements

* Staking pool has to be able to receive users' transfers of a certain ERC20 during a fixed period. 
After that period, the smart contract has to transfer back to users their token plus a reward of the same token.
* The reward has to be transfered from the owner to the smart contract before the staking period.
* A user can call "stake" function every time he wants(last timestamp will be used to calculate the reward).
* Each user will be rewarded with an amount of token directly proportional to the amount of token he staked and time passed for his tokens in staking 
in relation to total time of staking.
* A user can withdraw his funds calling "exit" function
* All the reward tokens have to be send to stakers at the end of staking period.

* Create a pseudorandom function



