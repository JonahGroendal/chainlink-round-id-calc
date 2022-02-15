// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{
  function latestRound() external view returns (uint256);
}


interface AggregatorProxy {
    function phaseId() external view returns (uint16);
    function phaseAggregators(uint16 phaseId) external view returns (AggregatorV2V3Interface);
}

contract ChainlinkRoundIdCalc {
    uint256 constant private PHASE_OFFSET = 64;

    function next(AggregatorProxy proxy, uint256 roundId) public view returns (uint80)
    {
        (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(roundId);
        uint maxAggregatorRoundId = proxy.phaseAggregators(phaseId).latestRound();

        if (aggregatorRoundId < maxAggregatorRoundId) {
            aggregatorRoundId++;
        }
        else if (phaseId < proxy.phaseId()) {
            phaseId++;
            aggregatorRoundId = 1;
        }
        return addPhase(phaseId, aggregatorRoundId);
    }

    /// @dev if roundId is the first entry, return the same roundId to indicate that we can't go back any further
    function prev(AggregatorProxy proxy, uint256 roundId) public view returns (uint80)
    {
        (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(roundId);

        if (aggregatorRoundId > 1) {
            aggregatorRoundId--;
        }
        else if (phaseId > 1) {
            phaseId--;
            aggregatorRoundId = uint64(proxy.phaseAggregators(phaseId).latestRound());
        }
        return addPhase(phaseId, aggregatorRoundId);
    }
    
    function addPhase(uint16 _phase, uint64 _originalId) internal pure returns (uint80)
    {
        return uint80(uint256(_phase) << PHASE_OFFSET | _originalId);
    }

    function parseIds(uint256 _roundId) internal pure returns (uint16, uint64)
    {
        uint16 phaseId = uint16(_roundId >> PHASE_OFFSET);
        uint64 aggregatorRoundId = uint64(_roundId);

        return (phaseId, aggregatorRoundId);
    }

/* 
    not useful for most applications
    
    code is untested


    /// @notice add `i` to `roundId`. Useful for searching for a particular timestamp
    /// @dev minimum possible phaseId is 1
    /// @dev minimum possible aggregatorRoundId is 1
    /// @dev if desired move amount is gt the current max ID, return the current max ID
    /// @dev if desired move amount is lt the minimum possible ID, return the minimum possible ID
    function move(AggregatorProxy proxy, uint256 roundId, int i) public view returns (uint80, int) {
        (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(roundId);
        int moved = 0;

        if (i < 0) {
            while (i < 0) {
                if (-1*i < aggregatorRoundId) {
                    moved += i;
                    aggregatorRoundId += i;
                    i -= i;
                }
                else if (phaseId <= 1) {
                    moved -= aggregatorRoundId - 1;
                    aggregatorRoundId = 1;
                    i = 0;
                }
                else {
                    phaseId -= 1;
                    moved -= aggregatorRoundId;
                    i += aggregatorRoundId;
                    aggregatorRoundId = uint64(proxy.phaseAggregators(phaseId).latestRound());
                }

            }
        }
        else if (i > 0) {
            while (i > 0) {
                uint32 latestAggregatorRoundId = proxy.phaseAggregators(phaseId).latestRound();
                if (aggregatorRoundId + i <= latestAggregatorRoundId) {
                    moved += i;
                    aggregatorRoundId += i;
                    i -= i;
                }
                else if (phaseId >= proxy.phaseId()) {
                    moved += latestAggregatorRoundId - aggregatorRoundId;
                    aggregatorRoundId = latestAggregatorRoundId;
                    i = 0;
                } else {
                    phaseId += 1;
                    moved += latestAggregatorRoundId - aggregatorRoundId + 1;
                    i -= latestAggregatorRoundId - aggregatorRoundId + 1;
                    aggregatorRoundId = 1;
                }
            }
        }

        return addPhase(phaseId, aggregatorRoundId);
    }
    */
}