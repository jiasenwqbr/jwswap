pragma solidity 0.7.0;

import "./IERC20.sol";
import "./IMintableToken.sol";
import "./IDividends.sol";
import "./SafeMath.sol";

contract Token is IERC20, IMintableToken, IDividends {
    using SafeMath for uint256;

    // ------------------------------------------ //
    // ----- BEGIN: DO NOT EDIT THIS SECTION ---- //
    // ------------------------------------------ //
    uint256 public totalSupply;
    uint256 public decimals = 18;
    string public name = "Test token";
    string public symbol = "TEST";
    mapping (address => uint256) public balanceOf;
    // ------------------------------------------ //
    // ----- END: DO NOT EDIT THIS SECTION ------ //  
    // ------------------------------------------ //

    // ------------------------
    // Additional State
    // ------------------------
    mapping(address => mapping(address => uint256)) private _allowances;

    address[] private _holders;
    mapping(address => bool) private _isHolder;

    mapping(address => uint256) private _dividends;

    // ------------------------
    // IERC20
    // ------------------------
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        _allowances[msg.sender][spender] = value;
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override returns (bool) {
        require(_allowances[from][msg.sender] >= value, "Allowance exceeded");
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    // ------------------------
    // IMintableToken
    // ------------------------
    function mint() external payable override {
        require(msg.value > 0, "Must send ETH");

        balanceOf[msg.sender] = balanceOf[msg.sender].add(msg.value);
        totalSupply = totalSupply.add(msg.value);

        _addHolder(msg.sender);
    }

    function burn(address payable dest) external override {
        uint256 amount = balanceOf[msg.sender];
        require(amount > 0, "Nothing to burn");

        balanceOf[msg.sender] = 0;
        totalSupply = totalSupply.sub(amount);

        // send ETH to dest
        dest.transfer(amount);

        // remove holder if balance zero
        _removeHolder(msg.sender);
    }

    // ------------------------
    // Internal transfer helper
    // ------------------------
    function _transfer(address from, address to, uint256 value) internal {
        require(balanceOf[from] >= value, "Insufficient balance");

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);

        _addHolder(to);
        _removeHolder(from);
    }

    // ------------------------
    // Holder management
    // ------------------------
    function _addHolder(address user) internal {
        if (!_isHolder[user] && balanceOf[user] > 0) {
            _holders.push(user);
            _isHolder[user] = true;
        }
    }

    function _removeHolder(address user) internal {
        if (_isHolder[user] && balanceOf[user] == 0) {
            _isHolder[user] = false;
        }
    }

    function getNumTokenHolders() external view override returns (uint256) {
        uint256 count = 0;
        for (uint i = 0; i < _holders.length; i++) {
            if (_isHolder[_holders[i]]) {
                count += 1;
            }
        }
        return count;
    }

    function getTokenHolder(uint256 index) external view override returns (address) {
        uint256 count = 0;
        for (uint i = 0; i < _holders.length; i++) {
            if (_isHolder[_holders[i]]) {
                count += 1;
                if (count == index) {
                    return _holders[i];
                }
            }
        }
        revert("Index out of range");
    }

    // ------------------------
    // Dividends
    // ------------------------
    function recordDividend() external payable override {
        require(msg.value > 0, "No ETH sent");

        uint256 supply = totalSupply;
        require(supply > 0, "No tokens minted");

        for (uint i = 0; i < _holders.length; i++) {
            address holder = _holders[i];
            if (_isHolder[holder] && balanceOf[holder] > 0) {
                uint256 share = msg.value.mul(balanceOf[holder]).div(supply);
                _dividends[holder] = _dividends[holder].add(share);
            }
        }
    }

    function getWithdrawableDividend(address payee) external view override returns (uint256) {
        return _dividends[payee];
    }

    function withdrawDividend(address payable dest) external override {
        uint256 amount = _dividends[msg.sender];
        require(amount > 0, "No dividends");

        _dividends[msg.sender] = 0;
        dest.transfer(amount);
    }

    // ------------------------
    // Burn to arbitrary dest helper (for tests)
    // ------------------------
    function burn(address payable dest) external payable {
        uint256 amount = balanceOf[msg.sender];
        require(amount > 0, "Nothing to burn");

        balanceOf[msg.sender] = 0;
        totalSupply = totalSupply.sub(amount);

        // send ETH to dest
        dest.transfer(amount);

        _removeHolder(msg.sender);
    }
}