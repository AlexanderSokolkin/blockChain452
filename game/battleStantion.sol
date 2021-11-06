pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "gameObject.sol";
import "stantionInterface.sol";

contract battleStation is gameObject, stantionInterface {
    
    unitInterface[] private units;
    uint private todol;

    constructor() public {
        tvm.accept();
        setDefencePower(8);
        setHP(50);
    }

    function addUnit(unitInterface unit) external override {
        tvm.accept();
        units.push(unit);
    }

    function popUnit(unitInterface unit) external override {
        tvm.accept();
        for (uint i = 0; i < units.length; ++i) {
            if (units[i] == unit) {
                delete units[i];
                break;
            }
        }
    }

    function death(address killer) internal override {
        tvm.accept();
        for (uint i = 0; i < units.length; ++i) {
            units[i].deathDueToTheStation(killer);
        }
        sendMoneyAndDestroy(killer);
    }

    function getCountOfUnits() public view returns(uint){
        tvm.accept();
        return units.length;
    }

}