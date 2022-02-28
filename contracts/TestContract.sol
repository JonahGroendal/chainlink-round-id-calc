// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./AggregatorProxy.sol";
import "./ChainlinkRoundIdCalc.sol";

contract TestContract {
    using ChainlinkRoundIdCalc for AggregatorProxy;

    AggregatorProxy public ethUsd;

    constructor() {
        ethUsd = AggregatorProxy(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    }

    function next(uint256 chainId) public view returns (uint80) {
        return ethUsd.next(chainId);
    }

    function prev(uint256 chainId) public view returns (uint80) {
        return ethUsd.prev(chainId);
    }

    function addPhase(uint16 _phase, uint64 _originalId) public pure returns (uint80) {
        return ChainlinkRoundIdCalc.addPhase(_phase, _originalId);
    }

    function parseIds(uint256 _roundId) public pure returns (uint16, uint64) {
        return ChainlinkRoundIdCalc.parseIds(_roundId);
    }

    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = ethUsd.latestRoundData();
        return price;
    }

    function getLatestRoundId() public view returns (uint80) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = ethUsd.latestRoundData();
        return roundID;
    }

    function getHistoricalPrice(uint80 roundId) public view returns (int256) {
        (
            uint80 id, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = ethUsd.getRoundData(roundId);
        require(timeStamp > 0, "Round not complete");
        return price;
    }
}