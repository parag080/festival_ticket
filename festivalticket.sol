// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<=0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FestivalTicket is ERC721Enumerable, Ownable {
    uint256 public maxTickets = 1000;
    uint256 public ticketPrice = 1 ether; // Fixed ticket price in wei
    uint256 public maxTicketPrice = 110 * ticketPrice / 100; // 110% of the previous sale price

    uint256 public organizerFeePercentage = 5; // Organizer's fee in percentage

    constructor() ERC721("FestivalTicket", "FT") {}

    function buyTicket() external payable {
        require(totalSupply() < maxTickets, "No more tickets available");
        require(msg.value >= ticketPrice, "Insufficient funds sent");

        _mint(msg.sender, totalSupply() + 1);
    }

    function setTicketPrice(uint256 _newPrice) external onlyOwner {
        maxTicketPrice = 110 * _newPrice / 100;
        ticketPrice = _newPrice;
    }

    function sellTicket(uint256 tokenId, uint256 newPrice) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner of the ticket");
        require(newPrice <= maxTicketPrice, "Price exceeds the maximum allowed");

        _approve(address(this), tokenId);
        safeTransferFrom(msg.sender, address(this), tokenId);

        // Calculate the organizer's fee
        uint256 organizerFee = (newPrice * organizerFeePercentage) / 100;
        uint256 sellerProceeds = newPrice - organizerFee;

        // Transfer funds to the seller and organizer
        payable(msg.sender).transfer(sellerProceeds);
        payable(owner()).transfer(organizerFee);
    }
}
