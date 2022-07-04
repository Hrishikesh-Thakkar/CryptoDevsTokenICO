// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {

    ICryptoDevs cryptoDevsNFT;
    uint256 public maxTotalSupply = 10000 * 10**18;
    uint256 public tokenPerNFT = 10 * 10**18;
    uint256 public _price = 0.001 ether;
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
          cryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }
    
    function mint(uint256 amount) public payable {
        uint256 totalCashNeeded = amount*_price;
        require(msg.value >= totalCashNeeded, "More Eth Needed");
        uint256 amountWithDecimals = amount * 10**18;
        require(totalSupply()+amountWithDecimals<=maxTotalSupply ,"Not Enough Tokens");
        _mint(msg.sender,amountWithDecimals);
    }

    function claim() public {
        address sender = msg.sender;
        uint256 balance = cryptoDevsNFT.balanceOf(sender);
        require(balance > 0, "You Don't Own NFTs");
        uint256 amount = 0;
        for(uint256 i=0;i<balance;i++){
            uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(sender,i);
            if(!tokenIdsClaimed[tokenId]){
                amount+=1;
                tokenIdsClaimed[tokenId] = true;
            }
            amount+=1;
        }
        require(amount>0,"Already claimed");
        require(totalSupply()+tokenPerNFT*amount<=maxTotalSupply ,"Not Enough Tokens");
        _mint(sender,tokenPerNFT*amount);
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
      }

      receive() external payable {}

      fallback() external payable {}
}
