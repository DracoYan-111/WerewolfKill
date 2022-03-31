// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract WerewolfKill is IERC20, Ownable {
    using SafeMath for uint256;
    using TransferHelper for address;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _blackList;
    bool takeFee = false;

    //1% burn
    uint256 public _burnFee = 10;
    //2% Lp dividend
    uint256 public _dividendFee = 20;
    //3% Add l P
    uint256 public _liquidityFee = 30;
    //denominator
    uint256 public _denominatorOfFee = 1000;
    //Black hole address
    address private _burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public usdt_decimals = 18;

    IPancakeRouter02 public _uniswapV2Router;
    address public uniswapV2Pair;

    //main
    //address public pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //address public husdtTokenAddress = 0x55d398326f99059fF775485246999027B3197955;
    // test
    address public pancakeRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public husdtTokenAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;

    StorageTokenContract stc;
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 total_
    ) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = total_ * 10 ** decimals();
        _balances[_msgSender()] += _totalSupply;

        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;

        _uniswapV2Router = IPancakeRouter02(pancakeRouterAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), husdtTokenAddress);

        stc = new StorageTokenContract(owner(), husdtTokenAddress);

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 1000, "Transfer amount must be greater than zero");
        require(!_blackList[from] && !_blackList[to], "Cannot be blacklisted");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {_balances[from] = fromBalance - amount;}

        uint256 newAmount = 0;
        if (takeFee) {
            newAmount = amount.div(_denominatorOfFee).mul(_burnFee);
            _tokenTransfer(from, _burnAddress, newAmount);
        }

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            _tokenTransfer(from, to, amount.sub(newAmount));
        } else {
            if (from == uniswapV2Pair) {
                _tokenTransferBuyOrSell(to, from, to, amount.sub(newAmount));
            } else if (to == uniswapV2Pair) {
                _tokenTransferBuyOrSell(from, from, to, amount.sub(newAmount));
            } else {
                _tokenTransfer(from, to, amount.sub(newAmount));
            }
        }
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 amount
    ) private {

        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    /**
    * @dev buy or sell
    */
    function _tokenTransferBuyOrSell(
        address restrictedAddress,
        address from,
        address to,
        uint256 amount
    ) private {
        if (!_isExcludedFromFee[restrictedAddress]) {
            uint256 dividendFee_ = amount.div(_denominatorOfFee).mul(_dividendFee);
            uint256 liquidityFee_ = amount.div(_denominatorOfFee).mul(_liquidityFee);

            // Transfer to the token contract and wait for the injection of liquidity
            _tokenTransfer(from, address(this), dividendFee_);
            // Transfer to the fund management contract and wait for lp dividends
            _tokenTransfer(from, address(stc), liquidityFee_);
            // The original amount minus the amount of destruction, and the rest is transferred to the user's address
            _tokenTransfer(from, to, amount.sub(dividendFee_ + liquidityFee_));

        } else {
            _tokenTransfer(from, to, amount);
        }
    }


    /**
    * @dev swap and add lp
    *
    *
    */
    function swapAndLiquify() public {

        uint256 half = _balances[address(this)].div(2);

        swapTokensForETH(half);

        uint256 otherHalf = _balances[address(this)];
        uint256 newBalance = IERC20(husdtTokenAddress).balanceOf(address(this));

        addLiquidityUSDT(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    /**
    * @dev 将代币换成Usdt
    */
    function swapTokensForETH(uint256 tokenAmount) public {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = husdtTokenAddress;
        path[2] = _uniswapV2Router.WETH();

        _approve(address(this), pancakeRouterAddress, tokenAmount);

        _uniswapV2Router.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        swapEthForUSDT();

    }

    /**
    * @dev 将代币换成Usdt
    */
    function swapEthForUSDT() public {
        uint256 balanceETH = address(this).balance;

        address[] memory path = new address[](3);
        path[0] = _uniswapV2Router.WETH();
        path[1] = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        path[2] = husdtTokenAddress;

        _uniswapV2Router.swapExactETHForTokens{value : balanceETH}(
            1, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    //增加流动性
    //代币数量 以太币数量
    function addLiquidityUSDT(uint256 tokenAmount, uint256 husdtAmount) public {

        _approve(address(this), pancakeRouterAddress, tokenAmount);
        IERC20(husdtTokenAddress).approve(pancakeRouterAddress, husdtAmount);

        _uniswapV2Router.addLiquidity(
            address(this),
            husdtTokenAddress,
            tokenAmount,
            husdtAmount,
            1, // slippage is unavoidable
            1, // slippage is unavoidable
            owner(),
            block.timestamp
        );

    }

    /*  *//**
    * @dev 卖出
    *
    *
    *//*
    function _tokenTransferSell(
        address restrictedAddress,
        address from,
        address to,
        uint256 amount
    ) private {
        if (!_isExcludedFromFee[restrictedAddress]) {
            uint256 dividendFee_ = amount.div(_denominatorOfFee).mul(_dividendFee);
            uint256 liquidityFee_ = amount.div(_denominatorOfFee).mul(_liquidityFee);

            //转移至该token合约，等待注入流动性
            _tokenTransfer(from, address(this), dividendFee_);
            //转移至资金管理合约，等待lp分红
            _tokenTransfer(from, stc, liquidityFee_);
            //原有金额减去销毁数量，剩余转移至用户地址
            _tokenTransfer(from, to, amount.sub(dividendFee_ + liquidityFee_));

        } else {
            _tokenTransfer(from, to, amount);
        }
    }*/


    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }

    //to recieve ETH from uniswapV2Router when swaping
    //交换时从 uniswapV2Router 接收 ETH
    receive() external payable {}

    // ========== onlyOwner ==========
    function setBlack(address account, bool state) public onlyOwner {
        _blackList[account] = state;
    }
}

contract StorageTokenContract is Ownable {
    using TransferHelper for address;
    address token;

    constructor(address tokenOwner, address _token) {
        token = _token;
        _token.safeApprove(tokenOwner, ~uint256(0));
        transferOwnership(tokenOwner);
    }

    function transferToken() public onlyOwner {
        IERC20 tokenERC20 = IERC20(token);
        uint256 balance = tokenERC20.balanceOf(address(this));
        token.safeTransfer(owner(), balance);
    }
}