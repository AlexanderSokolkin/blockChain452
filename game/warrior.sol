pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "unit.sol";

contract warrior is unit {

    uint static warriorId;

    constructor(stantionInterface baseAddress) unit(baseAddress) public {
        tvm.accept();
        setAttackPower(25);
        setDefencePower(5);
        setHP(20);
    }
}
