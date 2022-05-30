from brownie import StakingPool, accounts, config
from scripts.helpful_scripts import get_account
from scripts.deploy import deploy_StakingPool_and_stakingToken, KEPT_BALANCE


def test_exit():
    # Arrange
    account = get_account()
    StakingToken, stakingPool = deploy_StakingPool_and_stakingToken()

    # Act
    stakingPool.exit()

    # Assert
    assert StakingToken.balanceOf(account.address) == KEPT_BALANCE
    assert stakingPool.stakedTokensTotal == 0
