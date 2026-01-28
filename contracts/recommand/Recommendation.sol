// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
contract Recommendation is AccessControlUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable {
    // 拥有合约升级、参数配置权限。
    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");
    address private genesisAddress;
    struct UserInfo {
        address referrer; // 推荐人
        uint256 registrationTime;
        address[] referrals; // 直接推荐的下级
    }
    uint256 maxChainLength;
    
    mapping(address => UserInfo) public users;
    mapping(address => address[]) public referralChains;
    
    event ReferralRegistered(address  user, address[] referralChain,uint256 timestamp);


    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override onlyRole(MANAGE_ROLE) {}

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _genesisAddress,address admin,uint256 _maxChainLength) public initializer {
        require(_genesisAddress != address(0), "genesis zero");
        genesisAddress = _genesisAddress;
        __AccessControl_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        _grantRole(MANAGE_ROLE, admin);
        _grantRole(DEFAULT_ADMIN_ROLE, admin); 
        _setRoleAdmin(MANAGE_ROLE, DEFAULT_ADMIN_ROLE); 
        maxChainLength = _maxChainLength;
    }
    // 注册时
    function register(address referrerAddress) external {
        address user = msg.sender;
        
        require(user != referrerAddress, "Cannot refer yourself");
        require(users[user].referrer == address(0), "Already registered");
        require(referrerAddress == genesisAddress || users[referrerAddress].referrer != address(0), "Referrer not registered");
        
        // 设置用户信息
        users[user] = UserInfo({
            referrer: referrerAddress,
            registrationTime: block.timestamp,
            referrals: new address[](0)
        });
        
        // 更新推荐人的直接推荐列表
        if (referrerAddress != address(0)) {
            users[referrerAddress].referrals.push(user);
        }
        uint256 length = 0;
        address temp = referrerAddress;
        while(temp != address(0) && length  <= maxChainLength ){
            length++;
            temp = users[temp].referrer;
        }

        address[] memory chain = new address[](length);
        address current = referrerAddress;

        uint256 i = 0;
        while(current != address(0)){
            require(referralChains[msg.sender].length <= maxChainLength, "The depth of the referral chain has been exceeded");
            chain[i] = current;
            current = users[current].referrer;
            i++;
        }
        
        referralChains[user] = chain;
        
        emit ReferralRegistered(user,referralChains[user],block.timestamp);
    }
    
    // 获取用户的完整推荐信息
    function getUserInfo(address user) external view returns (
        address referrer,
        uint256 registrationTime,
        address[] memory directReferrals,
        address[] memory referralChain
    ) {
        UserInfo storage info = users[user];
        return (
            info.referrer,
            info.registrationTime,
            info.referrals,
            referralChains[user]
        );
    }

    function getUserReferralChains(address user) external view returns(address[] memory) {
        return referralChains[user];
    }

    function getGenesisAddress() public view returns (address) {
        return genesisAddress;
    }

    

}