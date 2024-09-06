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

    

}