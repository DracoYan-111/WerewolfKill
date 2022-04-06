// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IStorageTokenContract {
    function werewolfKillWithdraw() external;

    function notifyRewardAmount(uint256 reward) external;
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


contract WerewolfKill is IERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 usdtReceived, uint256 tokensIntoLiqudity);
    event UserLiquify(uint256 tokensSwapped, uint256 usdtReceived);

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

    // Dividend contract reward amount per second
    uint256 public rewardPerSecond;
    // The lp dividend contract starts to generate the number of rewards
    uint256 public lpDividendsStartToRewardNum;
    // Automatically inject the upper limit of the amount of liquidity
    uint256 public tokensSellToAddToLiquidityNum;
    // Is the lp dividend contract open?
    bool public whetherToOpen;

    IPancakeRouter02 public _uniswapV2Router;
    address public uniswapV2Pair;

    // main
    //address public pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //IERC20 public husdtTokenAddress = IERC20(0x55d398326f99059fF775485246999027B3197955);
    // test
    address public pancakeRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IERC20 public husdtTokenAddress = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);

    //Black hole address
    address private _burnAddress = 0x000000000000000000000000000000000000dEaD;

    StorageTokenContract public stc;

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
        uint256 total_,
        uint256 addLpMax_,
        uint256 dividendsMax_,
        uint256 rewardPerSecond_
    ) {
        _name = "LLL";
        _symbol = "LLL";
        _totalSupply = total_ * 10 ** decimals();

        rewardPerSecond = rewardPerSecond_;
        lpDividendsStartToRewardNum = dividendsMax_ * 10 ** decimals();
        tokensSellToAddToLiquidityNum = addLpMax_ * 10 ** decimals();
        _balances[_msgSender()] += _totalSupply;

        _uniswapV2Router = IPancakeRouter02(pancakeRouterAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(husdtTokenAddress));

        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;

        stc = new StorageTokenContract(uniswapV2Pair, owner(), address(this), husdtTokenAddress);
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        _transfer(_msgSender(), to, amount);
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
        require(amount > 10000, "Transfer amount must be greater than 1000");
        require(!_blackList[from] && !_blackList[to], "Cannot be blacklisted");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }

        uint256 newAmount;
        if (takeFee) {
            newAmount = amount.div(_denominatorOfFee).mul(_burnFee);
            _tokenTransfer(from, _burnAddress, newAmount);
        }

        if (from == uniswapV2Pair) {
            _tokenTransferBuyOrSell(to, from, to, amount.sub(newAmount));
        } else if (to == uniswapV2Pair) {
            _tokenTransferBuyOrSell(from, from, to, amount.sub(newAmount));
        } else {
            _tokenTransfer(from, to, amount.sub(newAmount));
        }
    }

    /*
    * @dev Token transfer without loss
    */
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
    * @param restrictedAddress Transaction originator address
    */
    function _tokenTransferBuyOrSell(
        address restrictedAddress,
        address from,
        address to,
        uint256 amount
    ) private {
        // Check if the transaction originator is Excluded From Fee
        if (!_isExcludedFromFee[restrictedAddress]) {
            // Satisfy the upper limit injection lp
            if (_balances[address(this)] >= tokensSellToAddToLiquidityNum) swapAndLiquify();
            // Start staking lp to generate rewards
            // Start staking lp to generate rewards
            if (!whetherToOpen && _balances[address(stc)] >= lpDividendsStartToRewardNum) {
                IStorageTokenContract(address(stc)).notifyRewardAmount(rewardPerSecond);
                whetherToOpen = true;
            }


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
    */
    function swapAndLiquify() private {
        uint256 tokenAmount = _balances[address(this)].div(2);
        uint256 initialBalance = husdtTokenAddress.balanceOf(address(this));

        // address(this) token -> address(stc) usdt -> address(this) usdt
        uint256 half = swapTokensForUsdt(tokenAmount);

        // add lp
        uint256 newBalance = addLiquidityUSDT(initialBalance, half);

        emit SwapAndLiquify(tokenAmount, newBalance, half);

    }

    /**
    * @dev Swap token
    * @param tokenAmount Exact other half quantity
    * @return Amount of tokens injected into liquidity
    */
    function swapTokensForUsdt(uint256 tokenAmount) private nonReentrant returns (uint256){
        uint256 tokenAmountTwo = _balances[address(this)].sub(tokenAmount);
        //token -> usdt
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(husdtTokenAddress);

        _approve(address(this), pancakeRouterAddress, tokenAmountTwo);

        //token:address(this) token -> address(uniswapV2Pair)
        //usdt:address(uniswapV2Pair) token -> address(stc)
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmountTwo,
            0, // accept any amount of usdt
            path,
            address(stc),
            block.timestamp
        );

        //usdt:address(stc) -> address(this)
        IStorageTokenContract(address(stc)).werewolfKillWithdraw();

        return tokenAmountTwo;
    }

    /**
    * @dev inject liquidity
    * @param initialBalance Amount of usdt before swap
    * @param half Increase the number of lp tokens
    * @return The amount of usdt in this transaction
    */
    function addLiquidityUSDT(uint256 initialBalance, uint256 half) private nonReentrant returns (uint256){
        uint256 usdtAmount = (husdtTokenAddress.balanceOf(address(this))).sub(initialBalance);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(husdtTokenAddress);

        uint256[] memory tokenAmount = _uniswapV2Router.getAmountsOut(half, path);

        _approve(address(this), pancakeRouterAddress, tokenAmount[0]);
        husdtTokenAddress.safeApprove(pancakeRouterAddress, tokenAmount[1]);

        //token:address(this) token -> address(uniswapV2Pair)
        //usdt:address(this) token -> address(uniswapV2Pair)
        _uniswapV2Router.addLiquidity(
            path[0],
            path[1],
            tokenAmount[0],
            tokenAmount[1],
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        return usdtAmount;
    }

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

    receive() external payable {}

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
    * @dev Set black
    * @param accounts Account list
    * @param state Account state
    */
    function setBlack(address[] memory accounts, bool state) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _blackList[accounts[i]] = state;
        }
    }

    /**
    * @dev Set excludedFromFee
    * @param accounts Account list
    * @param state Account state
    */
    function setExcludedFromFee(address[] memory accounts, bool state) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = state;
        }
    }

    /**
    * @dev Set liquidity pool address
    * @param router New router
    */
    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

    /**
    * @dev claim Tokens
    * @param token Token address(address(0) == ETH)
    * @param amount Claim amount
    */
    function claimTokens(
        address token,
        uint256 amount
    ) public onlyOwner {
        if (amount > 0) {
            if (token == address(0)) {
                payable(owner()).transfer(amount);
            } else {
                IERC20(token).safeTransfer(owner(), amount);
            }
        }
    }

    /**
    * @dev Start transaction destruction
    */
    function burnTokens() public onlyOwner {
        takeFee = true;
    }

    /* ========== USER ADD LP ========== */

    /**
    * @dev Get the added liquidity ratio
    * @param tokenOrUsdt Token selection
    *        -true:Enter the number of tokens to get the number of usdt
    *        -false:Enter the number of usdt to get the number of tokens
    * @param tokenAmount Token amount
    */
    function getAmountInOrOut(bool tokenOrUsdt, uint256 tokenAmount) public view returns (uint256 rAmount){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(husdtTokenAddress);

        if (tokenOrUsdt) {
            rAmount = _uniswapV2Router.getAmountsOut(tokenAmount, path)[1];
        } else {
            rAmount = _uniswapV2Router.getAmountsIn(tokenAmount, path)[0];
        }
    }

    /**
    * @dev user inject liquidity(approve usdt in advance)
    * @param tokenAmount The number of tokens to be exchanged
    * @param usdtAmount Amount of usdt to be exchanged
    */
    function userAddLiquidityUSDT(uint256 tokenAmount, uint256 usdtAmount) public nonReentrant {
        require(tokenAmount > 1000 || usdtAmount > 1000, "too few");

        _approve(_msgSender(), address(this), tokenAmount);
        _transfer(_msgSender(), address(this), tokenAmount);
        husdtTokenAddress.safeTransferFrom(_msgSender(), address(this), usdtAmount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(husdtTokenAddress);

        _approve(address(this), pancakeRouterAddress, tokenAmount);
        husdtTokenAddress.safeApprove(pancakeRouterAddress, usdtAmount);

        _uniswapV2Router.addLiquidity(
            path[0],
            path[1],
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _msgSender(),
            block.timestamp
        );
        emit UserLiquify(tokenAmount, usdtAmount);

    }
}

// @title Token transfer and pledge lp to obtain token rewards
contract StorageTokenContract is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address werewolfKill;

    IERC20 public  husdtTokenAddress;
    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _stakingToken,
        address tokenOwner,
        address _werewolfKill,
        IERC20 _husdtTokenAddress
    ) {
        husdtTokenAddress = _husdtTokenAddress;
        werewolfKill = _werewolfKill;
        husdtTokenAddress.safeApprove(_werewolfKill, ~uint256(0));
        transferOwnership(tokenOwner);
        rewardsToken = IERC20(_werewolfKill);
        stakingToken = IERC20(_stakingToken);
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
        );
    }

    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount) external nonReentrant updateReward(_msgSender()) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        stakingToken.safeTransferFrom(_msgSender(), address(this), amount);
        emit Staked(_msgSender(), amount);
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(_msgSender()) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        stakingToken.safeTransfer(_msgSender(), amount);
        emit Withdrawn(_msgSender(), amount);
    }

    function getReward() public nonReentrant updateReward(_msgSender()) {
        uint256 reward = rewards[_msgSender()];
        if (reward > 0) {
            rewards[_msgSender()] = 0;
            rewardsToken.safeTransfer(_msgSender(), reward);
            emit RewardPaid(_msgSender(), reward);
        }
    }

    function exit() external {
        withdraw(_balances[_msgSender()]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function werewolfKillWithdraw() public {
        require(_msgSender() == werewolfKill, "WK:not allowed");
        uint256 balance = husdtTokenAddress.balanceOf(address(this));
        husdtTokenAddress.safeTransfer(werewolfKill, balance);
    }

    function notifyRewardAmount(uint256 reward) external updateReward(address(0)) {
        require(werewolfKill == _msgSender(), "STC:not allowed");
        rewardRate = reward;

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(99999 days);
        emit RewardAdded(reward);
    }

    function claimTokens(
        address token,
        uint256 amount
    ) public onlyOwner {
        if (amount > 0) {
            if (token == address(0)) {
                payable(owner()).transfer(amount);
            } else {
                IERC20(token).safeTransfer(owner(), amount);
            }
        }
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}