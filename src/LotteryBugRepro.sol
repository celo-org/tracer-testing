// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./interface/IRandom.sol";

contract LotteryBugRepro {
    IRandom public constant RANDOMNESS_ADDRESS =
        IRandom(0x000000000000000000000000000000000000d015);

    address[] public winners;
    address[] public members;

    event LotteryWinner(
        address indexed winner,
        uint256 prize,
        uint256 timestamp
    );
    event RandomValueSelected(uint256 randomValue);
    event WinnerSelected(address winner);

    constructor(uint256 additionalArraySlots) {
        // Start with offset for ease of visually distinguishing addresses
        // 4096 offset -> 0th address at 0x0000000000000000000000000000000000001000
        uint160 offset = 4096;
        require (additionalArraySlots > 0, "must have at least 2 array slots");
        for (uint160 i = offset; i < offset + additionalArraySlots + 1; i++) {
            members.push(address(i));
        }
    }

    function runLottery() external payable {
        uint256 randomVal = _getRandomNumber();
        uint256 index = randomVal % members.length;
        // Reduce flakiness by not using 0th index if that's computed legitimately
        if (randomVal != 0 && index == 0) {
            index++;
        }
        emit RandomValueSelected(randomVal);
        address _winnerAddress = members[index];
        // Purely for debugging
        winners.push(_winnerAddress);
        emit WinnerSelected(_winnerAddress);
        address payable winnerTest = payable(_winnerAddress);
        winnerTest.transfer(msg.value);
        emit LotteryWinner(winnerTest, msg.value, block.timestamp);
    }

    function getMembers() external view returns(address[] memory) {
        return members;
    }

    function getWinners() external view returns(address[] memory) {
        return winners;
    }

    function _getRandomNumber() public view returns (uint256) {
        return uint256(RANDOMNESS_ADDRESS.random());
    }
}
