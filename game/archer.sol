pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "unit.sol";
contract archer is unit {
    
    uint static public archerId;

    constructor(stantionInterface baseAddress) unit(baseAddress) public {
        tvm.accept();
        setAttackPower(12);
        setDefencePower(2);
        setHP(15);
    }
}
