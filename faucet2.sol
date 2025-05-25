//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Faucet {
    uint public constant MAX_WITHDRAWAL = 0.1 ether;
    
    function withdraw(uint withdraw_amount) public {
        require(withdraw_amount <= MAX_WITHDRAWAL, "Amount exceeds maximum withdrawal");
        payable(msg.sender).transfer(withdraw_amount);
    }
    
    receive() external payable {}
}