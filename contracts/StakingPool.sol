// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//toDo: add libraries only if strictly needed

contract StakingPool is Ownable {
    /* ========== STATE VARIABLES ========== */

    IERC20 public stakingToken; //the address of the token to be staked by the users (same as the token given as a reward at the end of the staking period)
    uint256 public startStaking; //the beginning unix timestamp at which the staking pool will allow users to begin staking
    uint256 public endStaking; //the unix timestamp after which the users will not be able to stake their tokens anymore, and after which the rewards can be claimed

    uint256 public rewardTokensAmount; //the amount of tokens to distribute as reward to the partecipating users
    uint256 public stakedTokensTotal; //contains the total of the tokens staked by all the users
    //toDo: add support variables and data structures if needed
    uint256 public totalSecInStake; // sum of seconds in stake for all amounts of tokens
    uint256 public reward; // reward for each user
    uint256 public wMeanSeconds; // weighted average of seconds in stake for each user
    uint256 public wMeanAmount; // weighted average of amount in stake for each user

    struct Info {
        uint256 lastTimeStaked; // useful struct to manage users' infos
        uint256 tokenAmount;
        uint256 secondsInStaking;
        bool paid;
    }

    mapping(address => Info) userInfos; // mapping to assign struct to each user

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 rewardAmount);
    event Staked(address indexed user, uint256 stakedAmount);
    event Exit(
        address indexed user,
        uint256 stakedAmount,
        uint256 rewardAmount
    );

    /* ========== CONSTRUCTOR ========== */

    constructor(IERC20 _stakingToken) {
        stakingToken = IERC20(_stakingToken); // defining stakingToken
    }

    /* ========== FUNCTIONS ========== */

    function finalizePoolCreation(
        uint256 _startStaking,
        uint256 _periodInSec,
        uint256 _amountOfRewardsTokensToSend
    ) public {
        startStaking = _startStaking; // setting start staking
        endStaking = _startStaking + _periodInSec; // define staking period

        if (
            stakingToken.transferFrom(
                msg.sender,
                address(this),
                _amountOfRewardsTokensToSend
            ) // when if statement is verified: rewardTokensAmount = _amountOfRewardsTokensToSend
        ) {
            rewardTokensAmount = _amountOfRewardsTokensToSend;
            emit RewardAdded(_amountOfRewardsTokensToSend); // and event is emitted
        } else {
            // otherwise function is reverted
            revert();
        }
    }

    function stake(uint256 _amount) public checkPoolOpen {
        require(
            stakingToken.balanceOf(msg.sender) > _amount, // check to avoid user stakes more than his balance
            "Not enough tokens!"
        );

        if (stakingToken.transferFrom(msg.sender, address(this), _amount)) {
            // when if statement is verified
            userInfos[msg.sender].lastTimeStaked = block.timestamp; // I set struct variables
            userInfos[msg.sender].tokenAmount += _amount;
            userInfos[msg.sender].secondsInStaking = (endStaking -
                block.timestamp);

            stakedTokensTotal += _amount;
            totalSecInStake += (endStaking - block.timestamp); // I define these variables to calculate weighted means

            wMeanAmount =
                (userInfos[msg.sender].tokenAmount * 1000) / // Multipling token amount in stake of each user for 1000 beacause I can't use float numbers
                stakedTokensTotal;

            wMeanSeconds =
                (userInfos[msg.sender].secondsInStaking * 1000) / // Multipling seconds amount in stake of each user for 1000 beacause I can't use float numbers
                totalSecInStake;

            reward = (rewardTokensAmount * (wMeanAmount + wMeanSeconds)) / 2000; // Calculating reward as sum of 2 weighted means diveded for 2

            emit Staked(msg.sender, _amount); // event is emitted
        } else {
            revert(); // otherwise function is reverted
        }
    }

    function exit() public checkStakingFinished {
        require(
            userInfos[msg.sender].paid == false &&
                userInfos[msg.sender].lastTimeStaked > 0, // requirings to get rewarded
            "You already claimed"
        );
        uint256 unstakeAmount;

        unstakeAmount = reward + userInfos[msg.sender].tokenAmount; //defining unstake amount as sum of reward and staked tokens

        if (stakingToken.transfer(msg.sender, unstakeAmount)) {
            // when if statement is verified
            userInfos[msg.sender].paid = true;
            emit Exit(
                msg.sender,
                userInfos[msg.sender].tokenAmount,
                unstakeAmount
            ); // event is emitted
        } else {
            revert(); // otherwise function is reverted
        }
    }

    /* ========== VIEWS ========== */
    function timestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function generatePseudoRandomNumber(
        uint256 _seedNumber // generating pseudo random number from seed number
    ) public view returns (uint256 randomResult) {
        return (
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        _seedNumber
                    )
                )
            )
        );
    }

    /* ========== MODIFIERS ========== */

    modifier checkPoolOpen() {
        require(startStaking < block.timestamp, "Pool not open yet"); // this modifier avoids you stake before startStaking period
        _;
    }

    modifier checkStakingFinished() {
        // this modifier avoids you claim your reward before endStaking period
        require(block.timestamp > endStaking, "Locked");
        _;
    }
}
