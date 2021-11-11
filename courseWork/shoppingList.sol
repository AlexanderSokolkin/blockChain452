pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "structs.sol";

contract shoppingList {
    /*
        111 - попытка доступа с чужого адреса
        120 - покупка не найдена (id покупки не соответсвует ни одной из имеющихся)
     */
    uint256 m_ownerPubkey;

    Purchase[] purchase;

    // проверка вызова (должна быть доступна только владельцу, чей адресс сохраняем в поле m_ownerPubkey при инициализации контракта)
    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 111);
        _;
    }

    constructor (uint256 pubkey) public{
        require(pubkey != 0, 100);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function addPurchase(string name, uint count) public onlyOwner{
        tvm.accept();
        purchase.push(Purchase(purchase.length + 1, name, count, now, false, 0));
    }

    function deletePurchase(uint id) public onlyOwner{
        require(id <= purchase.length, 120);
        tvm.accept();
        delete purchase[id - 1];
        for (uint i = id - 1; i < purchase.length; ++i) {
            purchase[i].id--;
        }
    }

    function buy(uint id, uint prise) public onlyOwner{
        require(id <= purchase.length, 120);
        tvm.accept();
        purchase[id - 1].isBought = true;
        purchase[id - 1].prise = prise;
    }

    function getPurchaseList() public view returns (string[]) {
        string[] purchaseList;
        for (uint i = 0; i < purchase.length; ++i) {
            if (purchase[i].isBought) {
                purchaseList.push(format("{}. ✓ {}, {} шт. Стоимость - {}. ({})",
                                                purchase[i].id,
                                                purchase[i].name,
                                                purchase[i].count,
                                                purchase[i].prise,
                                                purchase[i].timestamp));
            } else {
                purchaseList.push(format("{}. ✗ {}, {} шт. ({})",
                                                purchase[i].id,
                                                purchase[i].name,
                                                purchase[i].count,
                                                purchase[i].timestamp));
            }
        }
        return purchaseList;
    }

    function getIncompletedPurchaseList() public view returns(string[]){
        string[] incompletedPurchaseList;
        for (uint i = 0; i < purchase.length; ++i) {
            if (!purchase[i].isBought) {
                incompletedPurchaseList.push(format("{}. {}, {} шт.",
                                                purchase[i].id,
                                                purchase[i].name,
                                                purchase[i].count));
            }
        }
        return incompletedPurchaseList;
    }

    function getPurchaseStat() public view returns (StatPurchase) {
        StatPurchase statPurchase;
        for (uint i = 0; i < purchase.length; ++i) {
            if (purchase[i].isBought) {
                statPurchase.completedPurchaseCount += purchase[i].count;
                statPurchase.totalPrise += purchase[i].prise;
            } else {
                statPurchase.incompletedPurchaseCount += purchase[i].count;
            }
        }
        return statPurchase;
    }


}