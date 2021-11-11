pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "initListDebot.sol";

contract fillListDebot is InitListDebot {

    string m_currentPurchaseName;


    function _menu() internal {
        string sep = '---------------------------------------------------';
        Menu.select(
            format(
                "You have:\n" /
                "Not paid purcheses - {};\n" /
                "Paid purcheses - {} (total prise - {});\n" /
                "Total purcheses - {};",
                    m_purchaseStat.incompletedPurchaseCount,
                    m_purchaseStat.completedPurchaseCount, m_purchaseStat.totalPrise,
                    m_purchaseStat.incompletedPurchaseCount + m_purchaseStat.completedPurchaseCount
            ),
            sep,
            [
                MenuItem("Add new purchase", "", tvm.functionId(addPurchase)),
                MenuItem("Show purchase list", "", tvm.functionId(showPurchaseList)),
                MenuItem("Delete purchase", "", tvm.functionId(deletePurchase))
            ]
        );
    }

    function addPurchase(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(addPurchase_), "Enter what do you want to buy", false);
    }

    function addPurchase_(string t_name) public {
        m_currentPurchaseName = t_name;
        Terminal.input(tvm.functionId(addPurchase__), "Enter the quantity", false);
    }

    function addPurchase__(string t_count) public view {
        (uint count,) = stoi(t_count);
        optional(uint256) pubkey = 0;
        shopListInterface(m_shoppingListAddress).addPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_currentPurchaseName, count);
    }

    function showPurchaseList(uint32 index) public view {
        index = index;
        optional(uint256) none;
        shopListInterface(m_shoppingListAddress).getPurchaseList{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchaseList_),
            onErrorId: 0
        }();
    }

    function showPurchaseList_(string[] t_purchaseList) public {
        
        if (t_purchaseList.length > 0) {
            Terminal.print(0, "Your purchase list:");
            for (uint i = 0; i < t_purchaseList.length; ++i) {
                Terminal.print(0, t_purchaseList[i]);
            }
        } else {
            Terminal.print(0, "Your purchase list is empty");
        }
        _menu();
    }

    function deletePurchase(uint32 index) public {
        index = index;
        if (m_purchaseStat.completedPurchaseCount > 0 || m_purchaseStat.incompletedPurchaseCount > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "You have no purchase to delete");
            _menu();
        }
    }

    function deletePurchase_(string t_id) public view {
        (uint id,) = stoi(t_id);
        optional(uint256) pubkey = 0;
        shopListInterface(m_shoppingListAddress).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(id);
    }
}