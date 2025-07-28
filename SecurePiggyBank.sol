// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SecurePiggyBank
 * @dev Secure version of PiggyBank with multiple security improvements
 * 
 * Security Features:
 * 1. Access Control - Only owner can withdraw funds
 * 2. Balance Tracking - Individual user balances tracked
 * 3. Withdrawal Pattern - Two-step withdrawal process for safety
 * 4. Auto-Restore - Failed transfers don't lose user funds
 * 5. Reentrancy Protection - Effects before interactions pattern
 */
contract SecurePiggyBank {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public pendingWithdrawals;
    
    // Events for transparency and logging
    event Deposit(address indexed user, uint256 amount);
    event WithdrawalRequested(address indexed user, uint256 amount);
    event WithdrawalClaimed(address indexed user, uint256 amount);
    event TransferFailed(address indexed user, uint256 amount);
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Access control modifier - only owner can call protected functions
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    /**
     * @dev Deposit function - tracks individual user balances
     * @notice Users can deposit ETH and their balance is recorded
     */
    function deposit() public payable {
        require(msg.value > 0, "Cannot deposit 0 ETH");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Step 1: Request withdrawal - moves balance to pending (safe operation)
     * @notice Only owner can withdraw, but only their own deposited funds
     */
    function withdraw() public onlyOwner {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        // Effects before interactions - update state first
        balances[msg.sender] = 0;
        pendingWithdrawals[msg.sender] += amount;
        
        emit WithdrawalRequested(msg.sender, amount);
    }
    
    /**
     * @dev Step 2: Claim withdrawal - transfers ETH with auto-restore on failure
     * @notice Anyone can call this to claim their pending withdrawals
     */
    function claimWithdrawal() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Nothing to claim");
        
        // Clear pending first (effects before interactions)
        pendingWithdrawals[msg.sender] = 0;
        
        // Attempt transfer with error handling
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            // Auto-restore on failure - user doesn't lose funds
            pendingWithdrawals[msg.sender] = amount;
            emit TransferFailed(msg.sender, amount);
            revert("Transfer failed, please try again");
        }
        
        emit WithdrawalClaimed(msg.sender, amount);
    }
    
    /**
     * @dev Get caller's current balance
     * @return Current balance of the caller
     */
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    
    /**
     * @dev Get caller's pending withdrawal amount
     * @return Pending withdrawal amount for the caller
     */
    function getPendingWithdrawal() public view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }
    
    /**
     * @dev Get total contract balance
     * @return Total ETH held by the contract
     */
    function getTotalBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Emergency function to transfer ownership (optional security feature)
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Cannot transfer to zero address");
        owner = newOwner;
    }
}