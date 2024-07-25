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

    // Mapping to store item names and their respective token costs
    mapping(string => uint256) public itemCosts;

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

    function redeemTokens(string memory item) external {
        uint256 itemCost = itemCosts[item];
        require(itemCost > 0, "Item does not exist.");
        require(balanceOf(msg.sender) >= itemCost, "Insufficient balance to redeem tokens for this item.");
        _burn(msg.sender, itemCost);
        emit TokensRedeemed(msg.sender, item, itemCost);
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

    // Function to set item costs, only owner can set this
    function setItemCost(string memory item, uint256 cost) external onlyOwner {
        itemCosts[item] = cost;
    }
}
