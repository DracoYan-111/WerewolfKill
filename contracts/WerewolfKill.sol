// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/// @title StorageTokenContract contract interface
interface IStorageTokenContract {
    function transferToken(address contractAddr) external returns (uint256 balance);
}

/// @title lpDividend contract interface
interface ILpDividend {
    function notifyRewardAmount(uint256 reward, uint256 timestamp) external;

    function transferToken(address contractAddr) external returns (uint256 balance);

    function setRewardsToken(IERC20 usdtAddr, IERC20 tokenAddr) external;

    function getTokenAddr() external view returns (address[3] memory addressList);
}

/// @title UniswapV2Factory contract interface
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

/// @title PancakeRouter01 contract interface
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

/// @title PancakeRouter02 and PancakeRouter01 contract interface
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

/// @title WerewolfKill token contract
/// @author Long
/// @notice This contract is the WerewolfKill token contract
contract WerewolfKill is IERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 usdtReceived, uint256 tokensIntoLiqudity);
    event UserAddLiquify(uint256 tokensSwapped, uint256 usdtReceived);

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

    // lp Distribution contract reward duration
    uint256 public rewardDuration;
    // The lp dividend contract starts to generate the number of rewards
    uint256 public lpDividendsStartToRewardNum;
    // Automatically inject the upper limit of the amount of liquidity
    uint256 public tokensSellToAddToLiquidityNum;

    IPancakeRouter02 public _uniswapV2Router;
    address public uniswapV2Pair;

    /// @dev main chain
    //address public pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //IERC20 public husdtTokenAddress = IERC20(0x55d398326f99059fF775485246999027B3197955);

    /// @dev test chain
    address public pancakeRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IERC20 public husdtTokenAddress = IERC20(0x314b623b0A543aA36401FD61253991932e4ab544);
    //token -> usdt
    address[]  path = new address[](2);

    //Black hole address
    address private _burnAddress = 0x000000000000000000000000000000000000dEaD;

    /// @dev external contract
    address public stc;
    address public lp;
    uint256 public ldContractAmount;

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
        address lp_,
        uint256 total_,
        uint256 addLpMax_,
        uint256 dividendsMax_,
        uint256 rewardDuration_
    ) {
        /// @dev Token Information
        _name = "LLL";
        _symbol = "LLL";
        _totalSupply = total_ * 10 ** decimals();

        /// @dev Additional Information
        rewardDuration = rewardDuration_;
        lpDividendsStartToRewardNum = dividendsMax_ * 10 ** decimals();
        tokensSellToAddToLiquidityNum = addLpMax_ * 10 ** decimals();
        _balances[_msgSender()] += _totalSupply;

        /// @dev Swap Information
        _uniswapV2Router = IPancakeRouter02(pancakeRouterAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(husdtTokenAddress));
        path[0] = address(this);
        path[1] = address(husdtTokenAddress);

        /// @dev Other Information
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;

        /// @dev External contract Information
        stc = address(new storageTokenContract(husdtTokenAddress));
        lp = lp_;

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
        require(from != address(0) && to != address(0), "ERC20: transfer the zero address");
        require(amount > 10000, "Transfer amount must be greater than 10000");
        require(!_blackList[from] && !_blackList[to], "Cannot be blacklisted");

        address[3] memory addresList = ILpDividend(lp).getTokenAddr();
        require(addresList[0] == address(this), "lp contract false");
        if (addresList[1] == address(0) || addresList[2] == address(0)) ILpDividend(lp).setRewardsToken(husdtTokenAddress, IERC20(uniswapV2Pair));

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }
        /// @dev User transfer fee
        uint256 newAmount = 0;
        if (takeFee) {
            newAmount = amount.div(_denominatorOfFee).mul(_burnFee);
            _tokenTransfer(from, _burnAddress, newAmount);
        }

        /// @dev User buys and sells
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
            if (from != uniswapV2Pair) {

                /// @dev Satisfy the upper limit injection lp
                if (_balances[address(this)] >= tokensSellToAddToLiquidityNum) swapAndLiquify();

                // Start staking lp to generate rewards
                if (ldContractAmount >= lpDividendsStartToRewardNum) distributeLp();
            }

            uint256 dividendFee_ = amount.div(_denominatorOfFee).mul(_dividendFee);
            uint256 liquidityFee_ = amount.div(_denominatorOfFee).mul(_liquidityFee);

            // Transfer to the token contract and wait for the injection of liquidity
            _tokenTransfer(from, address(this), dividendFee_);
            // Transfer to the fund management contract and wait for lp dividends
            _tokenTransfer(from, lp, liquidityFee_);
            ldContractAmount += liquidityFee_;
            // The original amount minus the amount of destruction, and the rest is transferred to the user's address
            _tokenTransfer(from, to, amount.sub(dividendFee_ + liquidityFee_));

        } else {
            _tokenTransfer(from, to, amount);
        }
    }


    /**
    * @dev Swap and add lp
    */
    function swapAndLiquify() private {
        uint256 tokenAmount = _balances[address(this)].div(2);
        uint256 initialBalance = husdtTokenAddress.balanceOf(address(this));

        // address(this) token -> address(stc) usdt -> address(this) usdt
        uint256 half = swapTokensForUsdt(tokenAmount, address(this));

        // add lp
        uint256 newBalance = addLiquidityUSDT(initialBalance, half);

        emit SwapAndLiquify(tokenAmount, newBalance, half);

    }

    /**
    * @dev Distribute LP rewards
    */
    function distributeLp() private {
        uint256 oldTokenBalances = _balances[address(this)];
        uint256 oldUsdtBalances = husdtTokenAddress.balanceOf(lp);
        ILpDividend(lp).transferToken(address(this));
        swapTokensForUsdt(oldTokenBalances, lp);
        uint256 newUsdtBalances = husdtTokenAddress.balanceOf(lp);
        uint256 difference = newUsdtBalances > oldUsdtBalances ? newUsdtBalances - oldUsdtBalances : 0;
        if (difference > 0) {
            ILpDividend(lp).notifyRewardAmount(difference.div(rewardDuration), rewardDuration);
            ldContractAmount = 0;
        }
    }

    /**
    * @dev Swap token
    * @param tokenAmount Exact other half quantity
    * @return Amount of tokens injected into liquidity
    */
    function swapTokensForUsdt(uint256 tokenAmount, address to) private returns (uint256){
        uint256 tokenAmountTwo = _balances[address(this)].sub(tokenAmount);

        _approve(address(this), pancakeRouterAddress, tokenAmountTwo);

        //token:address(this) token -> address(uniswapV2Pair)
        //usdt:address(uniswapV2Pair) token -> address(to)
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmountTwo,
            0, // accept any amount of usdt
            path,
            address(stc),
            block.timestamp
        );

        //usdt:address(stc) -> address(to)
        IStorageTokenContract(stc).transferToken(to);

        return tokenAmountTwo;
    }

    /**
    * @dev inject liquidity
    * @param initialBalance Amount of usdt before swap
    * @param half Increase the number of lp tokens
    * @return The amount of usdt in this transaction
    */
    function addLiquidityUSDT(uint256 initialBalance, uint256 half) private returns (uint256){
        uint256 usdtAmount = (husdtTokenAddress.balanceOf(address(this))).sub(initialBalance);

        uint256[] memory tokenAmount = _uniswapV2Router.getAmountsOut(half, path);

        _approve(address(this), pancakeRouterAddress, tokenAmount[0]);
        husdtTokenAddress.safeApprove(pancakeRouterAddress, tokenAmount[1]);

        //token:address(this) -> address(uniswapV2Pair)
        //usdt:address(this) -> address(uniswapV2Pair)
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
    * @dev Set the storageTokenContract contract address
    * @param newStc New storageTokenContract contract address
    */
    function setStc(address newStc) public onlyOwner {
        stc = newStc;
    }

    /**
    * @dev Set lpDividend contract address
    * @param newLp New lpDividend contract address
    */
    function setLp(address newLp) public onlyOwner {
        lp = newLp;
    }

    /**
    * @dev Set liquidity pool address
    * @param router New router
    */
    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

    /**
    * @dev Set lp contract rewardDuration
    * @param newRewardPerSecond Lp contract new rewardDuration
    */
    function setRewardPerSecond(uint256 newRewardPerSecond) public onlyOwner {
        rewardDuration = newRewardPerSecond;
    }

    /**
    * @dev Set up a new dividendFee
    * @param newDividendFee New dividendFee
    * @param newLiquidityFee New liquidityFee
    * @param newBurnFee New burnFee
    */
    function setAllFee(uint256 newDividendFee, uint256 newLiquidityFee, uint256 newBurnFee) public onlyOwner {
        if (newDividendFee != 0) {
            _dividendFee = newDividendFee;
        }
        if (newLiquidityFee != 0) {
            _liquidityFee = newLiquidityFee;
        }
        if (newBurnFee != 0) {
            _burnFee = newBurnFee;
        }
    }

    /**
    * @dev Set TokensSellToAddToLiquidityNum
    * @param newANum new tokensSellToAddToLiquidityNum(decimal!!)
    * @param newBNum new lpDividendsStartToRewardNum(decimal!!)
    */
    function setTokensSellToAddToLiquidityNum(uint256 newANum, uint256 newBNum) public onlyOwner {
        if (newANum != 0) {
            tokensSellToAddToLiquidityNum = newANum * 10 ** decimals();
        }
        if (newBNum != 0) {
            lpDividendsStartToRewardNum = newBNum * 10 ** decimals();
        }
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
        emit UserAddLiquify(tokenAmount, usdtAmount);

    }
}

/// @title Lp dividend contract
/// @author Long
/// @notice This contract is only for lp dividend operation
contract lpDividend is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    /* ========== STATE VARIABLES ========== */

    /// @dev tokens address
    IERC20 public tokenContract;
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => bool) public blacklist;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== VIEWS ========== */

    /**
    * @dev Total pledge amount
    * @return _totalSupply
    */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev User pledge amount
    * @param account User address
    * @return User pledge amount
    */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
    * @dev Determine if the end time is reached
    * @return The current time and the end time are smaller
    */
    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    /*
    * @dev Amount of rewards earned per staked token
    * @return Number of awards
    */
    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
        );
    }

    /**
    * @dev Query the number of rewards a user has received
    * @param account User address
    * @return The number of rewards the user has earned
    */
    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    /**
    * @dev Returns all addresses used for verification
    * @return addressList Token address List
    */
    function getTokenAddr() external view returns (address[3] memory addressList){
        addressList[0] = address(tokenContract);
        addressList[1] = address(rewardsToken);
        addressList[2] = address(stakingToken);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
    * @dev User pledges tokens
    * @param amount User pledge amount
    */
    function stake(uint256 amount) external nonReentrant updateReward(_msgSender()) {
        require(amount > 0, "Cannot stake 0");
        require(!blacklist[_msgSender()], "is blacklist");
        _totalSupply = _totalSupply.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        stakingToken.safeTransferFrom(_msgSender(), address(this), amount);
        emit Staked(_msgSender(), amount);
    }

    /**
    * @dev User redeems principal
    * @param amount The amount of principal redeemed by the user
    */
    function withdraw(uint256 amount) public nonReentrant updateReward(_msgSender()) {
        require(amount > 0, "Cannot withdraw 0");
        require(!blacklist[_msgSender()], "is blacklist");
        _totalSupply = _totalSupply.sub(amount);
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        stakingToken.safeTransfer(_msgSender(), amount);
        emit Withdrawn(_msgSender(), amount);
    }

    /**
    * @dev Users receive rewards
    */
    function getReward() public nonReentrant updateReward(_msgSender()) {
        require(!blacklist[_msgSender()], "is blacklist");
        uint256 reward = rewards[_msgSender()];
        if (reward > 0) {
            rewards[_msgSender()] = 0;
            rewardsToken.safeTransfer(_msgSender(), reward);
            emit RewardPaid(_msgSender(), reward);
        }
    }

    /**
    * @dev User logout(withdraw and getReward)
    */
    function exit() external {
        withdraw(_balances[_msgSender()]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
    * @dev Set user  blacklist
    * @param userAddrs User address array
    * @param condition User status
    *         true:add to blacklist
    *         false:Cancel from blacklist
    */
    function setBlacklist(address[] calldata userAddrs, bool condition) public onlyOwner {
        for (uint256 i; i < userAddrs.length; i++) {
            blacklist[userAddrs[i]] = condition;
        }
    }

    /**
    * @dev Set the number of rewards per second
    * @param reward New number of rewards per second
    * @param timestamp New reward Duration
    */
    function notifyRewardAmount(uint256 reward, uint256 timestamp) external updateReward(address(0)) {
        require(address(tokenContract) == _msgSender() || owner() == _msgSender(), "STC:not allowed");
        rewardRate = reward;

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(timestamp);
        emit RewardAdded(reward);
    }

    /**
    * @dev Set the token address(token contract use once!!!)
    * @param usdtAddr New Reward Token Address
    * @param tokenAddr New pledge token address
    */
    function setRewardsToken(IERC20 usdtAddr, IERC20 tokenAddr) external {
        require(address(tokenContract) == _msgSender() || owner() == _msgSender(), "SRT:not allowed");
        rewardsToken = usdtAddr;
        stakingToken = tokenAddr;
    }

    /**
    * @dev Set the token contract address
    * @param _token Token contract address
    */
    function setWerewolfKillToken(IERC20 _token) public onlyOwner {
        tokenContract = _token;
        _token.safeApprove(address(_token), ~uint(0));
    }

    /**
    * @dev transfer all token token
    * @param contractAddr Payment contract address
    */
    function transferToken(address contractAddr) external returns (uint256 balance) {
        require(address(tokenContract) == _msgSender(), "TT:not allowed");
        balance = tokenContract.balanceOf(address(this));
        tokenContract.safeTransfer(contractAddr, balance);
    }

    function claimTokens(
        address tokenAddress,
        address to,
        uint256 amount
    ) public onlyOwner {
        if (amount > 0) {
            if (tokenAddress == address(0)) {
                payable(to).transfer(amount);
            } else {
                IERC20(tokenAddress).safeTransfer(to, amount);
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
}

/// @title Usdt distribution contract
/// @author Long
/// @notice This contract is only used for Usdt transfer
contract storageTokenContract is Ownable {
    using SafeERC20 for IERC20;

    IERC20 tokenContract;
    constructor(IERC20 _token) {
        tokenContract = _token;
        _token.safeApprove(owner(), ~uint256(0));
    }

    /**
    * @dev Transfer all tokens to contractAddr address
    * @param contractAddr Payee address
    */
    function transferToken(address contractAddr) external onlyOwner returns (uint256 balance) {
        balance = tokenContract.balanceOf(address(this));
        tokenContract.safeTransfer(contractAddr, balance);
    }
}