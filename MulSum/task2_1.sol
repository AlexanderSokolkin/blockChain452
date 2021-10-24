pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract task2_1 {

    uint32 public product = 1;
    uint32 public sum = 0;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function multiplication(uint32 num) public {
        require(num >= 1 && num <= 10, 103);
        tvm.accept();

        product *= num;
    }

    function add(uint32 num) public {
        require(num >= 1 && num <= 10, 103);
        tvm.accept();

        sum += num;
    }
}
