pragma ton-solidity >= 0.35.0;

struct Purchase {
    uint id;
    string name;
    uint count;
    uint32 timestamp;
    bool isBought;
    uint prise;
}

struct StatPurchase {
    uint completedPurchaseCount;
    uint incompletedPurchaseCount;
    uint totalPrise;
}
