pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract task3_2 {

    struct task {
        string name;
        uint32 timestamp;
        bool isDone;
    }

    mapping (int8 => task) taskList;
    int8[] keys; // в данном массиве хранятся все ключи вышеобъявленного отображения
    int8 public key = 0; // Ключ уникальный для каждой нового дела

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function addTask(string name) public {
        tvm.accept();
        taskList.add(key, task(name, now, false));
        keys.push(key++);
    }

    function getNumOfOpenTasks() public view returns (uint8) {
        tvm.accept();
        uint8 count = 0;
        for (uint256 i = 0; i < keys.length; ++i) {
            if (!taskList[keys[i]].isDone) {
                count++;
            }
        }
        return count;
    }



    function getTaskList() public view returns (mapping(int8 => task)) {
        tvm.accept();
        return taskList;
    }

/** Аналог вышеописанной функции

    function getTastList2() public view returns (string[]) {
        tvm.accept();
        string[] resultList;
        for (uint256 i = 0; i < keys.length; ++i) {
            string taskStr = format("{} - name: {}, timestamp: {}, isDone: {}",
                                    i,
                                    taskList[keys[i]].name,
                                    taskList[keys[i]].timestamp,
                                    ((taskList[keys[i]].isDone) ? "true" : "false"));
            resultList.push(taskStr);
        }
        return resultList;
    }
*/

    function getTaskDescription(int8 _key) public view returns (task) {
        tvm.accept();
        require(taskList.exists(_key), 103);
        return taskList[_key];
    }

/** Аналог вышеописанной функции

    function getTaskDescription2(int8 _key) public view returns (string) {
        tvm.accept();
        require(taskList.exists(_key), 103);
        return format("{} - name: {}, timestamp: {}, isDone: {}",
                                    _key,
                                    taskList[keys[uint256(_key)]].name,
                                    taskList[keys[uint256(_key)]].timestamp,
                                    ((taskList[keys[uint256(_key)]].isDone) ? "true" : "false"));
    }
*/

    function deleteTask(int8 _key) public {
        tvm.accept();
        require(taskList.exists(_key), 103);
        delete taskList[_key];
        for (uint256 i = 0; i < keys.length; ++i) {
            if (keys[i] == _key) {
                delete keys[i];
                break;
            }
        }
    }

    function markTask(int8 _key) public {
        tvm.accept();
        require(taskList.exists(_key), 103);
        taskList[_key].isDone = true;
    }

}
