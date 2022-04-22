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
        // 质押金额
        uint256 pledgeAmount;
        // 质押时间
        uint256 pledgeTime;
        // 质押结束时间
        uint256 pledgeDuration;
        // 奖励结束时间
        uint256 rewardDuration;
        // 上次操作时间
        uint256 lastOperationTime;
        // 每秒奖励数量
        uint256 numberOfRewardsPerSecond;
        // 每秒缓释数量
        uint256 numberOfSustainedReleasesPerSecond;
    }

    mapping(address => mapping(uint256 => UserPledge)) userData;

    /// @dev time array
    uint256[] public lengthOfTime;
    uint256[] public rewardMultiplier;

    /// @dev 代币信息
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    /// @dev
    uint256 public singleMonth = 30 days;
    uint256 public constant unit = 10;

    /// @dev
    uint256 private _totalSupply;


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
    * @dev 每秒本金数量
    *
    *
    *
    */
    function userPrincipalAmount(uint256 subscript) public view returns (uint256){
        UserPledge memory userData_ = userData[_msgSender()][lengthOfTime[subscript]];

        require(userData_.pledgeAmount > 0, "!");

        if (userData_.pledgeTime == userData_.pledgeDuration) return userData_.numberOfSustainedReleasesPerSecond;

        if (block.timestamp < userData_.rewardDuration) return 0;

        // 每秒缓释 * ((当前时间 与 质押结束时间 取小) - 上次操作时间)
        return userData_.numberOfSustainedReleasesPerSecond.mul(
            Math.min(block.timestamp, userData_.pledgeDuration)
            .sub(userData_.lastOperationTime)
        );
    }

    /**
    * @dev 用户每秒奖励
    *
    *
    *
    *
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

    // ==================== SET ====================

    /**
    * @dev 用户质押
    * @param amount 用户质押数量
    * @param subscript 用户质押时长数组下标
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

        // 质押数量
        userData_.pledgeAmount = amount;
        // 质押时间
        userData_.pledgeTime = block.timestamp;
        // 质押结束时间
        userData_.pledgeDuration = pledgeDuration_;
        // 奖励结束时间
        userData_.rewardDuration = rewardDuration_;
        // 上次操作时间
        userData_.lastOperationTime = rewardDuration_;
        // 每秒奖励数量
        userData_.numberOfRewardsPerSecond = numberOfRewardsPerSecond_;
        // 每秒缓释数量
        userData_.numberOfSustainedReleasesPerSecond = numberOfSustainedReleasesPerSecond_;

        emit UserPledgeData(_msgSender(), amount, lengthOfTime[subscript]);
    }

    /**
    * @dev 用户提取本金
    * @param subscript 用户质押时长数组下标
    */
    function withdraw(uint256 subscript) public {
        UserPledge storage userData_ = userData[_msgSender()][lengthOfTime[subscript]];
        require(userData_.pledgeAmount >= 0, "Not pledged this month");
        uint256 benjin = userPrincipalAmount(subscript);
        require(benjin > 0, "no reward");
        userData_.pledgeAmount -= benjin;
        _totalSupply -= amount;
        userData_.lastOperationTime = block.timestamp;
        // stakingToken.safeTransfer(_msgSender,benjin);
        emit UserWithdrawData(_msgSender(), benjin, block.timestamp);
    }

    /**
    * @dev 用户提取奖励
    * @param subscript 用户质押时长数组下标
    */
    function getReward(uint256 subscript) public {
        UserPledge memory userData_ = userData[_msgSender()][lengthOfTime[subscript]];
        require(userData_.pledgeAmount >= 0, "Not pledged this month");
        uint256 jiangli = userAwardAmount(subscript);
        require(jiangli > 0, "no reward");
        // rewardsToken.safeTransfer(_msgSender,jiangli);
        emit UserRewardData(_msgSender(), jiangli, block.timestamp);
    }
}
