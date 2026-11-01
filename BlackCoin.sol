// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * Black Coin (BC) — Base Mainnet (Chain ID 8453)
 *
 * - Name:        Black Coin
 * - Symbol:      BC
 * - Decimals:    18
 * - Total supply: 1,000,000,000 BC — fixed forever, all minted once to SUPPLY_RECIPIENT
 * - No mint:     nobody can ever create more
 * - No tax:      no buy/sell/transfer fees in the contract
 * - No admin:    no owner, no blacklist, no pause, no upgrade — nothing to control later
 *
 * The full supply is minted to SUPPLY_RECIPIENT (Ken's wallet) no matter which
 * account or factory contract performs the deployment. This matters: Ken's
 * Coinbase Smart Wallet deploys through the public CREATE2 factory contract,
 * so msg.sender in this constructor is the factory — never rely on it here.
 */
contract BlackCoin {
    string public constant name = "Black Coin";
    string public constant symbol = "BC";
    uint8 public constant decimals = 18;
    uint256 public immutable totalSupply;

    /// @notice Ken's wallet — receives the entire 1B supply at deployment.
    address public constant SUPPLY_RECIPIENT = 0xEf8fB653A0aB5b7f01D0CD0DcA07b2C1EE3196E3;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        totalSupply = 1_000_000_000 * (10 ** uint256(decimals)); // 1 billion BC
        balanceOf[SUPPLY_RECIPIENT] = totalSupply;
        emit Transfer(address(0), SUPPLY_RECIPIENT, totalSupply);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "BC: allowance exceeded");
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount;
        }
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "BC: transfer to zero address");
        require(balanceOf[from] >= amount, "BC: insufficient balance");
        unchecked {
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
}
