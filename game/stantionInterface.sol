pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "unitInterface.sol";

interface stantionInterface {
    function addUnit(unitInterface unit) external;
    function popUnit(unitInterface unit) external;
}