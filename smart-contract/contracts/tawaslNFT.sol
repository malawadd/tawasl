// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract TawaslNFT is ERC1155, Ownable {
    struct subscription {
        bool isValue;
        address subscriber;
        uint256 subscriptionDate;
    }

    struct meeting {
        string name;
        uint256 minted;
        uint256 cost;
        uint256 balance;
        uint256 startDate;
        address owner;
        bool isValue;
        bool isPublic;
        string uri;
    }

    string public name = "Tawasl NFT";
    string public symbol = "Tawasl";
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 subscriptionBalance;
    uint256 subscriptionFee;
    address USDC_ADDRESS = address(0xE6d51E332C1110dec7Ec645cf5FA7738FdF28233);
    IERC20 internal usdcToken;

    mapping(uint256 => meeting) meetings;
    mapping(address => subscription) subscriptions;

    event MeetingCreated(
        uint256 tokenId,
        string name,
        address owner,
        uint256 dateCreated,
        uint256 startDate,
        bool isPublic,
        uint256 cost
    );
    event Subscribed(address subscriber, uint256 subscriptionDate);

    constructor(uint256 fee) ERC1155("") {
        subscriptionFee = fee;
        usdcToken = IERC20(USDC_ADDRESS);
    }

    modifier isSubscribed() {
        require(
            subscriptions[msg.sender].isValue == true,
            "You are not subscribed."
        );
        require(
            block.timestamp - subscriptions[msg.sender].subscriptionDate <=
                (86400 * 365),
            "You are not subscribed"
        ); // 1 year Subscription
        _;
    }

    modifier notSubscribed() {
        if (subscriptions[msg.sender].isValue == true)
            require(
                block.timestamp - subscriptions[msg.sender].subscriptionDate >
                    (86400 * 365),
                "You are  subscribed"
            ); // //30 Day Subscription
        _;
    }

    modifier isMeeting(uint256 id) {
        require(meetings[id].isValue == true, "Meeting does not exist");
        _;
    }

    modifier isMeetingOwner(uint256 id) {
        require(meetings[id].isValue == true, "Not a valid meeting");
        require(
            meetings[id].owner == msg.sender,
            "You are not the owner of this meeting"
        );
        _;
    }

    function subscribed() public view returns (bool) {
        if (
            subscriptions[msg.sender].isValue == true &&
            block.timestamp - subscriptions[msg.sender].subscriptionDate <=
            (86400 * 365)
        ) return true;
        return false;
    }

    function subscribe() public notSubscribed {
        uint256 senderBalanceRequired = subscriptionFee * 10**6;
        require(
            usdcToken.balanceOf(msg.sender) >= senderBalanceRequired,
            "You do not have enough USDC to subscribe"
        );
        usdcToken.transferFrom(
            msg.sender,
            address(this),
            senderBalanceRequired
        );
        subscriptions[msg.sender].isValue = true;
        subscriptions[msg.sender].subscriptionDate = block.timestamp;
        subscriptions[msg.sender].subscriber = msg.sender;
        subscriptionBalance += senderBalanceRequired;
        emit Subscribed(msg.sender, block.timestamp);
    }

    function createMeeting(
        string calldata _name,
        string calldata _uri,
        uint256 startDate,
        bool isPublic,
        uint256 cost
    ) external returns (uint256 tokenId) {
        _tokenIdCounter.increment();
        uint256 index = _tokenIdCounter.current();
        meetings[index].name = _name;
        meetings[index].startDate = startDate;
        meetings[index].uri = _uri;
        meetings[index].owner = msg.sender;
        meetings[index].isPublic = isPublic;
        meetings[index].cost = cost;
        tokenId = _tokenIdCounter.current();
        _mint(msg.sender, tokenId, 1, " ");
        meetings[index].minted += 1;
        emit MeetingCreated(
            tokenId,
            _name,
            msg.sender,
            block.timestamp,
            startDate,
            isPublic,
            cost
        );
    }

    function sendInvite(uint256 tokenId, address invitee)
        external
        isMeetingOwner(tokenId)
    {
        _mint(invitee, tokenId, 1, "");
        meetings[tokenId].minted++;
    }

    function mintNFT(uint256 tokenId) external isMeeting(tokenId) {
        require(meetings[tokenId].isPublic == true, "Meeting not public");
        require(
            balanceOf(msg.sender, tokenId) == 0,
            "You already subscribed for this meeting"
        );
        if (meetings[tokenId].cost > 0) {
            uint256 senderBalanceRequired = meetings[tokenId].cost * 10**6;
            require(
                usdcToken.balanceOf(msg.sender) >= senderBalanceRequired,
                "You do not have enough USDC to subscribe"
            );
            usdcToken.transferFrom(
                msg.sender,
                address(this),
                senderBalanceRequired
            );
            meetings[tokenId].balance += senderBalanceRequired;
        }
        _mint(msg.sender, tokenId, 1, "");
        meetings[tokenId].minted++;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(meetings[tokenId].uri));
    }

    function setUri(uint256 tokenId, string calldata _uri)
        public
        isMeetingOwner(tokenId)
    {
        meetings[tokenId].uri = _uri;
    }

    function setSubscriptionFee(uint256 fee) public onlyOwner {
        subscriptionFee = fee;
    }

    function getSubscriptionFee() public view returns (uint256) {
        return subscriptionFee;
    }

    function withdraw(uint256 tokenId) public isMeetingOwner(tokenId) {
        require(meetings[tokenId].balance > 0, "No balance to withdraw");
        require(
            usdcToken.balanceOf(address(this)) >= meetings[tokenId].balance,
            "You do not have enough USDC to withdraw"
        );
        usdcToken.transfer(msg.sender, meetings[tokenId].balance);
        meetings[tokenId].balance = 0;
    }
}
