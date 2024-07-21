## Project Title  
DegenToken ERC20 Contract with Loyalty Points

## Problem Statement
Create an ERC20 token named DegenToken with built-in functionality for loyalty points, allowing token holders to earn additional tokens based on the duration they hold the tokens. The contract should also include minting, transferring, burning,checking balance and redeeming tokens features.

## Prerequisites
Solidity ^0.8.18

OpenZeppelin Contracts v4.4.0 

## Description  
The DegenToken contract is an ERC20 token implementation with the following features:

1. Loyalty Points: Users earn loyalty points based on the duration they hold the tokens.
2. Minting: The owner can mint new tokens.
3. Transferring: Tokens can be transferred between users.
4. Burning: Users can burn their tokens.
5. Redeeming: Users can redeem tokens for specific items.
6. Check Balance: Checks token Balance of Caller.


## Getting Started

### Installing  
To run this program, you can use Remix, an online Solidity IDE. To get started, go to the Remix website at https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the "+" icon in the left-hand sidebar. Save the file with a .sol extension. Copy and paste the following code into the file:

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract DegenToken is ERC20, Ownable, ERC20Burnable {

    struct Loyalty {
        uint256 lastUpdated;
        uint256 loyaltyPoints;
    }

    mapping(address => Loyalty) private _loyaltyPoints;
    uint256 public constant LOYALTY_RATE = 1; // 1 token per day per token held

    event TokensMinted(address indexed to, uint256 amount);
    event TokensTransferred(address indexed from, address indexed to, uint256 amount);
    event TokensRedeemed(address indexed from, string item, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event LoyaltyPointsUpdated(address indexed user, uint256 loyaltyPoints);

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    function transferTokens(address recipient, uint256 amount) external {
        _updateLoyaltyPoints(msg.sender);
        _updateLoyaltyPoints(recipient);
        _transfer(_msgSender(), recipient, amount);
        emit TokensTransferred(msg.sender, recipient, amount);
    }

    function redeemTokens(string memory item, uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to redeem tokens.");
        _burn(msg.sender, amount);
        emit TokensRedeemed(msg.sender, item, amount);
    }

    function checkBalance() external view returns (uint256) {
        return balanceOf(msg.sender);
    }

    function burnTokens(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to burn tokens.");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    function checkLoyaltyPoints() external view returns (uint256) {
        return _loyaltyPoints[msg.sender].loyaltyPoints;
    }

    function claimLoyaltyTokens() external {
        _updateLoyaltyPoints(msg.sender);
        uint256 loyaltyPoints = _loyaltyPoints[msg.sender].loyaltyPoints;
        require(loyaltyPoints > 0, "No loyalty points to claim.");
        _loyaltyPoints[msg.sender].loyaltyPoints = 0;
        _mint(msg.sender, loyaltyPoints);
        emit LoyaltyPointsUpdated(msg.sender, 0);
    }

    function _updateLoyaltyPoints(address user) internal {
        Loyalty storage loyalty = _loyaltyPoints[user];
        uint256 daysHeld = (block.timestamp - loyalty.lastUpdated) / 1 days;
        uint256 newPoints = daysHeld * balanceOf(user) * LOYALTY_RATE;
        loyalty.loyaltyPoints += newPoints;
        loyalty.lastUpdated = block.timestamp;
        emit LoyaltyPointsUpdated(user, loyalty.loyaltyPoints);
    }
}


```

###  Executing program    
#### How to Run the Program      
1. Install the necessary dependencies using the following command:
npm install @openzeppelin/contracts
2. Compile the Solidity contract.
3. Deploy the contract using your preferred Ethereum development environment.  

#### For Remix:    
1. Open Remix IDE.  
2. Upload Game.sol.  
3. Compile and deploy the contract.  


## Authors  
Sandeep Kaur @Sandeep1925

## License  
This project is licensed under the MIT License - see the LICENSE.md file for details.  

We have established a solidity contract with this code. 
