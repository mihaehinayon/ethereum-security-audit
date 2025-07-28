// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VulnerablePiggyBank
 * @dev VULNERABLE CONTRACT - DO NOT USE IN PRODUCTION
 * 
 * This contract contains multiple security vulnerabilities:
 * 1. Access Control Vulnerability - Anyone can withdraw all funds
 * 2. Missing Balance Tracking - Deposits are not tracked per user
 * 3. Syntax Error - Missing semicolon in constructor
 */
contract VulnerablePiggyBank {
    address public owner;
    
    constructor() { 
        owner = msg.sender; // Fixed: Added missing semicolon
    }
    
    /**
     * @dev Deposit function - accepts ETH but doesn't track who deposited what
     * VULNERABILITY: No balance tracking per user
     */
    function deposit() public payable {}
    
    /**
     * @dev Withdraw function - sends ALL contract balance to caller
     * CRITICAL VULNERABILITY: No access control - anyone can drain the contract
     */
    function withdraw() public { 
        payable(msg.sender).transfer(address(this).balance); 
    }
    
    /**
     * @dev Empty attack function placeholder
     */
    function attack() public {}
}