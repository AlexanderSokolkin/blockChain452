pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface gameObjectInterface {
    
    function acceptAttack(int32 attackPower) external;

}

interface stantionInterface {
    function addUnit(unitInterface unit) external;
    function popUnit(unitInterface unit) external;

}

interface unitInterface {
    function deathDueToTheStation(address killer) external;
}