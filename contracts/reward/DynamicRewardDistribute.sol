// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";



contract DynamicRewardDistribute is
    Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    bool public funSwitch;

    bytes32 public DOMAIN_SEPARATOR;

    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Permit(address user,address token,uint256 accountId,uint256 amount,uint256 fee,uint256 nonce,uint256 deadline,uint256 typeNum)"
            )
        );
    bytes32 private constant PERMIT_TYPEHASH_ERC20 =
            keccak256(
                abi.encodePacked(
                    "Permit(address token,uint256 amount,uint256 fee,uint256 nonce)"
                )
            );

    address public signer;
    address feeReceiver;
    address public rewardAddress;
    address public operator;
    mapping(address => uint) public noncesERC20;

    mapping(address => uint) public nonces;

    
    event ReleaseReward(address userAddr,address token,uint256 amount,uint256 fee,address rewardAddress,uint256 createTime);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(MANAGE_ROLE) {}

    function initialize(address _signer,address _feeReceiver,address _rewardAddress,address _operator) public initializer {
        __AccessControlEnumerable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);

        signer = _signer;
        feeReceiver = _feeReceiver;
        rewardAddress = _rewardAddress;
        operator = _operator;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("DynamicRewardDistribute")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    receive() external payable {}

    function batchGrantRole(
        bytes32 role,
        address[] calldata accounts
    ) public onlyRole(getRoleAdmin(role)) {
        for (uint i = 0; i < accounts.length; i++) {
            _grantRole(role, accounts[i]);
        }
    }

    function batchRevokeRole(
        bytes32 role,
        address[] calldata accounts
    ) public onlyRole(getRoleAdmin(role)) {
        for (uint i = 0; i < accounts.length; i++) {
            _revokeRole(role, accounts[i]);
        }
    }

    function queryRoles(bytes32 role) public view returns (address[] memory) {
        uint roleNum = getRoleMemberCount(role);
        address[] memory accounts = new address[](roleNum);
        for (uint i = 0; i < roleNum; i++) {
            accounts[i] = getRoleMember(role, i);
        }
        return accounts;
    }

    function balance(address token) public view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20Upgradeable(token).balanceOf(address(this));
    }

    function withdrawErc20(
        address token,
        address to,
        uint256 amount
    ) public onlyRole(MANAGE_ROLE) {
        uint256 tokenBalance = IERC20Upgradeable(token).balanceOf(
            address(this)
        );
        require(tokenBalance >= amount, "ERROR:INSUFFICIENT");
        IERC20Upgradeable(token).safeTransfer(to, amount);
    }

    function withdrawBNB(
        address to,
        uint256 amount
    ) public onlyRole(MANAGE_ROLE) {
        uint256 bnbBalance = payable(address(this)).balance;
        require(bnbBalance >= amount, "ERROR:INSUFFICIENT");
        payable(to).transfer(amount);
    }

    function setSigner(address _signer) public onlyRole(MANAGE_ROLE) {
        signer = _signer;
    }

    function setFeeReceiver(address _feeReceiver) public onlyRole(MANAGE_ROLE) {
        require(_feeReceiver != address(0),"fee receiver can not be 0 address");
        feeReceiver = _feeReceiver;
    }

    function setFunSwith(bool _funSwitch) public onlyRole(MANAGE_ROLE) {
        funSwitch = _funSwitch;
    }

    

    function splitSignature(
        bytes memory sig
    ) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65, "Not Invalid Signature Data");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function releaseReward(
        bytes memory data
    ) public onlyRole(OPERATOR_ROLE) nonReentrant{
        (
            address token,
            uint256 amount,
            uint256 fee,
            uint256 nonce,
            bytes memory signature
        ) = abi.decode(
                data,
                (address,uint256, uint256,uint256,bytes)
            );
        require(nonce == noncesERC20[msg.sender], "INVALID_NONCE");

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        bytes32 signHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH_ERC20,
                        token,
                        amount,
                        fee,
                        nonce
                    )
                )
            )
        );
        require(
            signer == ecrecover(signHash, v, r, s),
            "ERROR:INVALID_REQUEST"
        );
        noncesERC20[msg.sender]++;
        require(rewardAddress != address(0),"rewardAddress is 0");
        uint256 tokenBalance = IERC20Upgradeable(token).balanceOf(
            address(this)
        );
        require(tokenBalance >= amount, "ERROR:INSUFFICIENT");
        IERC20Upgradeable(token).safeTransfer(rewardAddress, amount - fee );
        IERC20Upgradeable(token).safeTransfer(feeReceiver, fee);

        emit ReleaseReward(msg.sender,token,amount,fee,rewardAddress,block.timestamp);
    }
}
