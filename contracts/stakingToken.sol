pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract stakingToken is ERC20 {
    constructor() public ERC20("stakingToken", "SKT") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}
