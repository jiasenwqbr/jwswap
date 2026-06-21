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
library AiWeb3Tools {
    function randomWithSeed(uint256 lenth, uint256 seed) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, seed, tx.origin))) % lenth;
    }
    function swapForToken(ISwapRouter _ROUTER, IERC20 _TOKEN_A, IERC20 _TOKEN_B, uint amountIn, uint rate, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(_TOKEN_A);
        path[1] = address(_TOKEN_B);
        uint amountOut = _ROUTER.getAmountsOut(amountIn, path)[1];
        _TOKEN_A.approve(address(_ROUTER), amountIn);
        _ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, (amountOut * (10000 - rate)) / 10000, path, to, block.timestamp);
        emit SwapTokensForTokens(amountIn, path);
    }
    function swapForTokenTrans(ISwapRouter _ROUTER, IERC20 _TOKEN_A, IERC20 _TOKEN_B, uint amountIn, uint rate, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(_TOKEN_A);
        path[1] = address(_TOKEN_B);
        uint amountOut = _ROUTER.getAmountsOut(amountIn, path)[1];
        _TOKEN_A.approve(address(_ROUTER), amountIn);
        if (address(this) == to) {
            _ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, (amountOut * (10000 - rate)) / 10000, path, to, block.timestamp);
        } else {
            uint balance = _TOKEN_B.balanceOf(address(this));
            _ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, (amountOut * (10000 - rate)) / 10000, path, address(this), block.timestamp);
            balance = _TOKEN_B.balanceOf(address(this)) - balance;
            _TOKEN_B.transfer(to, balance);
        }
        emit SwapTokensForTokens(amountIn, path);
    }
    function swapForExact(ISwapRouter _ROUTER, IERC20 _TOKEN_A, IERC20 _TOKEN_B, uint amountOut, uint rate, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(_TOKEN_A);
        path[1] = address(_TOKEN_B);
        uint amountIn = _ROUTER.getAmountsIn(amountOut, path)[0];
        amountIn = (amountIn * (10000 + rate)) / 10000;
        _TOKEN_A.approve(address(_ROUTER), amountIn);
        _ROUTER.swapTokensForExactTokens(amountOut, amountIn, path, to, block.timestamp);
        emit SwapTokensForTokens(amountIn, path);
    }
    function addLiquidityUSDT(ISwapRouter _ROUTER, IERC20 _USDT, uint256 usdtAmount, IERC20 _TOKEN, uint256 tokenAmount, address to) internal {
        _TOKEN.approve(address(_ROUTER), tokenAmount);
        _USDT.approve(address(_ROUTER), usdtAmount);
        _ROUTER.addLiquidity(address(_USDT), address(_TOKEN), usdtAmount, tokenAmount, 0, 0, to, block.timestamp);
        emit AddLiquidity(tokenAmount, usdtAmount);
    }
    event SwapTokensForTokens(uint256 amountIn, address[] path);
    event AddLiquidity(uint256 tokenAmount, uint256 ethAmount);
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
interface ICODE is IERC20 {
    function swapBack() external;
    function burnPool() external;
    function getPrice() external view returns (uint256);
    function sendIntegral(address account, uint amount) external;
}
interface INODE {
    function updateReward() external;
    function updatePool() external;
    function updateUser(address account) external;
    function sendRewardCreate(uint amount) external;
    function sendNodeReward(address account, uint amount) external;
    function setUserForce(address account, uint category, bool data) external;
}
contract AMain is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using Address for address;
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
    ConfigSingle private _cs;
    ConfigMulti private _cm;
    TokenAdd private _ta;
    TotalInfo private _ti;
    mapping(uint => OrderInfo) public orders;
    mapping(address => mapping(uint => uint)) public userOrderIndex;
    mapping(uint => address) public userAdds;
    mapping(address => UserInfo) public users;
    mapping(address => TeamInfo) public teams;
    mapping(address => mapping(uint => address)) public userInvites;
    mapping(uint => uint) public dayAmounts;
    mapping(address => bool) public isBlackList;
    mapping(uint => uint) public prices;
    mapping(uint => uint) public priceTimes;
    address private _dead;
    address public swapPair;
    mapping(uint => uint) public swapPool;
    modifier onlyManager() {
        require(owner() == _msgSender() || _ta.manager == _msgSender(), "Main: Not Manager");
        _;
    }
    modifier checkWallet(address account) {
        require(account == tx.origin, "Main: Not Wallet");
        _;
    }
    modifier checkUser() {
        require(users[msg.sender].index > 0, "Main: User Not Exist");
        require(!isBlackList[msg.sender], "User Invalid");
        updatePrice();
        _updateUser(msg.sender);
        _;
        updateAll();
    }
    event BindRefer(address account, address refer);
    event Actions(address account, uint category, uint amount1, uint amount2, uint amount3, uint amount4);
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();

    }
    function withdrawToken(IERC20 token, address to, uint amount) public onlyManager {
        token.transfer(to, amount);
    }
    function setTokenAdd(uint256 category, address data) public onlyManager {
        if (category == 1) _ta.manager = data;
        if (category == 2) _ta.market = data;
        if (category == 3) _ta.lpRecieve = data;
        if (category == 4) _ta.flowTo = data;
        if (category == 5) _ta.glodTo = data;
        if (category == 8) _ta.dynamic = data;
        if (category == 10) _ta.USDT = IERC20(data);
        if (category == 11) _ta.TOKEN = ICODE(data);
        if (category == 13) _ta.TP = IERC20(data);
        if (category == 14) _ta.TRC = IERC20(data);
        if (category == 15) _ta.NODE = INODE(data);
        if (category == 16) _ta.JQ = ICODE(data);
        if (category == 17) swapPair = data;
    }
    function setConfig(uint256 category, uint256 data) public onlyManager {
        if (category == 4) _cs.userMaxAmount = data;
        if (category == 5) _cs.incomeNode = data;
        if (category == 6) _cs.incomeFund = data;
        if (category == 7) _cs.inviteRate = data;
        if (category == 9) _cs.stakeMin = data;
        if (category == 10) _cs.stakeMax = data;
        if (category == 11) _cs.stakeStocks = data;
        if (category == 12) _cs.mintRate = data;
        if (category == 13) _cs.rewardRate = data;
        if (category == 14) _cm.nodePrice = data;
        if (category == 15) _cm.nodeReward = data;
        if (category == 16) _cm.nodeLevel = data;
        if (category == 17) _cm.nodeInvite = data;
        if (category == 18) _cm.nodeBuyTP = data;
        if (category == 21) _cm.nodeBuyTRC = data;
        if (category == 19) _cm.machinePrice = data;
        if (category == 20) _cm.machineReward = data;
    }
    function setConfigMulti(uint256 category, uint256[] memory data) public onlyManager {
        for (uint256 i = 0; i < data.length; i++) {
            if (category == 2 && i < _cm.teamAmounts.length) _cm.teamAmounts[i] = data[i];
            if (category == 3 && i < _cm.teamRates.length) _cm.teamRates[i] = data[i];
            if (category == 4 && i < _cm.depositRates.length) _cm.depositRates[i] = data[i];
        }
    }
    function setIsBlackList(address account, bool data) public onlyManager {
        isBlackList[account] = data;
    }
    function setUserLevel(address account, uint data) public onlyManager {
        if (data > 0) {
            _handleTeamLevel(account, teams[account].level, data);
            teams[account].isManual = true;
        } else {
            uint newLevel = _getTeamLevel(teams[account].teamMin);
            teams[account].isManual = false;
            _handleTeamLevel(account, teams[account].level, newLevel);
        }
    }
    function addMachine(address account, uint amount, uint reward) public onlyManager {
        _deposit(account, amount, reward);
    }
    function register(address refer) public {
        address account = msg.sender;
        require(users[refer].index > 0, "Main: Refer Not Exist");
        require(users[account].index == 0, "Main: User Has Exist");
        _ti.totalUser++;
        userAdds[_ti.totalUser] = account;
        UserInfo storage user = users[account];
        user.index = _ti.totalUser;
        user.refer = refer;
        teams[refer].invites++;
        userInvites[refer][teams[refer].invites] = account;
        emit BindRefer(account, refer);
        address parent = refer;
        for (uint256 i = 0; i < 100; i++) {
            if (parent == address(0)) break;
            teams[parent].teamUser++;
            parent = users[parent].refer;
        }
        updatePrice();
    }
    function buyMachine() public checkUser {
        address account = msg.sender;
        require(_cm.machinePrice > 0, "Main: No Machine");
        _ta.USDT.transferFrom(account, address(this), _cm.machinePrice);
        _handleNodeAmount(_cm.machinePrice);
        _deposit(account, _cm.machinePrice, _cm.machineReward);
    }
    function buyNode() public checkUser {
        address account = msg.sender;
        require(_cm.nodePrice > 0, "Main: No Node");
        _ta.USDT.transferFrom(account, address(this), _cm.nodePrice);
        if (users[account].refer != address(0) && users[account].refer != _dead) {
            _ta.USDT.transfer(users[account].refer, (_cm.nodePrice * _cm.nodeInvite) / 10000);
        }
        _handleNodeAmount(_cm.nodePrice);
        _deposit(account, _cm.nodePrice, _cm.nodeReward);
        if (teams[account].level < _cm.nodeLevel) {
            _handleTeamLevel(account, teams[account].level, _cm.nodeLevel);
            teams[account].isManual = true;
        }
        _ta.NODE.setUserForce(account, 1, true);
    }
    function deposit(uint amount) public checkUser {
        address account = msg.sender;{
            require(_cs.stakeMin <= amount, "Main: Amount Less Min");
            require(_cs.stakeMax >= amount, "Main: Amount Over Max");
            uint dayNum = DateTime.getTodayNum(_cs.addTime);
            require(_cs.stakeStocks >= dayAmounts[dayNum] + amount, "Main: Insufficient Amount");
            dayAmounts[dayNum] += amount;
        }
        _ta.USDT.transferFrom(account, address(this), amount);
        _ta.JQ.sendIntegral(account, amount);
        if (_cm.depositRates[0] > 0)
            AiWeb3Tools.swapForTokenTrans(_ta.ROUTER, _ta.USDT, _ta.TOKEN, (amount * _cm.depositRates[0]) / 10000, 1000, address(_ta.NODE));
        if (_cm.depositRates[1] > 0) _ta.USDT.transfer(_ta.flowTo, (amount * _cm.depositRates[1]) / 10000);
        if (_cm.depositRates[2] > 0) _ta.USDT.transfer(_ta.glodTo, (amount * _cm.depositRates[2]) / 10000);
        if (_cm.depositRates[3] > 0) AiWeb3Tools.swapForTokenTrans(_ta.ROUTER, _ta.USDT, _ta.TP, (amount * _cm.depositRates[3]) / 10000, 1000, _dead);
        if (_cm.depositRates[4] > 0)
            AiWeb3Tools.swapForTokenTrans(_ta.ROUTER, _ta.USDT, _ta.TRC, (amount * _cm.depositRates[4]) / 10000, 1000, _dead);{
            uint surplus = _ta.USDT.balanceOf(address(this));
            uint beforeBalance = _ta.TOKEN.balanceOf(address(this));
            AiWeb3Tools.swapForTokenTrans(_ta.ROUTER, _ta.USDT, _ta.TOKEN, surplus / 2, 1000, address(this));
            beforeBalance = _ta.TOKEN.balanceOf(address(this)) - beforeBalance;
            AiWeb3Tools.addLiquidityUSDT(_ta.ROUTER, _ta.USDT, surplus / 2, _ta.TOKEN, beforeBalance, _ta.lpRecieve);
        }
        UserInfo storage user = users[account];
        require(user.index > 0, "Main: User Not Exist");
        require(user.actual + amount <= _cs.userMaxAmount, "Main: Over User Max Amount");
        _deposit(account, amount, amount);
    }
    function claim() public checkUser {
        address account = msg.sender;
        UserInfo storage user = users[account];
        uint amount = user.balance;
        if (amount == 0) return;
        user.balance = 0;
        uint usdt = user.balanceU;
        user.balanceU = 0;
        _ti.totalExtract += amount;
        _ta.TOKEN.transfer(account, (amount * (10000 - _cs.inviteRate - _cs.incomeNode - _cs.incomeFund - _cm.teamRates[_cm.teamRates.length - 1])) / 10000);
        _ta.TOKEN.transfer(_ta.market, (amount * _cs.incomeFund) / 10000);
        _ta.TOKEN.transfer(address(_ta.NODE), (amount * _cs.incomeNode) / 10000);
        _sendRewardInvite(account, amount, usdt);
        _sendRewardTeam(account, amount, usdt);
        _ta.TOKEN.swapBack();
        require(_ta.TOKEN.balanceOf(swapPair) > getLastPool(), "Over Swap Pool Limit");
    }
    function updateAll() public {
        uint gasUsed = 0;
        uint gasLeft = gasleft();
        _ta.TOKEN.burnPool();
        while (true) {
            if (_ti.lastIndex > _ti.totalUser) _ti.lastIndex = 1;
            address account = userAdds[_ti.lastIndex];
            if (users[account].actual > 0) {
                _updateUser(account);
            }
            _ti.lastIndex++;
            gasUsed += (gasLeft - gasleft());
            gasLeft = gasleft();
            if (gasUsed > _cs.handleGas) {
                return;
            }
        }
    }
    function updatePrice() public {
        if (block.timestamp >= priceTimes[_ti.priceTotal] + 3600) {
            if (_ta.TOKEN.getPrice() != prices[_ti.priceTotal]) {
                _ti.priceTotal++;
                prices[_ti.priceTotal] = _ta.TOKEN.getPrice();
                priceTimes[_ti.priceTotal] = block.timestamp;
            }
        }
        if (_ta.TOKEN.balanceOf(swapPair) > swapPool[block.timestamp / 3600]) {
            swapPool[block.timestamp / 3600] = _ta.TOKEN.balanceOf(swapPair);
        }
    }
    function getConfig() public view returns (ConfigSingle memory config, TokenAdd memory tokenAdd, TotalInfo memory totalInfo) {
        config = _cs;
        tokenAdd = _ta;
        totalInfo = _ti;
    }
    function getConfigMulti() public view returns (ConfigMulti memory config) {
        config = _cm;
    }
    function getLastPool() public view returns (uint amount) {
        uint i = 1;
        while (i < 100) {
            amount = (swapPool[block.timestamp / 3600 - i] * 90) / 100;
            i++;
            if (amount > 0) break;
        }
        if (amount == 0) amount = 690_0000e18;
    }
    function getHours() public view returns (uint) {
        return block.timestamp / 3600;
    }
    function _handleNodeAmount(uint amount) private {
        if (_cm.nodeBuyTP > 0) AiWeb3Tools.swapForTokenTrans(_ta.ROUTER, _ta.USDT, _ta.TP, (amount * _cm.nodeBuyTP) / 10000, 1000, _dead);
        if (_cm.nodeBuyTRC > 0) AiWeb3Tools.swapForTokenTrans(_ta.ROUTER, _ta.USDT, _ta.TRC, (amount * _cm.nodeBuyTRC) / 10000, 1000, _dead);
        _ta.USDT.transfer(_ta.market, _ta.USDT.balanceOf(address(this)));
    }
    function _deposit(address account, uint amount, uint reward) private {
        UserInfo storage user = users[account];{
            if (user.actual == 0) teams[user.refer].inviteValids++;
            user.amount += amount;
            user.actual += amount;
            user.rewardMax += reward;
            _ti.totalRewardMax += reward;
            _ti.totalAmount += amount;
            _ti.totalActual += amount;
            user.orders++;
            _ti.totalOrder++;
            orders[_ti.totalOrder] = OrderInfo({
                isValid: true, index: _ti.totalOrder, userIndex: user.orders, amount: amount, rewardMax: reward, reward: 0, rewardU: 0, startTime: block.timestamp, lastTime: block.timestamp, lastPrice: _ti.priceTotal, owner: account
            });
            userOrderIndex[account][user.orders] = _ti.totalOrder;
            emit Actions(account, 1, _ti.totalOrder, amount, user.actual, user.balance);
        }
        _updateTeamAmount(account, amount, true);
    }
    function _updateUser(address account) private {
        UserInfo storage user = users[account];
        uint rewardTotal;
        uint rewardTotalU;
        uint releaseAmount;
        for (uint i = user.lastOut; i < user.orders; i++) {
            OrderInfo storage order = orders[userOrderIndex[account][i + 1]];
            if (order.isValid) {
                uint reward;
                uint rewardToken;
                for (uint j = order.lastPrice; j <= _ti.priceTotal; j++) {
                    uint rewardU;
                    if (j == _ti.priceTotal && order.lastTime >= priceTimes[j] && block.timestamp > order.lastTime) {
                        rewardU = ((block.timestamp - order.lastTime) * _cs.mintRate * order.amount) / (10000 * _cs.dayTimes);
                    }
                    else if (j == _ti.priceTotal && order.lastTime < priceTimes[j] && block.timestamp > priceTimes[j]) {
                        rewardU = ((block.timestamp - priceTimes[j]) * _cs.mintRate * order.amount) / (10000 * _cs.dayTimes);
                    }
                    else if (block.timestamp >= priceTimes[j + 1] && order.lastTime < priceTimes[j] && priceTimes[j + 1] > priceTimes[j]) {
                        rewardU = ((priceTimes[j + 1] - priceTimes[j]) * _cs.mintRate * order.amount) / (10000 * _cs.dayTimes);
                    }
                    else if (block.timestamp >= priceTimes[j + 1] && order.lastTime >= priceTimes[j] && priceTimes[j + 1] > order.lastTime) {
                        rewardU = ((priceTimes[j + 1] - order.lastTime) * _cs.mintRate * order.amount) / (10000 * _cs.dayTimes);
                    }
                    else if (block.timestamp < priceTimes[j + 1] && order.lastTime >= priceTimes[j] && block.timestamp > order.lastTime) {
                        rewardU = ((block.timestamp - order.lastTime) * _cs.mintRate * order.amount) / (10000 * _cs.dayTimes);
                    }
                    else if (block.timestamp < priceTimes[j + 1] && order.lastTime < priceTimes[j] && block.timestamp > priceTimes[j]) {
                        rewardU = ((block.timestamp - priceTimes[j]) * _cs.mintRate * order.amount) / (10000 * _cs.dayTimes);
                    }
                    if (rewardU > 0) {
                        reward += rewardU;
                        rewardToken += (1e18 * rewardU) / prices[j];
                    }
                }
                if (reward + order.rewardU > order.rewardMax) {
                    rewardToken = (rewardToken * order.rewardMax) / reward;
                    reward = order.rewardMax - order.rewardU;
                    order.isValid = false;
                    releaseAmount += order.amount;
                    emit Actions(account, 3, order.index, order.amount, order.lastTime, user.actual);
                }
                order.rewardU += reward;
                order.reward += rewardToken;
                order.lastTime = block.timestamp;
                order.lastPrice = _ti.priceTotal;
                rewardTotalU += reward;
                rewardTotal += rewardToken;
            }
            if (!order.isValid && order.index == user.lastOut + 1) user.lastOut = order.index;
        }
        if (rewardTotal > 0) {
            user.balance += rewardTotal;
            user.balanceU += rewardTotalU;
            if (user.rewardMax < rewardTotalU) user.rewardMax = 0;
            else user.rewardMax -= rewardTotalU;
            if (_ti.totalRewardMax < rewardTotalU) _ti.totalRewardMax = 0;
            else _ti.totalRewardMax -= rewardTotalU;
            user.rewardStatic += rewardTotal;
            _ti.totalRewardStatic += rewardTotal;
        }
        if (releaseAmount > 0) {
            if (_ti.totalActual < releaseAmount) _ti.totalActual = 0;
            else _ti.totalActual -= releaseAmount;
            if (user.actual < releaseAmount) user.actual = 0;
            else user.actual -= releaseAmount;
            if (user.actual == 0 && teams[user.refer].inviteValids > 0) teams[user.refer].inviteValids--;
            _updateTeamAmount(account, releaseAmount, false);
        }
    }
    function _sendRewardInvite(address account, uint amount, uint usdt) private returns (uint reward, uint rewardU) {
        address refer = users[account].refer;
        UserInfo storage user = users[refer];
        reward = (amount * _cs.inviteRate) / 10000;
        rewardU = (usdt * _cs.inviteRate) / 10000;
        if (user.actual > 0 && reward > 0) {
            _handleStakeReward(refer, reward, rewardU, 12);
        }
    }
    function _sendRewardTeam(address account, uint amount, uint usdt) private returns (uint rewardResult) {
        address refer = users[account].refer;
        uint currentLevel;
        uint currentRate;
        uint reward;
        uint rewardU;
        rewardResult = (amount * (_cm.teamRates[_cm.teamRates.length - 1])) / 10000;
        for (uint256 i; i < 100; ++i) {
            if (refer == address(0)) break;
            UserInfo storage user = users[refer];
            if (user.actual > 0 && teams[refer].level > currentLevel) {
                currentLevel = teams[refer].level;
                reward = (amount * (_cm.teamRates[currentLevel - 1] - currentRate)) / 10000;
                rewardU = (usdt * (_cm.teamRates[currentLevel - 1] - currentRate)) / 10000;
                currentRate = _cm.teamRates[currentLevel - 1];
                _handleStakeReward(refer, reward, rewardU, 13);
            }
            if (currentLevel >= _cm.teamRates.length) break;
            refer = users[refer].refer;
        }
    }
    function _handleStakeReward(address refer, uint reward, uint rewardU, uint category) private {
        _updateUser(refer);
        UserInfo storage parent = users[refer];
        _ti.totalExtract += reward;
        _ta.TOKEN.transfer(refer, reward);
        if (category == 12) {
            _ti.totalRewardInvite += reward;
            parent.rewardInvite += reward;
        }
        else if (category == 13 || category == 14 || category == 15) {
            _ti.totalRewardTeam += reward;
            parent.rewardTeam += reward;
        }


    }
    function _updateTeamAmount(address account, uint256 amount, bool isAdd) private {
        address refer = users[account].refer;
        address currentAdd = account;
        for (uint256 i; i < 100; ++i) {
            if (refer == address(0)) break;
            if (isAdd) {
                teams[refer].teamAmount += amount;
            }
            else if (teams[refer].teamAmount <= amount) {
                teams[refer].teamAmount = 0;
            }
            else teams[refer].teamAmount -= amount;
            _updateTeamMax(currentAdd, refer);
            currentAdd = refer;
            refer = users[refer].refer;
        }
    }
    function _updateTeamMax(address account, address refer) private {
        address maxAddr = teams[refer].maxAccount;
        if (maxAddr != account) {
            uint256 mAmount = teams[maxAddr].teamAmount + users[maxAddr].actual;
            uint256 aAmount = teams[account].teamAmount + users[account].actual;
            uint256 minAmount = teams[refer].teamAmount;
            if (mAmount >= aAmount) {
                if (minAmount > mAmount) minAmount -= mAmount;
                else minAmount = 0;
            }
            else {
                teams[refer].maxAccount = account;
                teams[refer].teamMax = aAmount;
                if (minAmount > aAmount) minAmount -= aAmount;
                else minAmount = 0;
            }
            teams[refer].teamMin = minAmount;
        }
        else {
            teams[refer].teamMax = teams[maxAddr].teamAmount + users[account].actual;
        }
        _handleTeamLevel(refer, teams[refer].level, _getTeamLevel(teams[refer].teamMin));
    }
    function _handleTeamLevel(address refer, uint oldLevel, uint newLevel) private {
        if (newLevel > oldLevel || (!teams[refer].isManual && newLevel != oldLevel)) {
            teams[refer].level = newLevel;
        }
    }
    function _getTeamLevel(uint teamAmount) private view returns (uint level) {
        for (uint i = 0; i < _cm.teamAmounts.length; i++) {
            if (teamAmount >= _cm.teamAmounts[i]) {
                level = i + 1;
            }
        }
    }
}
