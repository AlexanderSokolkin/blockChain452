pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "base/Debot.sol";
import "base/Terminal.sol";
import "base/Menu.sol";
import "base/AddressInput.sol";
import "base/ConfirmInput.sol";
import "base/Upgradable.sol";
import "base/Sdk.sol";
import "interfaces.sol";

abstract contract InitListDebot is Debot, Upgradable {

    TvmCell         m_shoppingListCode;     // shopping list contract code
    address         m_shoppingListAddress;  // shopping list contract address
    StatPurchase    m_purchaseStat;         // Statistics of incompleted and completed purchases
    uint256         m_masterPubKey;         // User pubkey
    address         m_walletAddress;        // User wallet address

    uint32          INITIAL_BALANCE = 200000000;



    function _menu() internal {} // Определяем в наследниках

    function setTodoCode(TvmCell t_code) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_shoppingListCode = t_code;
    }


    function onError(uint32 t_sdkError, uint32 t_exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", t_sdkError, t_exitCode));
        _menu();
    }

    function onSuccess() public view {
        _getStat(tvm.functionId(setStat));
    }



    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey), "Please enter your public key", false);
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function savePublicKey(string t_userPubKey) public {
        (uint res, bool status) = stoi("0x" + t_userPubKey);
        if (status) {
            m_masterPubKey = res;
            Terminal.print(0, "Checking if you already have a shopping list ...");

            // Находим адрес исходя из содержания контракта shoppingList и нашего публичного ключа
            TvmCell deployState = tvm.insertPubkey(m_shoppingListCode, m_masterPubKey);
            m_shoppingListAddress = address.makeAddrStd(0, tvm.hash(deployState));

            Terminal.print(0, format( "Info: your shopping contract address is {}", m_shoppingListAddress));
            Sdk.getAccountType(tvm.functionId(checkShoppingListStatus), m_shoppingListAddress);

        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key", false);
        }
    }


    function checkShoppingListStatus(int8 t_accountType) public {
        if (t_accountType == 1) { // список покупок уже задеплоен (активный)
            _getStat(tvm.functionId(setStat)); // показываем статистику

        } else if (t_accountType == -1)  { // список покупок еще не задеплоен, по его адресу вообще ничего нет (нет кристаллов)
            Terminal.print(0, "You don't have a shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else if (t_accountType == 0) { // контракт не задеплоен, но по его адресу есть какие-то средства
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your TODO contract has enough tokens on its balance"
            ));
            deploy();

        } else if (t_accountType == 2) {  // аккаунт заморожен
            Terminal.print(0, format("Can not continue: account {} is frozen", m_shoppingListAddress));
        }
    }


    function creditAccount(address t_walletAddress) public {
        // Закидываем 0.2 тон на адрес списка покупок из кошелька, который указали выше в методе get
        m_walletAddress = t_walletAddress;
        optional(uint256) pubkey = 0;
        Transactable(m_walletAddress).sendTransaction {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)
        }(m_shoppingListAddress, INITIAL_BALANCE, false, 3);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        creditAccount(m_walletAddress);
    }

    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfStatusIs0), m_shoppingListAddress);
    }

    function checkIfStatusIs0(int8 t_accountType) public {
        if (t_accountType ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    function deploy() private view {
            TvmCell image = tvm.insertPubkey(m_shoppingListCode, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_shoppingListAddress,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {HasConstructorWithPubKey, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        deploy();
    }

    function setStat(StatPurchase t_purchaseStat) public {
        m_purchaseStat = t_purchaseStat;
        _menu();
    }

    function _getStat(uint32 t_answerId) private view {
        optional(uint256) none;
        shopListInterface(m_shoppingListAddress).getPurchaseStat{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: t_answerId,
            onErrorId: 0
        }();
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
}