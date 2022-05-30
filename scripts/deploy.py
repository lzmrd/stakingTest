from brownie import StakingPool, stakingToken, accounts, network, config
from scripts.helpful_scripts import get_account
from web3 import Web3

KEPT_BALANCE = Web3.toWei(100, "ether")


def deploy_StakingPool_and_stakingToken():
    account = get_account()

    StakingToken = stakingToken.deploy({"from": account})

    stakingPool = StakingPool.deploy(
        StakingToken.address,
        {"from": account},
    )
    tx = StakingToken.transfer(
        stakingPool.address,
        StakingToken.totalSupply() - KEPT_BALANCE,
        {"from": account},
    )

    tx.wait(1)

    return StakingToken, stakingPool


def main():
    deploy_StakingPool_and_stakingToken()
