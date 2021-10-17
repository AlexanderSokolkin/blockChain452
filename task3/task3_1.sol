pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract task3_1 {

    string[] public queue;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function getInQueue(string name) public {
        tvm.accept();
        string[] tempQueue;
        tempQueue.push(name);
        for (uint i = 0; i < queue.length; ++i){
            tempQueue.push(queue[i]);
        }
        queue = tempQueue;
    }

    function getOutQueue() public returns (string) {
        tvm.accept();
        require(queue.empty(), 103);
        string name = queue[queue.length - 1];
        queue.pop();
        return name;
    }

}
