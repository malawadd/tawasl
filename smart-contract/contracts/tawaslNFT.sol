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

    mapping(uint256 => meeting) _meetings;
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
        _;
    }

    modifier isMeeting() {
        _;
    }

    modifier isMeetingOwner() {
        _;
    }

    function subscribed() public view returns (bool) {}

    function subscribe() public notSubscribed {}

    function createMeeting() external returns (uint256 tokenId) {}

    function mintNFT(uint256 tokenId) external isMeeting(tokenId) {}

    function uri(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {}

    function setUri() public isMeetingOwner(tokenId) {}

    function setSubscriptionFee() public onlyOwner {}

    function getSubscriptionFee() public view returns (uint256) {}

    function withdraw() public isMeetingOwner(tokenId) {}
}
