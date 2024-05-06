// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20Factory} from "../src/ERC20Factory.sol";
import {Test, console, StdUtils} from "forge-std/Test.sol";
import {Base20Implementation} from "../src/Base20Implementation.sol";

contract InscriptionFactoryTest is Test {
    Base20Implementation base20imple;
    ERC20Factory factory;
    uint256 ownerPrivateKey = 123456;
    uint256 buyerPrivateKey = 7890123;
    address owner;
    address buyer;
    address token;
    function setUp() public {
        owner = vm.addr(ownerPrivateKey);
        buyer = vm.addr(buyerPrivateKey);
        vm.startPrank(owner);
        base20imple = new Base20Implementation();
        factory = new ERC20Factory();
        factory.setERC20Implementation(address(base20imple));
        vm.stopPrank();
    }

    function test_deployInscription() public {
        string memory symbol = "buyer";
        uint256 perMint = 100;
        uint256 price = 100;
        uint256 totalSupply = 1000;
        token = factory.deployInscription(symbol, totalSupply, perMint, price);
    }

    function test_mintInscription() public {
        test_deployInscription();
        address randomBuyer;
        uint256 _price = Base20Implementation(token).priceOfOneMint();
        // 前十个买家可以成功铸币
        for (uint256 i = 1; i < 11; i++) {
            randomBuyer = vm.addr(i);
            vm.startPrank(randomBuyer);
            vm.deal(randomBuyer, 1 ether);
            factory.mintInscription{value: _price}(address(token));
        }
        // 第11个铸币的会超过最大发行量报错
        vm.expectRevert();
        randomBuyer = vm.addr(12);
        vm.startPrank(randomBuyer);
        vm.deal(randomBuyer, 1 ether);
        factory.mintInscription{value: _price}(address(token));
    }

}
