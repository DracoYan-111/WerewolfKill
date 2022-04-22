// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract seedTokenPool is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // ==================== EVENT ====================
    event UserPledgeData(address userAddress, uint256 amount, uint256 pledgeDuration);
    event UserWithdrawData(address userAddress, uint256 amount, uint256 pledgeDuration);
    event UserRewardData(address userAddress, uint256 amount, uint256 pledgeDuration);


    struct UserPledge {
        // pledge amount
        uint256 pledgeAmount;
        // pledge time
        uint256 pledgeTime;
        // pledge end time
        uint256 pledgeDuration;
        // Reward end time
        uint256 rewardDuration;
        // last operation time
        uint256 lastOperationTime;
        // Number of rewards per second
        uint256 numberOfRewardsPerSecond;
        // Number of sustained releases per second
        uint256 numberOfSustainedReleasesPerSecond;
    }

    mapping(address => mapping(uint256 => UserPledge)) userData;

    /// @dev time array
    uint256[] public lengthOfTime;
    uint256[] public rewardMultiplier;

    /// @dev Token Information
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    /// @dev Project information
    uint256 public singleMonth = 30 days;
    uint256 public constant unit = 10;
    bool public isReward = false;
    mapping(address => bool) public _blackList;
    uint256 private _totalSupply;


    /**
    * @param rewardsToken_ Reward Token Address
    * @param stakingToken_ Staking token address
    */
    constructor(
        IERC20 rewardsToken_,
        IERC20 stakingToken_
    ) {

        rewardsToken = rewardsToken_;
        stakingToken = stakingToken_;

        lengthOfTime = [0, 1 * singleMonth, 3 * singleMonth, 6 * singleMonth];
        rewardMultiplier = [1, 10, 20, 30];

    }


    // ==================== GET ====================
    /**
    * @dev Total pledge amount
    * @return _totalSupply
    */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev User principal amount
    * @param subscript User pledge duration array subscript
    */
    function userPrincipalAmount(uint256 subscript) public view returns (uint256){
        UserPledge memory userData_ = userData[_msgSender()][lengthOfTime[subscript]];

        if (userData_.pledgeAmount == 0) return 0;

        if (userData_.pledgeTime == userData_.pledgeDuration) return userData_.numberOfSustainedReleasesPerSecond;

        if (block.timestamp < userData_.rewardDuration) return 0;

        // 每秒缓释 * ((当前时间 与 质押结束时间 取小) - 上次操作时间)
        return userData_.numberOfSustainedReleasesPerSecond.mul(
            Math.min(block.timestamp, userData_.pledgeDuration)
            .sub(userData_.lastOperationTime)
        );
    }

    /**
    * @dev Number of user rewards
    * @param subscript User pledge duration array subscript
    */
    function userAwardAmount(uint256 subscript) public view returns (uint256){
        UserPledge memory userData_ = userData[_msgSender()][lengthOfTime[subscript]];

        require(userData_.pledgeAmount > 0, "!");

        // 每秒奖励 * (当前时间 与 奖励结束时间 取小) - 开始时间
        return (userData_.numberOfRewardsPerSecond).mul(
            Math.min(block.timestamp, userData_.rewardDuration)
            .sub(userData_.pledgeDuration)
        );
    }

    // ==================== USER USE ====================

    /**
    * @dev User pledge
    * @param amount User pledge amount
    * @param subscript User pledge duration array subscript
    */
    function stake(
        uint256 amount,
        uint256 subscript
    ) public {

        UserPledge storage userData_ = userData[_msgSender()][lengthOfTime[subscript]];

        require(userData_.pledgeAmount <= 0, "The time has been pledged");
        require(amount >= 10000, "too little pledge");

        // stakingToken.safeTransferFrom(_msgSender,address(this),amount);
        _totalSupply += amount;
        uint256 pledgeDuration_;
        uint256 numberOfRewardsPerSecond_;
        uint256 numberOfSustainedReleasesPerSecond_;

        if (subscript == 0) {
            pledgeDuration_ = block.timestamp;
            numberOfRewardsPerSecond_ = (amount.mul(rewardMultiplier[subscript]).div(unit)).div(singleMonth);
            numberOfSustainedReleasesPerSecond_ = amount;
        }

        pledgeDuration_ = (block.timestamp.add(lengthOfTime[subscript])).add(singleMonth);
        numberOfRewardsPerSecond_ = (amount.mul(rewardMultiplier[subscript]).div(unit)).div(lengthOfTime[subscript]);
        numberOfSustainedReleasesPerSecond_ = amount.div(singleMonth);

        uint256 rewardDuration_ = block.timestamp.add(lengthOfTime[subscript]);

        userData_.pledgeAmount = amount;
        userData_.pledgeTime = block.timestamp;
        userData_.pledgeDuration = pledgeDuration_;
        userData_.rewardDuration = rewardDuration_;
        userData_.lastOperationTime = rewardDuration_;
        userData_.numberOfRewardsPerSecond = numberOfRewardsPerSecond_;
        userData_.numberOfSustainedReleasesPerSecond = numberOfSustainedReleasesPerSecond_;

        emit UserPledgeData(_msgSender(), amount, lengthOfTime[subscript]);
    }

    /**
    * @dev User withdraws principal
    * @param subscript User pledge duration array subscript
    */
    function withdraw(uint256 subscript) public {
        UserPledge storage userData_ = userData[_msgSender()][lengthOfTime[subscript]];
        require(userData_.pledgeAmount >= 0, "Not pledged this month");
        uint256 principal = userPrincipalAmount(subscript);
        require(principal > 10000, "too little principal");
        userData_.pledgeAmount -= principal;
        _totalSupply -= amount;
        userData_.lastOperationTime = block.timestamp;
        // stakingToken.safeTransfer(_msgSender,principal);
        emit UserWithdrawData(_msgSender(), principal, block.timestamp);
    }

    /**
    * @dev User Withdrawal Rewards
    * @param subscript User pledge duration array subscript
    */
    function getReward(uint256 subscript) public {
        require(isReward, "Rewards not enabled");
        UserPledge memory userData_ = userData[_msgSender()][lengthOfTime[subscript]];
        require(userData_.pledgeAmount >= 0, "Not pledged this month");
        uint256 award = userAwardAmount(subscript);
        require(award > 10000, "Too little reward");
        // rewardsToken.safeTransfer(_msgSender,award);
        emit UserRewardData(_msgSender(), award, block.timestamp);
    }

    // ==================== OWNER USE ====================
    /**
    * @dev Set rewards on or off
    * @param newIsReward Reward claim status
    */
    function setIsReward(bool newIsReward) public onlyOwner {
        isReward = newIsReward;
    }

    /**
    * @dev Set up blacklist users
    * @param account User address
    * @param state User status
    */
    function setBlack(address account, bool state) public onlyOwner {
        _blackList[account] = state;
    }

    /**
    * @dev get tokens
    * @param tokenAddress Get token address
    * @param to Payee Address
    * @param amount Get quantity
    */
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
}
