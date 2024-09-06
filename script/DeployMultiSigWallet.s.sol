// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "lib/forge-std/src/Script.sol";
import {MultiSigWallet} from "src/MultiSigWallet.sol";

contract DeployMultiSigWallet {

    uint256 private constant NUM_OF_APPROVALS = 3;
    // For local anvil chain only!
    address USER1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address USER2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address USER3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    function run() external returns(MultiSigWallet){
        address[] memory owners;
        owners[0] = USER1;
        owners[1] = USER2;
        owners[2] = USER3;
        
        MultiSigWallet multiSigWallet = new MultiSigWallet(owners, NUM_OF_APPROVALS);
        return multiSigWallet;
    }
}
