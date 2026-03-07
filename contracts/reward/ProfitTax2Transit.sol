// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
contract ProfitTax2Transit  is  Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable {
        using SafeERC20Upgradeable for IERC20Upgradeable;
        bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");
        bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

        bytes32 public DOMAIN_SEPARATOR;

        bytes32 private constant PERMIT_TYPEHASH_ERC20 =
            keccak256(
                abi.encodePacked(
                    "Permit(address token,uint256 amount,uint256 nonce)"
                )
            );
        bytes32 private constant PERMIT_TYPEHASH_PIJS =
            keccak256(
                abi.encodePacked(
                    "Permit(uint256 amount,uint256 nonce)"
                )
            );

        address public signer;
        address public rewardAddress;
        address public operator;

        mapping(address => uint) public noncesERC20;
        mapping(address => uint) public noncesPIJS;
        /// @custom:oz-upgrades-unsafe-allow constructor
        constructor() {
            _disableInitializers();
        }

        function _authorizeUpgrade(
            address newImplementation
        ) internal override onlyRole(MANAGE_ROLE) {}

        function initialize(
            address _signer,address _rewardAddress,address _operator
        ) public initializer {
            __AccessControlEnumerable_init();
            __ReentrancyGuard_init();
            __UUPSUpgradeable_init();
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(MANAGE_ROLE, msg.sender);
            _grantRole(OPERATOR_ROLE,_operator);

            signer = _signer;
            operator = _operator;
            rewardAddress = _rewardAddress;
            uint256 chainId;
            assembly {
                chainId := chainid()
            }
            DOMAIN_SEPARATOR = keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("ProfitTax2Transit")),
                    keccak256(bytes("1")),
                    chainId,
                    address(this)
                )
            );

        }

    event WithdrawErc20(address token,address operator,address to,uint256 amount,uint256 createTime);
    event WithdrawPIJS(address operator,address to,uint256 amount,uint256 createTime);
    event ReleaseReward(address userAddr,address token,uint256 amount,address rewardAddress,uint256 createTime);
    event WithdrawPIJSToReward(address userAddr,uint256 amount,address rewardAddress,uint256 createTime);


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
    ) public onlyRole(MANAGE_ROLE) nonReentrant {
        uint256 tokenBalance = IERC20Upgradeable(token).balanceOf(
            address(this)
        );
        require(tokenBalance >= amount, "ERROR:INSUFFICIENT");
        IERC20Upgradeable(token).safeTransfer(to, amount);
        emit WithdrawErc20(token,msg.sender,to,amount,block.timestamp);
    }

    function withdrawPIJS(
        address to,
        uint256 amount
    ) public onlyRole(MANAGE_ROLE) nonReentrant {
        uint256 bnbBalance = payable(address(this)).balance;
        require(bnbBalance >= amount, "ERROR:INSUFFICIENT");
        payable(to).transfer(amount);
        emit WithdrawPIJS(msg.sender,to,amount,block.timestamp);
    }
    receive() external payable {}

    // 释放
    function releaseReward(
        bytes memory data
    ) public onlyRole(OPERATOR_ROLE) nonReentrant{
        (
            address token,
            uint256 amount,
            uint256 nonce,
            bytes memory signature
        ) = abi.decode(
                data,
                (address,uint256, uint256, bytes)
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
        IERC20Upgradeable(token).safeTransfer(rewardAddress, amount);

        emit ReleaseReward(msg.sender,token,amount,rewardAddress,block.timestamp);
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
    function setRewardContract (address _rewardAddress) external onlyRole(MANAGE_ROLE) {
        require(_rewardAddress != address(0),"0 address");
        rewardAddress = _rewardAddress;
    }



}