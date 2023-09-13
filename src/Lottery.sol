// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./interface/IRandom.sol";

contract LottreyClubNative {
    IRandom public constant RANDOMNESS_ADDRESS =
        IRandom(0x000000000000000000000000000000000000d015);

    string public name;
    uint256 public prize;
    uint256 public depositAmount;
    uint256 public membersLimit;

    address public manager;
    address public factory;
    address public _winnerAddress;
    address[] public _membersCounters;

    bool public isLottreyStart = false;

    mapping(address => uint256) private _balance;

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "LottreyClub: Only manager can call this function"
        );
        _;
    }

    event NewRegister(address indexed member, uint256 timestamp);
    event LottreyWinner(
        address indexed winner,
        uint256 prize,
        uint256 timestamp
    );
    event RandomValueSelected(uint256 randomValue);
    event RandomUintIdx(uint256 i);
    event RandomSeedIdx(uint256 i);
    event WinnerSelected(address winner);

    constructor(uint256 _depositAmount) {
        factory = msg.sender;
        _winnerAddress = address(0);
        name = "LotteryClub";
        // depositAmount = 500000000000000000;
        depositAmount = _depositAmount;
        membersLimit = 8;
        prize = _depositAmount * membersLimit;
        manager = msg.sender;
    }

    // function initialize(
    //     string calldata _name,
    //     uint256 _prize,
    //     uint256 _deposit,
    //     uint256 _membersLimit,
    //     address _manager
    // ) external {
    //     require(
    //         msg.sender == factory,
    //         "LottreyClub: Only factory can call this function"
    //     );
    //     name = _name;
    //     prize = _prize;
    //     depositAmount = _deposit;
    //     membersLimit = _membersLimit;
    //     manager = _manager;
    // }

    function startLottrey() external onlyManager {
        require(!isLottreyStart, "LottreyClub: Lottrey already started");
        isLottreyStart = true;
    }

    function endLottreyAndDraw() external onlyManager {
        require(isLottreyStart, "LottreyClub: Lottrey not started");
        require(
            _membersCounters.length >= membersLimit,
            "LottreyClub: Not enough members"
        );
        require(
            address(this).balance >= prize,
            "LottreyClub: Not enough balance"
        );
        _drawLottrey();
    }

    function registerMember() external payable {
        require(isLottreyStart, "LottreyClub: Lottrey not started");
        require(_membersCounters.length < membersLimit, "LottreyClub: Full");
        require(_balance[msg.sender] == 0, "LottreyClub: Already registered");
        require(
            msg.value == depositAmount,
            "LottreyClub: Deposit amount not correct");
        _balance[msg.sender] = msg.value;
        _membersCounters.push(msg.sender);
        emit NewRegister(msg.sender, block.timestamp);
    }

    function getMembersTotal() external view returns(uint256) {
        return _membersCounters.length;
    }

    function _drawLottrey() private {
        bytes32 randBytes = RANDOMNESS_ADDRESS.random();
        uint256 randomValIdx = uint256(randBytes) % _membersCounters.length;
        emit RandomUintIdx(randomValIdx);

        bytes32 seed = keccak256(abi.encodePacked(randBytes));
        uint256 idx = uint256(seed) % _membersCounters.length;
        emit RandomSeedIdx(idx);
    


        // emit RandomValueSelected(randomVal);
        _winnerAddress = _membersCounters[
            // _getRandomNumber() % _membersCounters.length
            // randomVal % _membersCounters.length
            // randomValIdx
            idx
        ];
        emit WinnerSelected(_winnerAddress);
        address payable winnerTest = payable(_winnerAddress);
        winnerTest.transfer(prize);
        emit LottreyWinner(winnerTest, prize, block.timestamp);

        // (bool success, ) = _winnerAddress.call{value: prize}("");
        // if (success) {
        //     // _resetLottrey();
        //     // emit LottreyWinner(_winnerAddress, prize, block.timestamp);
        // } else {
        //     revert("LottreyClub: Error sending prize to winner");
        // }
    }

    function _resetLottrey() private {
        _winnerAddress = address(0);
        _membersCounters = new address[](0);
        isLottreyStart = false;
    }

    function _getRandomNumber() public view returns (uint256) {
        // return uint256(RANDOMNESS_ADDRESS.getBlockRandomness(block.number));
        return uint256(RANDOMNESS_ADDRESS.random());
    }
}
