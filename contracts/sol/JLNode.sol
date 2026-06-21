// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
library DateTime {
    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 constant YEAR_IN_SECONDS = 31536000;
    uint256 constant LEAP_YEAR_IN_SECONDS = 31622400;
    uint256 constant HOUR_IN_SECONDS = 3600;
    uint256 constant MINUTE_IN_SECONDS = 60;
    uint16 constant ORIGIN_YEAR = 1970;
    function isLeapYear(uint256 year) internal pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }
    function leapYearsBefore(uint256 year) internal pure returns (uint256) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }
    function getDaysInMonth(uint256 month, uint256 year) internal pure returns (uint256) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (isLeapYear(year)) {
            return 29;
        } else {
            return 28;
        }
    }
    function parseTimestamp(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day, uint256 weekday, uint256 hour, uint256 minute, uint256 second) {
        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint8 i;
        year = getYear(timestamp);
        buf = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - buf);
        uint256 secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }
        for (i = 1; i <= getDaysInMonth(month, year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
        hour = getHour(timestamp);
        minute = getMinute(timestamp);
        second = getSecond(timestamp);
        weekday = getWeekday(timestamp);
    }
    function getYear(uint256 timestamp) internal pure returns (uint16) {
        uint256 secondsAccountedFor = 0;
        uint16 year;
        uint256 numLeapYears;
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);
        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }
    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month, , , , , ) = parseTimestamp(timestamp);
    }
    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (, , day, , , , ) = parseTimestamp(timestamp);
    }
    function getHour(uint256 timestamp) internal pure returns (uint256) {
        return ((timestamp / 60 / 60) % 24);
    }
    function getMinute(uint256 timestamp) internal pure returns (uint256) {
        return ((timestamp / 60) % 60);
    }
    function getSecond(uint256 timestamp) internal pure returns (uint256) {
        return (timestamp % 60);
    }
    function getWeekday(uint256 timestamp) internal pure returns (uint256) {
        return ((timestamp / DAY_IN_SECONDS + 4) % 7);
    }
    function toTimestamp(uint16 year, uint8 month, uint8 day) internal pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }
    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) internal pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }
    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) internal pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }
    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) internal pure returns (uint256 timestamp) {
        uint16 i;
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            } else {
                timestamp += YEAR_IN_SECONDS;
            }
        }
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        } else {
            monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;
        for (i = 1; i < month; i++) {
            timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
        }
        timestamp += DAY_IN_SECONDS * (day - 1);
        timestamp += HOUR_IN_SECONDS * (hour);
        timestamp += MINUTE_IN_SECONDS * (minute);
        timestamp += second;
        return timestamp;
    }
    function getDayNum(uint256 timestamp) internal pure returns (uint256) {
        (uint256 year, uint256 month, uint256 day, , , , ) = parseTimestamp(timestamp);
        return year * 10000 + month * 100 + day;
    }
    function getTodayNum(uint256 timestamp) internal view returns (uint256) {
        (uint256 year, uint256 month, uint256 day, , , , ) = parseTimestamp(block.timestamp + timestamp);
        return year * 10000 + month * 100 + day;
    }
    function getDayHour(uint256 timestamp) internal pure returns (uint256) {
        (uint256 year, uint256 month, uint256 day, , uint256 hour, , ) = parseTimestamp(timestamp);
        return year * 1000000 + month * 10000 + day * 100 + hour;
    }
    function getDayMinute(uint256 timestamp) internal pure returns (uint256) {
        (uint256 year, uint256 month, uint256 day, , uint256 hour, uint256 minute, ) = parseTimestamp(timestamp);
        return (year * 1000000) + (month * 10000) + (day * 100) + ((hour % 10) * 10 + minute / 10);
    }
}
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}
interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface ISwapPair {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}
interface ISwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}
library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(address target, bool success, bytes memory returndata, string memory errorMessage) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }
    struct BooleanSlot {
        bool value;
    }
    struct Bytes32Slot {
        bytes32 value;
    }
    struct Uint256Slot {
        uint256 value;
    }
    struct StringSlot {
        string value;
    }
    struct BytesSlot {
        bytes value;
    }
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
}
interface IERC1822ProxiableUpgradeable {
    function proxiableUUID() external view returns (bytes32);
}
interface IBeaconUpgradeable {
    function implementation() external view returns (address);
}
interface IERC1967Upgradeable {
    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);
    event BeaconUpgraded(address indexed beacon);
}
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require((isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1), "Initializable: contract is already initialized");
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
abstract contract ERC1967UpgradeUpgradeable is Initializable, IERC1967Upgradeable {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    function __ERC1967Upgrade_init() internal onlyInitializing {}
    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {}
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(newImplementation, data);
        }
    }
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()), "ERC1967: beacon implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }
    uint256[50] private __gap;
}
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    address private immutable __self = address(this);
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }
    function __UUPSUpgradeable_init() internal onlyInitializing {}
    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {}
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
    function upgradeTo(address newImplementation) public virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }
    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}
    function __Context_init_unchained() internal onlyInitializing {}
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
    uint256[50] private __gap;
}
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }
    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}
interface INFT {
    function createNFT(uint power, uint newMaxSupply, string memory cid, string memory suffix) external;
    function mint(address to, uint tokenId, uint amount) external;
}
interface ICODE is IERC20 {
    function swapBack() external;
}
interface INODE {
    function updatePool() external;
}
interface IMAIN {
    struct ConfigSingle {
        uint addTime;
        uint dayTimes;
        uint handleGas;
        uint userMaxAmount;
        uint incomeNode;
        uint incomeFund;
        uint inviteRate;
        uint stakeMin;
        uint stakeMax;
        uint stakeStocks;
        uint mintRate;
        uint rewardRate;
    }
    struct ConfigMulti {
        uint nodePrice;
        uint nodeReward;
        uint nodeLevel;
        uint nodeInvite;
        uint nodeBuyTP;
        uint nodeBuyTRC;
        uint machinePrice;
        uint machineReward;
        uint[6] teamAmounts;
        uint[6] teamRates;
        uint[5] depositRates;
    }
    struct TokenAdd {
        address manager;
        address market;
        address lpRecieve;
        address flowTo;
        address glodTo;
        address dynamic;
        IERC20 USDT;
        ICODE TOKEN;
        ICODE JQ;
        IERC20 TP;
        IERC20 TRC;
        INODE NODE;
        ISwapRouter ROUTER;
    }
    struct TotalInfo {
        uint totalUser;
        uint totalOrder;
        uint totalAmount;
        uint totalActual;
        uint totalRewardStatic;
        uint totalRewardInvite;
        uint totalRewardTeam;
        uint totalExtract;
        uint priceTotal;
        uint totalRewardMax;
        uint lastIndex;
    }
    struct UserInfo {
        uint index;
        uint amount;
        uint actual;
        uint balance;
        uint balanceU;
        uint rewardMax;
        uint rewardStatic;
        uint rewardInvite;
        uint rewardTeam;
        uint orders;
        uint lastOut;
        address refer;
    }
    struct TeamInfo {
        bool isManual;
        uint level;
        uint invites;
        uint inviteValids;
        uint teamUser;
        uint teamAmount;
        uint teamMax;
        uint teamMin;
        address maxAccount;
    }
    struct OrderInfo {
        bool isValid;
        uint index;
        uint userIndex;
        uint amount;
        uint rewardMax;
        uint reward;
        uint rewardU;
        uint startTime;
        uint lastTime;
        uint lastPrice;
        address owner;
    }
    function userInvites(address account, uint index) external view returns (address);
    function users(address account) external view returns (UserInfo memory user);
    function teams(address account) external view returns (TeamInfo memory team);
    function userOrderIndex(address account, uint index) external view returns (uint);
    function orders(uint index) external view returns (OrderInfo memory order);
    function isBlackList(address account) external view returns (bool);
    function getConfig() external view returns (ConfigSingle memory config, TokenAdd memory tokenAdd, TotalInfo memory totalInfo);
    function getConfigMulti() external view returns (ConfigMulti memory config);
    function register(address account, address refer) external;
    function deposit(address account, uint index, uint amount, uint preIndex) external;
    function release(address account, uint index) external;
    function updateUser(address account) external;
    function updatePool() external;
    function minuteAmounts(uint index) external view returns (uint);
    function dayAmounts(uint dayNum, uint index) external view returns (uint);
    function dayUserAmounts(address account, uint index) external view returns (uint);
    function sendMining(uint amount) external;
}
contract ANode is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using Address for address;
    using Strings for uint256;
    struct ConfigSingle {
        uint nodeAmount;
        uint nodePriceA;
        uint nodePriceB;
        uint nodePriceC;
        uint nodeSurplusA;
        uint nodeSurplusB;
        uint nodeSurplusC;
    }
    struct ConfigMulti {
        uint[3] rates;
        uint[7] teamRelease;
    }
    struct UserReward {
        bool isExist;
        bool isForceA;
        bool isForceB;
        bool isForceC;
        uint index;
        uint balance;
        uint debtA;
        uint debtB;
        uint debtC;
        uint rewardA;
        uint rewardB;
        uint rewardC;
    }
    struct TotalReward {
        uint totalUser;
        uint totalRewardA;
        uint totalRewardB;
        uint totalRewardC;
        uint totalForceA;
        uint perForceA;
        uint totalForceB;
        uint perForceB;
        uint totalForceC;
        uint perForceC;
        uint lastBalance;
        uint lastIndex;
    }
    struct TokenAdd {
        address market;
        address dynamic;
        IMAIN MAIN;
    }
    ConfigSingle private _cs;
    ConfigMulti private _cm;
    TokenAdd private _ta;
    TotalReward private _tr;
    mapping(uint => address) public userAdds;
    mapping(address => UserReward) public users;
    mapping(address => uint[7]) public userClaims;
    uint public diffAmount;
    modifier onlyManager() {
        if (owner() != msg.sender && msg.sender != address(_ta.MAIN)) {
            (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
            require(tokenAdd.manager == msg.sender, "Mint: Not Manager");
        }
        _;
    }
    modifier checkUser() {
        require(_ta.MAIN.users(msg.sender).index > 0, "User Not Exist");
        _;
    }
    modifier checkBlack() {
        require(!_ta.MAIN.isBlackList(msg.sender), "User Is Invalid");
        _;
    }
    event Actions(address account, uint category, uint amount1, uint amount2, uint amount3, uint amount4);
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        _ta.MAIN = IMAIN(0x08afFc83216C6a93e8180a35D4397819cd13D998);
        _cm.rates = [10000, 0, 0];
        _tr.perForceA = 1;
        _tr.perForceB = 1;
        _tr.perForceC = 1;
        _cs.nodeAmount = 10000e18;
        _cs.nodePriceA = 3000e18;
        _cs.nodeSurplusA = 33;
    }
    function withdrawToken(IERC20 token, uint256 amount, address to) public onlyManager {
        (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
        if (address(token) == address(tokenAdd.TOKEN)) updatePool();
        token.transfer(to, amount);
        if (address(token) == address(tokenAdd.TOKEN)) _tr.lastBalance = tokenAdd.TOKEN.balanceOf(address(this));
    }
    function setTokenAdd(uint256 category, address data) public onlyManager {
        if (category == 1) _ta.market = data;
        if (category == 2) _ta.dynamic = data;
        if (category == 10) _ta.MAIN = IMAIN(data);
    }
    function setConfig(uint category, uint data) public onlyManager {
        if (category == 1) _cs.nodeAmount = data;
        if (category == 2) _cs.nodePriceA = data;
        if (category == 3) _cs.nodePriceB = data;
        if (category == 4) _cs.nodePriceC = data;
        if (category == 5) _cs.nodeSurplusA = data;
        if (category == 6) _cs.nodeSurplusB = data;
        if (category == 7) _cs.nodeSurplusC = data;
        if (category == 8) diffAmount = data;
    }
    function setConfigMulti(uint256 category, uint256[] memory data) public onlyManager {
        updateReward();
        for (uint256 i = 0; i < data.length; i++) {
            if (category == 1 && i < _cm.rates.length) _cm.rates[i] = data[i];
            if (category == 2 && i < _cm.teamRelease.length) _cm.teamRelease[i] = data[i];
        }
        if (category == 1) {
            uint total;
            for (uint i = 0; i < _cm.rates.length; i++) {
                total += _cm.rates[i];
            }
            require(total == 10000, "Rate Sum Not Match 10000");
        }
    }
    function setUserForceBatch(address[] memory accounts, uint category, bool data) public onlyManager {
        updateReward();
        for (uint i = 0; i < accounts.length; i++) {
            _handleUser(accounts[i]);
            _setUserForce(accounts[i], category, data);
        }
    }
    function setUserForce(address account, uint category, bool data) public onlyManager {
        updateReward();
        _handleUser(account);
        _setUserForce(account, category, data);
    }
    function sendRewardCreate(uint amount) public {
        require(msg.sender == address(_ta.MAIN), "Node: Not Main");
        (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
        require(tokenAdd.TOKEN.balanceOf(address(this)) >= amount, "Node: Insufficient Balance");
        _tr.lastBalance += amount;
        _sendRewardB(amount);
        updateReward();
    }
    function addBalance(address[] memory accounts) public onlyManager {
        for (uint i = 0; i < accounts.length; i++) {
            users[accounts[i]].balance += diffAmount;
        }
    }
    function buyNodeA() public checkUser checkBlack {
        address account = msg.sender;
        require(_cs.nodeSurplusA > 0, "Insufficient Node");
        _cs.nodeSurplusA--;
        (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
        tokenAdd.TOKEN.transferFrom(account, _ta.market, _cs.nodePriceA);
        require(!users[account].isForceA, "Has Buy");
        _setUserForce(account, 1, true);
    }
    function claim() public checkUser checkBlack {
        address account = msg.sender;
        updateReward();
        _handleUser(account);
        UserReward storage user = users[account];
        require(user.balance > diffAmount, "Balance Insufficient");
        uint amount = user.balance - diffAmount;
        user.balance -= amount;
        emit Actions(account, 74, amount, user.rewardA, user.rewardB, user.rewardC);
        (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
        tokenAdd.TOKEN.transfer(account, amount);
        _tr.lastBalance = tokenAdd.TOKEN.balanceOf(address(this));
    }
    function updateUser(address account) public {
        updateReward();
        _handleUser(account);
        updatePool();
    }
    function updatePool() public {{
            uint gasUsed = 0;
            uint gasLeft = gasleft();
            while (true) {
                if (_tr.lastIndex > _tr.totalUser) {
                    _tr.lastIndex = 1;
                    break;
                }
                address account = userAdds[_tr.lastIndex];
                _handleUser(account);
                _tr.lastIndex++;
                gasUsed += (gasLeft - gasleft());
                gasLeft = gasleft();
                if (gasUsed > 600000) {
                    return;
                }
            }
        }
    }
    function updateReward() public {
        (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
        if (tokenAdd.TOKEN.balanceOf(address(this)) > _tr.lastBalance) {
            uint reward = tokenAdd.TOKEN.balanceOf(address(this)) - _tr.lastBalance;
            _tr.lastBalance = tokenAdd.TOKEN.balanceOf(address(this));
            if (_cm.rates[0] > 0) _sendRewardA((reward * _cm.rates[0]) / 10000);
            if (_cm.rates[1] > 0) _sendRewardB((reward * _cm.rates[1]) / 10000);
            if (_cm.rates[2] > 0) _sendRewardC((reward * _cm.rates[2]) / 10000);
        }
    }
    function addUSDT(uint amount) public {
        updatePool();
        (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
        tokenAdd.TOKEN.transferFrom(msg.sender, address(this), amount);
        _tr.lastBalance = tokenAdd.TOKEN.balanceOf(address(this));
    }
    function getConfig() public view returns (ConfigSingle memory config, TokenAdd memory tokenAdd, TotalReward memory totalReward) {
        config = _cs;
        tokenAdd = _ta;
        totalReward = _tr;
    }
    function getConfigMulti() public view returns (ConfigMulti memory config) {
        config = _cm;
    }
    function getUserInfo(address account) public view returns (UserReward memory user, uint balance, uint[7] memory releases) {
        user = users[account];
        uint _perForceA = _tr.perForceA;
        uint _perForceB = _tr.perForceB;
        uint _perForceC = _tr.perForceC;
        (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
        if (tokenAdd.TOKEN.balanceOf(address(this)) > _tr.lastBalance) {
            uint reward = tokenAdd.TOKEN.balanceOf(address(this)) - _tr.lastBalance;
            if (_tr.totalForceA > 0) _perForceA += (reward * _cm.rates[0]) / 10000 / _tr.totalForceA;
            if (_tr.totalForceB > 0) _perForceB += (reward * _cm.rates[1]) / 10000 / _tr.totalForceB;
            if (_tr.totalForceC > 0) _perForceC += (reward * _cm.rates[2]) / 10000 / _tr.totalForceC;
        }
        IMAIN.TeamInfo memory userInfo = _ta.MAIN.teams(account);
        if (user.isForceA) {
            if (user.debtA == 0) user.debtA = _perForceA;
            uint reward = _perForceA - user.debtA;
            user.debtA = _perForceA;
            if (reward > 0 && userInfo.teamMin >= _cs.nodeAmount) {
                user.rewardA += reward;
                user.balance += reward;
            }
        }
        if (user.isForceB) {
            if (user.debtB == 0) user.debtB = _perForceB;
            uint reward = _perForceB - user.debtB;
            user.debtB = _perForceB;
            if (reward > 0 && userInfo.teamMin >= _cs.nodeAmount) {
                user.rewardB += reward;
                user.balance += reward;
            }
        }
        if (user.isForceC) {
            if (user.debtC == 0) user.debtC = _perForceC;
            uint reward = _perForceC - user.debtC;
            user.debtC = _perForceC;
            if (reward > 0 && userInfo.teamMin >= _cs.nodeAmount) {
                user.rewardC += reward;
                user.balance += reward;
            }
        }
        if (user.balance > diffAmount) user.balance -= diffAmount;
        else user.balance = 0;
    }
    function _setUserForce(address account, uint category, bool data) private {
        if (!users[account].isExist) {
            _tr.totalUser++;
            userAdds[_tr.totalUser] = account;
            users[account].isExist = true;
            users[account].index = _tr.totalUser;
        }
        _handleUser(account);
        UserReward storage user = users[account];
        if (data) {
            if (category == 1 && !user.isForceA) {
                _tr.totalForceA++;
                user.isForceA = true;
                user.debtA = _tr.perForceA;
            } else if (category == 2 && !user.isForceB) {
                _tr.totalForceB++;
                user.isForceB = true;
                user.debtB = _tr.perForceB;
            } else if (category == 3 && !user.isForceC) {
                _tr.totalForceC++;
                user.isForceC = true;
                user.debtC = _tr.perForceC;
            }
            if(user.balance < diffAmount) user.balance = diffAmount;
        } else {
            if (category == 1 && user.isForceA) {
                if (_tr.totalForceA > 0) _tr.totalForceA--;
                user.isForceA = false;
                user.debtA = 0;
            } else if (category == 2 && user.isForceB) {
                if (_tr.totalForceB > 0) _tr.totalForceB--;
                user.isForceB = false;
                user.debtB = 0;
            } else if (category == 3 && user.isForceC) {
                if (_tr.totalForceC > 0) _tr.totalForceC--;
                user.isForceC = false;
                user.debtC = 0;
            }
        }
    }
    function _handleUser(address account) private {
        IMAIN.TeamInfo memory userInfo = _ta.MAIN.teams(account);
        UserReward storage user = users[account];
        if (user.isForceA) {
            if (user.debtA == 0) user.debtA = _tr.perForceA;
            uint reward = _tr.perForceA - user.debtA;
            user.debtA = _tr.perForceA;
            if (reward > 0 && userInfo.teamMin < _cs.nodeAmount) {
            } else if (reward > 0) {
                user.rewardA += reward;
                user.balance += reward;
                emit Actions(account, 71, reward, user.rewardA, user.rewardB, user.rewardC);
            }
        }
        if (user.isForceB) {
            if (user.debtB == 0) user.debtB = _tr.perForceB;
            uint reward = _tr.perForceB - user.debtB;
            user.debtB = _tr.perForceB;
            if (reward > 0 && userInfo.teamMin < _cs.nodeAmount) {
            } else if (reward > 0) {
                user.rewardB += reward;
                user.balance += reward;
                emit Actions(account, 72, reward, user.rewardA, user.rewardB, user.rewardC);
            }
        }
        if (user.isForceC) {
            if (user.debtC == 0) user.debtC = _tr.perForceC;
            uint reward = _tr.perForceC - user.debtC;
            user.debtC = _tr.perForceC;
            if (reward > 0 && userInfo.teamMin < _cs.nodeAmount) {
            } else if (reward > 0) {
                user.rewardC += reward;
                user.balance += reward;
                emit Actions(account, 73, reward, user.rewardA, user.rewardB, user.rewardC);
            }
        }
    }
    function _sendRewardA(uint amount) private {
        if (_tr.totalForceA == 0) {
            (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
            tokenAdd.TOKEN.transfer(_ta.dynamic, amount);
            _tr.lastBalance = tokenAdd.TOKEN.balanceOf(address(this));
        } else _tr.perForceA += (amount) / _tr.totalForceA;
        _tr.totalRewardA += amount;
    }
    function _sendRewardB(uint amount) private {
        if (_tr.totalForceB == 0) {
            (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
            tokenAdd.TOKEN.transfer(_ta.dynamic, amount);
            _tr.lastBalance = tokenAdd.TOKEN.balanceOf(address(this));
        } else _tr.perForceB += (amount) / _tr.totalForceB;
        _tr.totalRewardB += amount;
    }
    function _sendRewardC(uint amount) private {
        if (_tr.totalForceC == 0) {
            (, IMAIN.TokenAdd memory tokenAdd, ) = _ta.MAIN.getConfig();
            tokenAdd.TOKEN.transfer(_ta.dynamic, amount);
            _tr.lastBalance = tokenAdd.TOKEN.balanceOf(address(this));
        } else _tr.perForceC += (amount) / _tr.totalForceC;
        _tr.totalRewardC += amount;
    }
}
