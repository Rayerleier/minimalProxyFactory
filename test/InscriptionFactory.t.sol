// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console, StdUtils} from "forge-std/Test.sol";
import {InscriptionFactory} from "../src/InscriptionFactory.sol";

contract InscriptionFactoryTest is Test {
    InscriptionFactory public inscriptionFactory;
    address owner; //项目方账号，即管理员
    uint256 fee;
    address deployer; //发行者
    function setUp() public {
        owner = makeAddr("owner");
        deployer = makeAddr("deployer");
        fee = 100 wei;
        // 设置管理员和铸币费率
        vm.prank(owner);
        inscriptionFactory = new InscriptionFactory(fee);
    }

    function test_Factory()public{
        vm.deal(deployer, 1 ether);
        vm.startPrank(deployer);
        // deal(address(inscriptionFactory), deployer, 0.05 ether);
        inscriptionFactory.deployInscription("deployer", 1e8, 5, 100 wei); // 我要怎么边call function边附带value
        vm.stopPrank();


    }
    
}
