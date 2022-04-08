// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract bulkSend is Ownable {
    using SafeERC20 for IERC20;

    function batchTransfer(
        IERC20 tokenAddress,
        address[] calldata userAddr,
        uint256[] calldata amount
    ) external onlyOwner {
        require(userAddr.length == amount.length,"!=length");
        for (uint256 i = 0; i < userAddr.length; i++) {
            tokenAddress.safeTransfer(userAddr[i],amount[i]);
        }
    }


}



