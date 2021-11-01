pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "gameObject.sol";
import "battleStation.sol";

contract unit is gameObject, unitInterface {

    int32 private attackPower;
    stantionInterface base;

    constructor(stantionInterface stantion) public {
        tvm.accept();
        stantion.addUnit(this);
        base = stantion;
    }

    function setAttackPower(int32 power) public {
        tvm.accept();
        attackPower = power;
    }

    function getAttackPower() public returns(int32) {
        tvm.accept();
        return attackPower;
    }

    function attack(gameObjectInterface object) public {
        tvm.accept();
        object.acceptAttack(attackPower);
    }

    function death(address killer) internal override {
        tvm.accept();
        base.popUnit(this);
        sendMoneyAndDestroy(killer);
    }

    function deathDueToTheStation(address killer) external override {
        tvm.accept();
        require(stantionInterface(msg.sender) == base, 200);
        sendMoneyAndDestroy(killer);
    }
}
