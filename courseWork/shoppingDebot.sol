pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "initListDebot.sol";

contract shoppingDebot is InitListDebot {

    uint m_purchaseId;


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
                MenuItem("Show purchase list", "", tvm.functionId(showPurchaseList)),
                MenuItem("Delete purchase", "", tvm.functionId(deletePurchase)),
                MenuItem("Make a purchase", "", tvm.functionId(buy))
            ]
        );
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

    function buy(uint32 index) public {
        index = index;
        showIncompletedPurchaseList();
        Terminal.input(tvm.functionId(buy_), "Choose what you are going to buy", false);
    }

    function buy_(string t_id) private {
        (uint id,) = stoi(t_id);
        m_purchaseId = id;
        Terminal.input(tvm.functionId(buy__), "Enter the price", false);
    }

    function buy__(string t_price) public view {
        (uint price,) = stoi(t_price);
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
            }(m_purchaseId, price);
    }

    function showIncompletedPurchaseList() private view {
        optional(uint256) pubkey = 0;
        shopListInterface(m_shoppingListAddress).getIncompletedPurchaseList{
                abiVer: 2,
                extMsg: true,
                sign: false,
                pubkey: 0,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(showIncompletedPurchaseList_),
                onErrorId: 0
            }();
    }

    function showIncompletedPurchaseList_(string[] incompletedPurchaseList) private view {
        Terminal.print(0, "Incompleted purchase list:");
        for (uint i = 0; i < incompletedPurchaseList.length; ++i) {
            Terminal.print(0, "    " + incompletedPurchaseList[i]);
        }
        Terminal.print(0, "---------------------------------------------");
    }

}