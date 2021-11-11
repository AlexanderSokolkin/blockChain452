pragma ton-solidity >= 0.35.0;

import "structs.sol";

interface shopListInterface {
    function getPurchaseStat() external returns(StatPurchase);
    function addPurchase(string name, uint count) external;
    function getPurchaseList() external returns (string[]);
    function deletePurchase(uint id) external;
    function buy(uint id, uint prise) external;
    function getIncompletedPurchaseList() external returns(string[]);
}

interface Transactable {
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags) external;
}

abstract contract HasConstructorWithPubKey {
    constructor(uint256 pubkey) public {}
}