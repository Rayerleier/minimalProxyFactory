// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract InscriptionFactory {
    address public owner;
    uint public fee; // 铸造费用
    mapping (address=> uint256) public balanceOf;
    struct TokenPrice{
        uint perMint;
        uint price;
    }
    mapping (address=>TokenPrice)public OfTokenPrice;


    event TokenCreated(
        address indexed tokenAddress,
        string symbol,
        uint totalSupply
    );

    constructor(uint _fee) {
        owner = msg.sender;
        fee = _fee;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function changeFee(uint _newFee) external onlyOwner {
        fee = _newFee;
    }

    function deployInscription(
        string memory symbol,
        uint totalSupply,
        uint perMint,
        uint price
    ) external payable {
        require(msg.value >= fee, "Insufficient fee");

        ERC20 token = new ERC20("rainrayer", symbol); // 创建 ERC20 合约

        OfTokenPrice[address(token)] = (TokenPrice(perMint, price));
        emit TokenCreated(address(token), symbol, totalSupply);

        // 向合约发送以太币，这部分以太币用于代币铸造，不算在手续费内
        payable(address(token)).transfer(msg.value-fee);
        // 手续费转给管理员账户
        payable(owner).transfer(fee);

        // 进行铸造
        for (uint i = 0; i < totalSupply; i += perMint) {
            token._mint(msg.sender, perMint);
        }
    }

    function mintInscription(address tokenAddr) external payable {
        ERC20 token = ERC20(tokenAddr);
        TokenPrice memory tokenPrice= OfTokenPrice[address(token)];
        require(msg.value >= tokenPrice.perMint * tokenPrice.price, "Insufficient payment");

        for (uint i = 0; i < tokenPrice.perMint; i++) {
            token._mint(msg.sender, 1);
        }
        payable(owner).transfer(msg.value); // 将费用转给合约创建者
    }

    receive() external payable {}
}
