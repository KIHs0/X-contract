// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@openzeppelin/contracts/access/Ownable.sol";

contract X is Ownable {
    address internal tweetowner;

    constructor(address _ownerAddr) Ownable(_ownerAddr) {
        tweetowner = _ownerAddr;
    }

    struct tweet {
        uint256 id;
        address author;
        string content;
        uint256 likes;
        uint256 dislikes;
        uint256 timestamp;
    }
    mapping(address => tweet[]) public tweets;

    event TweetCreated(
        uint256 indexed id,
        address indexed author,
        string content,
        uint256 indexed timestamp
    );
    event TweetLikes(uint indexed id  , address indexed post , address indexed  liker, uint256 likescount);
    event TweetDisLikes(uint indexed id  , address indexed post , address indexed liker, uint256 likescount);

    uint256 MAX_TWEET_LENGTH = 256;

    modifier increaseTweetLength() {
        _checkOwner();
        _;
    }

    //----------------------------------login functions

    function increaseTweetLengthfx(uint256 ilength)
        external
        increaseTweetLength{
        MAX_TWEET_LENGTH = ilength;
    }

    function Post(string memory text) public {
        require(
            bytes(text).length < 256,
            "tweet cannot be longer than 256 characters"
        );
        tweet memory newtweets = tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: text,
            likes: 0,
            dislikes: 0,
            timestamp: block.timestamp
        });
        tweets[msg.sender].push(newtweets);
        emit TweetCreated(
            newtweets.id,
            newtweets.author,
            newtweets.content,
            newtweets.timestamp
        );
    }

    function getPost(address addr, uint256 i)
        public
        view
        returns (tweet memory){
        return tweets[addr][i];
    }

    function getAllPost(address addr) public view returns (tweet[] memory) {
        return tweets[addr];
    }

    function deletePost(address addr, uint256 i) public {
        delete tweets[addr][i];
    }

    function likepost(address post, uint256 i) public {
        require(tweets[post][i].id == i, "post doesnot found");
        tweets[post][i].likes++;

        emit TweetLikes(i, post, msg.sender, tweets[post][i].likes);
    }

    function dislikepost(address post, uint256 i) public {
        require(tweets[post][i].id == i, "post doesnot exist");
        require(tweets[post][i].likes > 0, "likes count is just 0");
        tweets[post][i].likes--;
        emit TweetDisLikes(i, post, msg.sender, tweets[post][i].likes);
    }

    function getalllikes(address post) public view returns (uint256) {
        uint256 alllikes = 0;
        for (uint256 i; i < tweets[post].length; i++) {
            if (tweets[post][i].author == post) {
                alllikes += tweets[post][i].likes;
            }
        }
        return alllikes;
    }
}
