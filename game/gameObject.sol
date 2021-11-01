pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Interfaces.sol";

contract gameObject is gameObjectInterface {
    
    int32 internal defencePower;
    int32 internal HP;

    constructor() public {
        tvm.accept();
    }

    function setDefencePower(int32 def) public {
        tvm.accept();
        defencePower = def;
    }

    function getDefencePower() public returns(int32) {
        tvm.accept();
        return defencePower;
    }

    function setHP(int32 hp) public {
        tvm.accept();
        HP = hp;
    }

    function getHP() public returns(int32) {
        tvm.accept();
        return HP;
    }

    function acceptAttack(int32 attackPower) external override {
        tvm.accept();
        if (attackPower > defencePower) {
            HP -= attackPower - defencePower;
            if (!checkAlive()) {
                death(msg.sender);
            }
        }
    }

    // Проверить здоровье объекта (не убит ли он)
    function checkAlive() private view returns(bool){
        tvm.accept();
        return (HP <= 0) ? false : true;
    }

    function death(address killer) virtual internal {}

    function sendMoneyAndDestroy(address killer) internal {
        tvm.accept();
        killer.transfer(0, true, 160);
    }

}
