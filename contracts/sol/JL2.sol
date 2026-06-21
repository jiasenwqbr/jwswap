// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
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
interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function totalSupply() external view returns (uint);
    function approve(address guy, uint wad) external returns (bool);
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}
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
interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
contract ERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
    function _transfer(address from, address recipient, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        address to = recipient;
        if (address(1) == recipient) to = address(0);
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _balances[address(0)] += amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
}
contract Distributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
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
contract AToken is ERC20, Ownable {
    using Address for address;
    struct ConfigSingle {
        uint openTime;
        uint removeRate;
        uint addPoolRate;
        uint openSwap;
        uint mainAmount;
        uint autoSwap;
    }
    struct TotalInfo {
        uint startBlock;
        uint startBurn;
        uint lastBurn;
        uint lastBurnBlock;
    }
    struct TokenAdd {
        address market;
        address nodeAdd;
        address swapPair;
        IERC20 USDT;
        IMAIN MAIN;
        ISwapRouter ROUTER;
        Distributor DISTRIBUTOR;
    }
    ConfigSingle private _cs;
    TotalInfo private _ti;
    TokenAdd private _ta;
    mapping(uint => uint) public swapPools;
    mapping(address => bool) public isFeeExempt;
    mapping(address => uint) public userAmounts;
    address private _dead = 0x000000000000000000000000000000000000dEaD;
    bool _inSwapAndLiquify;
    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }
    event Actions(address account, uint category, uint amount1, uint amount2, uint amount3);
    constructor() ERC20("JL", "JL") {
        address recieve = 0xdF245C383c43F86C5D5693B5FAf703C8d35585b3;
        _ta.market = 0xdF245C383c43F86C5D5693B5FAf703C8d35585b3;
       
        _ta.nodeAdd = 0x69aadf4EC8275fFeC584EaBc1d3Db55E8dd83607;
        _ta.MAIN = IMAIN(0x08afFc83216C6a93e8180a35D4397819cd13D998);
        _ta.USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _ta.ROUTER = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _ta.swapPair = pairFor(_ta.ROUTER.factory(), address(this), address(_ta.USDT));
        _ta.DISTRIBUTOR = new Distributor(address(_ta.USDT));
        isFeeExempt[address(this)] = true;
        isFeeExempt[recieve] = true;
        isFeeExempt[address(_ta.MAIN)] = true;
        _cs.removeRate = 5;
        _cs.addPoolRate = 5;
        _cs.autoSwap = 10e18;
        _cs.mainAmount = 690_0000e18;
        _ti.lastBurnBlock = block.number;
        _mint(recieve, 1_3000_0000 * 10 ** decimals());
        _mint(address(_ta.MAIN), _cs.mainAmount);
        transferOwnership(recieve);
        require(address(this) > address(_ta.USDT), "Address Lower");
    }
    function withdrawToken(IERC20 token, uint256 amount) public onlyOwner {
        token.transfer(msg.sender, amount);
    }
    function setTokenAdd(uint256 category, address data) public onlyOwner {
        if (category == 1) _ta.market = data;
        if (category == 2) _ta.nodeAdd = data;
        if (category == 11) _ta.MAIN = IMAIN(data);
    }
    function setConfig(uint256 category, uint256 data) public onlyOwner {
        if (category == 1) _cs.openTime = data;
        if (category == 2) _cs.removeRate = data;
        if (category == 3) _cs.addPoolRate = data;
        if (category == 4) _cs.openSwap = data;
        if (category == 7) _cs.mainAmount = data;
        if (category == 8) _cs.autoSwap = data;
    }
    function setIsFeeExempt(address account, bool newValue) public onlyOwner {
        isFeeExempt[account] = newValue;
    }
    function swapBack() public {
        require(msg.sender == address(_ta.MAIN), "Token: Not Main");
        burnPool();
        uint balance = balanceOf(address(_ta.MAIN));
        if (balance < _cs.mainAmount) {
            balance = _cs.mainAmount - balance;
            require(balanceOf(_ta.swapPair) - balance > getLastPool(), "Token: Over Pool Limit");
            super._transfer(_ta.swapPair, address(_ta.MAIN), balance);
            ISwapPair(_ta.swapPair).sync();
        }
    }
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (_inSwapAndLiquify) {
            super._transfer(from, to, amount);
        }
        else if (from == _ta.swapPair) {
            if (isFeeExempt[to]) {
                super._transfer(from, to, amount);
            }
            else if (_ti.startBlock == 0 || _cs.openTime == 0 || block.timestamp < _cs.openTime) {
                revert("Not Open Swap");
            } else {
                (, uint rOther, uint balanceOther) = _getReserves();
                if (balanceOther > rOther) {
                    userAmounts[to] += getSwapValueUSDT(amount);
                }
                uint256 every = amount / 1000;
                super._transfer(from, address(this), every * 15);
                super._transfer(from, _ta.nodeAdd, every * 15);
                super._transfer(from, to, amount - every * 30);
            }
            if (balanceOf(_ta.swapPair) > swapPools[block.timestamp / 3600]) {
                swapPools[block.timestamp / 3600] = balanceOf(_ta.swapPair);
            }
        }
        else if (to == _ta.swapPair) {
            if (isFeeExempt[from]) {
                super._transfer(from, to, amount);
                if (_ti.startBlock == 0) {
                    _ti.startBlock = block.number;
                    _ti.startBurn = block.timestamp / 3600;
                    _ti.lastBurn = block.timestamp / 3600;
                }
            }
            else if (_ti.startBlock == 0) {
                revert("Not And Liquify");
            } else {
                (uint rThis, uint rOther, uint balanceOther) = _getReserves();
                if (balanceOther >= rOther + (amount * rOther * (100 - _cs.addPoolRate)) / (rThis * 100) && balanceOther <= rOther + (amount * rOther * (100 + _cs.addPoolRate)) / (rThis * 100)) {
                    uint256 every = amount / 1000;
                    super._transfer(from, address(this), every * 15);
                    super._transfer(from, _ta.nodeAdd, every * 15);
                    super._transfer(from, to, amount - every * 30);
                }
                else {
                    burnPool();
                    if (block.number > _ti.lastBurnBlock && balanceOf(_ta.swapPair) - amount > getLastPool()) {
                        super._transfer(_ta.swapPair, _dead, (amount * 8) / 10);
                        ISwapPair(_ta.swapPair).sync();
                        _ti.lastBurnBlock = block.number;
                    }
                    _swapAndLiquify();
                    uint fee;{
                        uint usdt = getSwapValueUSDT(amount);
                        if (userAmounts[from] <= usdt) {
                            fee = ((usdt - userAmounts[from]) * amount * 15) / usdt / 100;
                            userAmounts[from] = 0;
                        } else userAmounts[from] -= usdt;
                    }
                    if (fee > 0) {
                        super._transfer(from, address(this), (fee * 7) / 15);
                        super._transfer(from, _ta.nodeAdd, (fee * 8) / 15);
                    }
                    uint256 every = amount / 1000;
                    super._transfer(from, address(this), every * 15);
                    super._transfer(from, _ta.nodeAdd, every * 15);
                    super._transfer(from, to, amount - every * 30 - fee);
                }
            }
            if (balanceOf(_ta.swapPair) > swapPools[block.timestamp / 3600]) {
                swapPools[block.timestamp / 3600] = balanceOf(_ta.swapPair);
            }
        }
        else {
            super._transfer(from, to, amount);
        }
    }
    function getConfig() public view returns (ConfigSingle memory config, TokenAdd memory tokenAdd, TotalInfo memory totalInfo) {
        config = _cs;
        tokenAdd = _ta;
        totalInfo = _ti;
    }
    function getLastPool() public view returns (uint amount) {
        uint i = 1;
        while (i < 100) {
            amount = swapPools[block.timestamp / 3600 - i];
            i++;
            if (amount > 0) break;
        }
        if (amount == 0) amount = (totalSupply() * 9) / 10;
        else amount = (amount * 9) / 10;
    }
    function getPrice() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_ta.USDT);
        if (_ta.swapPair == address(0)) return 0;
        (uint256 reserve1, uint256 reserve2, ) = ISwapPair(_ta.swapPair).getReserves();
        if (reserve1 == 0 || reserve2 == 0) {
            return 0;
        } else {
            return _ta.ROUTER.getAmountsOut(1 * 10 ** decimals(), path)[1];
        }
    }
    function getSwapValueUSDT(uint amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_ta.USDT);
        if (_ta.swapPair == address(0)) return 0;
        (uint256 reserve1, uint256 reserve2, ) = ISwapPair(_ta.swapPair).getReserves();
        if (reserve1 == 0 || reserve2 == 0) {
            return 0;
        } else {
            return _ta.ROUTER.getAmountsOut(amount, path)[1];
        }
    }
    function getAutoSwapMin() public view returns (uint256) {
        uint256 price = getSwapValueUSDT(1e18);
        if (price == 0) {
            return totalSupply();
        } else {
            return (1e18 * 1e18) / price;
        }
    }
    function swapAndTrans() public {
        _swapAndLiquify();
    }
    function burnPool() public lockTheSwap {
        if (_ti.startBlock == 0) return;
        if (_ti.lastBurn == 0) _ti.lastBurn = _ti.startBurn;
        if (_ti.lastBurn > block.timestamp / 3600) return;
        uint rate = ((_ti.lastBurn - _ti.startBurn) / 24 / 30) * 50 + 100;
        if (rate > 600) rate = 600;
        uint amount = (balanceOf(_ta.swapPair) * rate) / 240000;
        if (balanceOf(_ta.swapPair) - amount > getLastPool()) {
            super._transfer(_ta.swapPair, _dead, amount);
            ISwapPair(_ta.swapPair).sync();
            _ti.lastBurn++;
        }
    }
    function _getReserves() private view returns (uint rThis, uint rOther, uint balanceOther) {
        (uint r0, uint r1, ) = ISwapPair(_ta.swapPair).getReserves();
        if (address(_ta.USDT) < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
        balanceOther = _ta.USDT.balanceOf(_ta.swapPair);
    }
    function _swapAndLiquify() private lockTheSwap {
        if (_ti.startBlock == 0) return;
        uint amount = balanceOf(address(this));
        if (amount >= 1e6) amount -= 1e6;
        else amount = 0;
        if (amount < getAutoSwapMin()) amount = 0;
        if (amount > 0) {
            _swapForUSDT(amount, address(_ta.DISTRIBUTOR));
            uint256 amountU = _ta.USDT.balanceOf(address(_ta.DISTRIBUTOR));
            if (amountU > 0) _ta.USDT.transferFrom(address(_ta.DISTRIBUTOR), _ta.market, amountU);
        }
    }
    function _swapForUSDT(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_ta.USDT);
        super._approve(address(this), address(_ta.ROUTER), tokenAmount);
        _ta.ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, to, block.timestamp);
        emit SwapTokensForTokens(tokenAmount, path);
    }
    function _swapForTokens(uint256 amount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(_ta.USDT);
        path[1] = address(this);
        _ta.USDT.approve(address(_ta.ROUTER), amount);
        _ta.ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp);
        emit SwapTokensForTokens(amount, path);
    }
    function _swapUSDT(uint256 amount, address to) private {
        address[] memory path = new address[](2);
        path[0] = _ta.ROUTER.WETH();
        path[1] = address(_ta.USDT);
        IERC20(_ta.ROUTER.WETH()).approve(address(_ta.ROUTER), amount);
        _ta.ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp);
        emit SwapTokensForTokens(amount, path);
    }
    function _addLiquidity(uint256 tokenAmount, uint256 usdtAmount, address to) private {
        super._approve(address(this), address(_ta.ROUTER), tokenAmount);
        _ta.USDT.approve(address(_ta.ROUTER), usdtAmount);
        _ta.ROUTER.addLiquidity(address(this), address(_ta.USDT), tokenAmount, usdtAmount, 0, 0, to, block.timestamp);
        emit AddLiquidity(tokenAmount, usdtAmount);
    }
    event SwapTokensForTokens(uint256 amountIn, address[] path);
    event AddLiquidity(uint256 tokenAmount, uint256 ethAmount);
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint256(keccak256(abi.encodePacked(hex"ff", factory, keccak256(abi.encodePacked(token0, token1)), hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5")))));
    }
}
