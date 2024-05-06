// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base20Implementation} from "./Base20Implementation.sol";

contract ERC20Factory is Ownable {
    address public erc20implementation;
    uint256 ratio = 10;
    constructor() Ownable(msg.sender) {}

    event SetERC20ImplementationEvent(address implementationAdress);
    event SetRatioEvent(uint256 ratio);
    function setERC20Implementation(
        address _erc20implementation
    ) public onlyOwner {
        erc20implementation = _erc20implementation;
        emit SetERC20ImplementationEvent(erc20implementation);
    }

    function setRatio(uint256 _ratio)public onlyOwner() {
        ratio = _ratio;
        emit SetRatioEvent(ratio);
    }

    function deployInscription(
        string memory _symbol,
        uint _totalSupply,
        uint _perMint,
        uint _price
    ) external returns (address) {
        require(
            erc20implementation != address(0),
            "Implementation address is null"
        );
        return _clone(_symbol, _totalSupply, _perMint, _price);
    }

    function mintInscription(address tokenAddr) external payable {
        Base20Implementation base20imple = Base20Implementation(tokenAddr);
        uint256 price = base20imple.priceOfOneMint();
        uint256 realPrice = price*((100-ratio)/100);
        require(msg.value>= realPrice, "Not enough money");
        base20imple.mint{value: realPrice}(msg.sender);        
    }

    function getBalance()public view returns(uint256 ) {
        return address(this).balance;
    }

    function _clone(
        string memory _symbol,
        uint _totalSupply,
        uint _perMint,
        uint _price
    ) internal returns (address) {
        address newAdress = _create(erc20implementation);
        Base20Implementation(newAdress).initialize(
            _symbol,
            _totalSupply,
            _perMint,
            _price,
            address(this)
        );
        return newAdress;
    }

    function _create(
        address _implementation
    ) internal returns (address result) {
        bytes20 targetBytes = bytes20(_implementation);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
        require(result != address(0), "ERC1167: create failed");
    }
    
}
