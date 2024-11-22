// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Kat is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _postIds;
    Counters.Counter private _commentIds;

    struct Post {
        uint256 id;
        address author;
        string content;
        string mediaUrl;
        uint256 likes;
        uint256 timestamp;
        bool exists;
    }

    struct Comment {
        uint256 id;
        uint256 postId;
        address author;
        string content;
        uint256 timestamp;
    }

    struct Profile {
        string username;
        string bio;
        string avatar;
        bool exists;
    }

    mapping(uint256 => Post) public posts;
    mapping(uint256 => Comment[]) public postComments;
    mapping(address => Profile) public profiles;
    mapping(address => uint256[]) public userPosts;
    mapping(address => mapping(address => bool)) public following;
    mapping(uint256 => mapping(address => bool)) public postLikes;

    event PostCreated(uint256 indexed postId, address indexed author, string content, string mediaUrl);
    event PostLiked(uint256 indexed postId, address indexed liker);
    event CommentAdded(uint256 indexed postId, uint256 indexed commentId, address indexed author, string content);
    event UserFollowed(address indexed follower, address indexed followed);
    event ProfileUpdated(address indexed user, string username, string bio);

    constructor() ERC721("KatSocial", "KAT") {}

    // Helper function to check if a post exists
    function postExists(uint256 _postId) public view returns (bool) {
        return posts[_postId].exists;
    }

    // Helper function to check if a profile exists
    function profileExists(address _user) public view returns (bool) {
        return profiles[_user].exists;
    }

    function createProfile(string memory _username, string memory _bio, string memory _avatar) public {
        require(!profiles[msg.sender].exists, "Profile already exists");
        require(bytes(_username).length > 0, "Username cannot be empty");
        profiles[msg.sender] = Profile(_username, _bio, _avatar, true);
        emit ProfileUpdated(msg.sender, _username, _bio);
    }

    function createPost(string memory _content, string memory _mediaUrl) public {
        require(profiles[msg.sender].exists, "Create a profile first");
        require(bytes(_content).length > 0, "Content cannot be empty");
        
        _postIds.increment();
        uint256 newPostId = _postIds.current();
        
        Post memory newPost = Post(
            newPostId,
            msg.sender,
            _content,
            _mediaUrl,
            0,
            block.timestamp,
            true  
        );
        
        posts[newPostId] = newPost;
        userPosts[msg.sender].push(newPostId);
        
        _safeMint(msg.sender, newPostId);
        
        emit PostCreated(newPostId, msg.sender, _content, _mediaUrl);
    }

    function likePost(uint256 _postId) public {
        require(postExists(_postId), "Post does not exist");
        require(!postLikes[_postId][msg.sender], "Already liked this post");
        
        posts[_postId].likes += 1;
        postLikes[_postId][msg.sender] = true;
        emit PostLiked(_postId, msg.sender);
    }

    function addComment(uint256 _postId, string memory _content) public {
        require(postExists(_postId), "Post does not exist");
        require(bytes(_content).length > 0, "Comment cannot be empty");

        _commentIds.increment();
        uint256 newCommentId = _commentIds.current();

        Comment memory newComment = Comment(
            newCommentId,
            _postId,
            msg.sender,
            _content,
            block.timestamp
        );
        
        postComments[_postId].push(newComment);
        emit CommentAdded(_postId, newCommentId, msg.sender, _content);
    }

    function followUser(address _userToFollow) public {
        require(msg.sender != _userToFollow, "Cannot follow yourself");
        require(profileExists(_userToFollow), "User to follow does not exist");
        require(!following[msg.sender][_userToFollow], "Already following this user");
        
        following[msg.sender][_userToFollow] = true;
        emit UserFollowed(msg.sender, _userToFollow);
    }

    function getUserPosts(address _user) public view returns (Post[] memory) {
        uint256[] memory postIds = userPosts[_user];
        Post[] memory userPostsArray = new Post[](postIds.length);
        
        for (uint256 i = 0; i < postIds.length; i++) {
            userPostsArray[i] = posts[postIds[i]];
        }
        
        return userPostsArray;
    }

    function getPostComments(uint256 _postId) public view returns (Comment[] memory) {
        require(postExists(_postId), "Post does not exist");
        return postComments[_postId];
    }

    function hasLikedPost(uint256 _postId, address _user) public view returns (bool) {
        return postLikes[_postId][_user];
    }
}