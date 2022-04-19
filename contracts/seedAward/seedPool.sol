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

    event UserPledgeData(address userAddress, uint256 amount, uint256 pledgeDuration);


    struct UserPledge {
        // 质押金额
        uint256 pledgeAmount;
        // 质押结束时间
        uint256 pledgeDuration;
        // 奖励结束时间
        uint256 rewardDuration;
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
    uint256 public unit = 10;

    /// @dev
    uint256 private _totalSupply;


    constructor(
        IERC20 rewardsToken_,
        IERC20 stakingToken_
    ) {

        rewardsToken = rewardsToken_;
        stakingToken = stakingToken_;

        lengthOfTime = [1 * singleMonth, 3 * singleMonth, 6 * singleMonth];
        rewardMultiplier = [10, 20, 30];

    }

    /**
    * @dev Total pledge amount
    * @return _totalSupply
    */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function userPrincipalAmount(uint256 subscript) external view returns (uint256){
        UserPledge memory userData_ = userData[_msgSender()][lengthOfTime[subscript]];
        if (block.timestamp < userData_.rewardDuration) return 0;

        // 每秒缓释 * (当前时间 与 质押结束时间 取小) - 奖励结束时间
        return userData_.numberOfSustainedReleasesPerSecond.mul(
            Math.min(block.timestamp, userData_.pledgeDuration)
            .sub(userData_.rewardDuration)
        );
    }

    function userAwardAmount(uint256 subscript) external view returns (uint256){
        UserPledge memory userData_ = userData[_msgSender()][lengthOfTime[subscript]];

        // 每秒奖励 * (当前时间 与 奖励结束时间 取小) - 质押时长
        return (userData_.numberOfRewardsPerSecond).mul(
            Math.min(block.timestamp, userData_.rewardDuration)
            .sub(lengthOfTime[subscript])
        );
    }

    //=====

    /**
    * @dev 用户质押
    * @param amount 用户质押数量
    * @param subscript 用户质押时长数组下标
    */
    function stake(
        uint256 amount,
        uint256 subscript
    ) public {
        require(userData[_msgSender()][lengthOfTime[subscript]].pledgeAmount <= 0, "The time has been pledged");
        require(amount >= 10000, "too little pledge");

        // stakingToken.safeTransferFrom(_msgSender,address(this),amount);
        _totalSupply += amount;

        uint256 pledgeDuration_ = (block.timestamp.add(lengthOfTime[subscript])).add(singleMonth);
        uint256 rewardDuration_ = block.timestamp.add(lengthOfTime[subscript]);

        userData[_msgSender()][lengthOfTime[subscript]] = UserPledge(
            amount,
            pledgeDuration_,
            rewardDuration_,
            (amount.mul(rewardMultiplier[subscript])).div(unit),
            amount.div(singleMonth)
        );

        emit UserPledgeData(_msgSender(), amount, lengthOfTime[subscript]);
    }


    //    /**
    //    * @dev 用户提取本金
    //    * @param subscript 用户质押时长数组下标
    //    */
    //    function withdraw(
    //        uint256 subscript
    //    ) public {
    //        require(userData[_msgSender()][lengthOfTime[subscript]].pledgeAmount <= 0, "该月已经质押");
    //        require(amount >= 10000, "质押太少");
    //
    //        // stakingToken.safeTransferFrom(_msgSender,address(this),amount);
    //        _totalSupply += amount;
    //
    //        uint256 pledgeDuration_ = (block.timestamp.add(lengthOfTime[subscript])).add(singleMonth);
    //        uint256 rewardDuration_ = block.timestamp.add(lengthOfTime[subscript]);
    //
    //        userData[_msgSender()][lengthOfTime[subscript]] = UserPledge(
    //            amount,
    //            pledgeDuration_,
    //            rewardDuration_,
    //            (amount.mul(rewardMultiplier[subscript])).dev(unit),
    //            amount.div(singleMonth)
    //        );
    //
    //        emit UserPledgeData(_msgSender(), amount, lengthOfTime[subscript]);
    //    }


}
