pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface gameObjectInterface {
    function acceptAttack(int32 attackPower) external;
}