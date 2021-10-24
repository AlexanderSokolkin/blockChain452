pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract nftToken {

    struct Weapon {
        string name;
        uint level;
        uint cartridgesInMagazine;
    }

    Weapon[] weaponStorage;
    mapping (string => uint) weaponOwners;
    mapping (string => uint) weaponForSale; // (название => цена)

    modifier weaponExist(string name) {
        tvm.accept();
        require(weaponOwners.exists(name), 100);
        _;
    }

    modifier isWeaponOwner(string name) {
        require(weaponOwners[name] == msg.pubkey(), 200);
        _;
    }

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function addWeapon(string name, uint level, uint cartridgesInMagazine) public {
        tvm.accept();
        require(!weaponOwners.exists(name), 100);//Так как у каждого токена должен быть владелец, то можем проверить уникальность имени по сопоставлению
        weaponStorage.push(Weapon(name, level, cartridgesInMagazine));
        weaponOwners[name] = msg.pubkey();
    }

    function getInfoAboutOwnerWeapons(uint adress) public view returns(string[]){
        tvm.accept();
        string[] ownerWeapons;
        // optional(string, uint) weaponOpt = weaponOwners.min();

        for (uint i = 0; i < weaponStorage.length; ++i) {
            if (weaponOwners[weaponStorage[i].name] == adress){
                ownerWeapons.push(weaponStorage[i].name);
            }
        }

        return ownerWeapons;
    }

    function deleteWeapon(string name) public isWeaponOwner(name) {
        tvm.accept();
        for (uint i = 0; i < weaponStorage.length; ++i) {
            if (weaponStorage[i].name == name) {
                delete weaponStorage[i];
                delete weaponOwners[name];
                break;
            }
        }

    }

    function getInfoAboutWeapon(string name) public view weaponExist(name) returns(Weapon) {
        for (uint i = 0; i < weaponStorage.length; ++i) {
            if (weaponStorage[i].name == name) {
                return weaponStorage[i];
                break;
            }
        }
    }

    function changeWeaponLevel(string name, uint level) public weaponExist(name) isWeaponOwner(name){
        for (uint i = 0; i < weaponStorage.length; ++i) {
            if (weaponStorage[i].name == name) {
                weaponStorage[i].level = level;
                break;
            }
        }
    }

    function putUpForSale (string name, uint price) public weaponExist(name) isWeaponOwner(name){ // также можно менять цену на уже выставленное на продажу оружие
        weaponForSale[name] = price;
    }

    function getWeaponList() public view returns(string[]){
        tvm.accept();
        string[] weaponList;
        for (uint i = 0; i < weaponStorage.length; ++i){
            if (weaponForSale.exists(weaponStorage[i].name)) {
                weaponList.push(format("{}(for sale)", weaponStorage[i].name));
            } else {
                weaponList.push(weaponStorage[i].name);
            }
        }

        return weaponList;

    }

}
