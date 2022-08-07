// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

// Import this file to use console.log
import "hardhat/console.sol";

contract Rentable is Initializable {

    /* ======== ADDRESS ======== */
    /// @notice Creator of the flash claim contract
    address public creator;

    /// @notice Wallet with claim permission on the flash claim contract
    address public renter;

    /// @notice Denomination of current rental payment currency
    address public currency;

    /// @notice NFT up for rental contract
    address public nft;

    /* ======== UINT ======== */
    /// @notice ID of NFT up for rental contract
    uint256 public id;

    /// @notice Cost to rent NFT for the week
    uint256 public cost;

    /// @notice Contract start time
    uint256 public startTime;

    /* ======== MAPPING ======== */
    /// @notice Track if rent was paid during the current epoch
    mapping(uint256 => bool) public rentalPaid;

    /// @notice Rental payment during an epoch
    mapping(uint256 => uint256) public amountPaid;

    /// @notice Currency used for rental payment during an epoch
    mapping(uint256 => address) public currencyPaid;

    /// @notice Track ownership transfer approval permissions
    mapping(address => bool) public approval;

    /// @notice If rental is ended early repayments are tracked here
    mapping(address => mapping(address => uint256)) public repayment;

    /* ======== MODIFIER ======== */
    modifier isOwner {
        require(msg.sender == creator);
        _;
    }

    modifier isRenter {
        require(msg.sender == renter);
        _;
    }

    function initialize(
        address _creator,
        address _paymentCurrency,
        uint256 _price
    ) external initializer {
        creator = _creator;
        currency = _paymentCurrency;
        cost = _price;
        startTime = block.timestamp;
    }

    /* ======== OWNER CONTROLS ======== */
    /// @notice Owner deposits NFT to be rented out
    /// @dev Only one NFT can be deposited at a time
    function depositNFT(
        address _nft,
        uint256 _id
    ) external isOwner {
        require(nft == address(0));
        nft = _nft;
        id = _id;
        IERC721(_nft).transferFrom(msg.sender, address(this), _id);
    }

    /// @notice If the owner would like to change the payment currency.
    function updateCurrency(address _currency) external isOwner {
        require(renter == address(0));
        require(!rentalPaid[(block.timestamp - startTime) / 1 weeks]);
        currency = _currency;
    }

    /// @notice If the owner would like to change the cost of renting.
    function updateCost(uint _cost) external isOwner {
        require(renter == address(0));
        require(!rentalPaid[(block.timestamp - startTime) / 1 weeks]);
        cost = _cost;
    }

    /// @notice If the owner would like to claim rental proceeds.
    function claimRentalPayment(uint256 epoch) external isOwner {
        require(epoch > ((block.timestamp - startTime) / 1 weeks));
        uint256 payout = amountPaid[epoch];
        address currencyPayout = currencyPaid[epoch];
        delete amountPaid[epoch];
        delete currencyPaid[epoch];
        IERC20(currencyPayout).transferFrom(
            msg.sender, 
            address(this), 
            payout
        );
    }

    /// @notice Approve the transfer of ownership
    /// @dev This approves transfers of ownership over this rental contract AND the NFT
    function approveTransfer(address _addr) external isOwner {
        approval[_addr] = true;
    }

    /// @notice Trades the ownership of the contract AND underlying NFT
    function tradeUnderlyingNFT(address to) external {
        require(approval[msg.sender]);
        creator = to;
    }

    /// @notice Withdraws NFT
    /// @dev If there is an active rental, the payment is refunded
    function withdrawNFT() external isOwner {
        if(rentalPaid[(block.timestamp - startTime) / 1 weeks]) {
            repayment[currency][renter] += cost; 
        }
        IERC721(nft).transferFrom(address(this), msg.sender, id);
        nft = address(0);
        id = 0;
    }

    /* ======== RENTER CONTROLS ======== */
    /// @notice A new renter pays rental cost and receives renter powers.
    /// @param _new The address of new renter
    function newRenter(address _new) external {
        require(!rentalPaid[(block.timestamp - startTime) / 1 weeks]);
        IERC20(currency).transferFrom(msg.sender, address(this), cost);
        rentalPaid[(block.timestamp - startTime) / 1 weeks] = true;
        renter = _new;
    }

    /// @notice Renter holds control over NFT usage with the contract as a proxy operator
    /// @dev The function receives executes the desired action (passed in by the selector) and
    /// automatically approves the interaction contract. However, for any interaction it requires
    /// that the NFT is returned and held by this contract at the end of the transaction. 
    /// @param _nft Address of the NFT 
    /// @param _id ID of the NFT
    /// @param _interactionContract Contract being interacted with
    /// @param data Function selector and parameters
    function executeAction(
        address _nft, 
        uint256 _id, 
        address _interactionContract,
        bytes memory data
    ) external isRenter {
        IERC721(_nft).approve(_interactionContract, _id);
        require(rentalPaid[(block.timestamp - startTime) / 1 weeks]);
        (bool success, ) = address(_interactionContract).call(data);
        require(success);

        require(address(this) == IERC721(_nft).ownerOf(_id));
    }

    /// @notice In the case that a rental is terminated early, the renter is fully refunded
    /// @param _currency The currency in which rental payment was paid
    function claimCancelledPayment(address _currency) external {
        uint256 payout = repayment[currency][renter];
        delete repayment[currency][renter];
        IERC20(_currency).transfer(msg.sender, payout);
    }
}
