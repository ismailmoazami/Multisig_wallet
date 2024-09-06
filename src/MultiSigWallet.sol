// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract MultiSigWallet {
    event Deposit(address indexed user, uint256 indexed amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    address[] public owners;
    mapping(address user => bool isOwner) public isOwner;
    uint256 public numberOfSignsRequired;

    Transaction[] public transactions;
    mapping(uint256 indexOfTx => mapping(address owner => bool isApprovedByUser)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not the owner!");
        _;
    }

    modifier txExist(uint256 _txId) {
        require(_txId < transactions.length, "Tx does not exist!");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "Already approved!");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "Already executed!");
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredApprovals) {
        require(_owners.length > 0);
        require(_requiredApprovals > 0 && _requiredApprovals < _owners.length);

        for(uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Address zero!");
            require(!isOwner[_owners[i]], "Not unique!");

            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;

        }
        numberOfSignsRequired = _requiredApprovals;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(address _to, uint256 _value, bytes calldata _data) external onlyOwner{
        require(_value <= address(this).balance, "Exceeds the wallet address!");

        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data, 
            executed: false
        }));
        emit Submit(transactions.length - 1);
    }

    function approve(uint256 _txId) 
    external
    txExist(_txId)
    notApproved(_txId)
    notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function execute(uint256 _txId) 
    external
    onlyOwner 
    txExist(_txId) 
    notExecuted(_txId)
    {
        require(_getApprovalCount(_txId) >= numberOfSignsRequired, "Not enough signs!");
        
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Transfer failed!");
        emit Execute(_txId);
    }

    function revoke(uint256 _txId) 
    external 
    onlyOwner 
    txExist(_txId) 
    notExecuted(_txId)
    {
        require(approved[_txId][msg.sender], "Not approved!");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    // Internal Functions:
    function _getApprovalCount(uint256 _txId) internal view returns(uint count) {
        for(uint i = 0; i < owners.length; i++) {
            if(approved[_txId][owners[i]]){
                count += 1;
            }
        }
    }

}