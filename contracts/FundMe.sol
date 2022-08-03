// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error FundMe__NotOwner();

/** 
* @title A contract for crowd funding
* @author Mors
* @notice This contract is to demo a sample funding contract
* @dev This implements price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private addressToAmountFunded;
    address[] private funders;

    address private immutable owner;
    uint256 public constant MINIMUM_USD = 50 * 10**18;
    AggregatorV3Interface public priceFeed;

    modifier onlyOwner {
        if (msg.sender != owner) revert FundMe__NotOwner();
        _;
    }

    //Functions Order:
    //constructor
    //receive
    //fallback
    //external
    //public
    //internal
    //private
    //view / pure
    
    constructor(address priceFeedAddress) {
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        owner = msg.sender;
    }

    /* receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    } */


    function fund() public payable {
        require(msg.value.getConversionRate(priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    
    
    function withdraw() payable onlyOwner public {
        address[] memory _funders = funders;
        uint256 lengthOfFunders = _funders.length;
        for (uint256 funderIndex=0; funderIndex < lengthOfFunders; ++funderIndex){
            address funder = _funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = owner.call{value: address(this).balance}("");
        require(callSuccess);
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    function getFunders(uint256 index) public view returns(address) {
        return funders[index];
    }

    function getPriceFeed() public view returns(AggregatorV3Interface) {
        return priceFeed;
    }

    function getAddressToAmountFunded(address funder) public view returns (uint256) {
        return addressToAmountFunded[funder];
    }

}



