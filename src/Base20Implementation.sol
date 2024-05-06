pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import {ERC20Upgradeable} from "../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "./interface/TokensReceive.sol";
// import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract Base20Implementation is ERC20Upgradeable {
    error ERC20NotEnough(address);
    error ERC20OnlyOneMint(address);
    event ERC20Mint(address sender, uint256 amount, uint256 balance);
    event finishMint(address sender, uint256 amount, uint256 balance);
    string private constant name_ = "Rain Rayer";
    address private factoryAddress;
    uint256 public perMint;
    uint256 public price;
    uint256 public maxTotalSupply;
    address[] public mintAddress;
    TokensReceive transferBack;
    

    
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _perMint,
        uint256 _price,
        address _factoryAddress
    ) external initializer {
        __ERC20_init(name_, _symbol);
        perMint = _perMint;
        price = _price;
        maxTotalSupply = _totalSupply;
        factoryAddress = _factoryAddress;
    }

    function mint(address mintUser) external payable {
        require(msg.sender == factoryAddress, "mint in factory");
        console.log(maxTotalSupply, mintAddress.length * perMint + perMint);
        if (maxTotalSupply < mintAddress.length * perMint + perMint) {
            revert ERC20NotEnough(mintUser);
        }
        if (isUse(mintUser)) revert ERC20OnlyOneMint(mintUser);
        mintAddress.push(mintUser);
        if (maxTotalSupply == mintAddress.length * perMint) {
            for (uint256 i = 0; i < mintAddress.length; i++) {
                _mint(mintAddress[i], perMint);
                emit finishMint(
                    mintAddress[i],
                    perMint,
                    balanceOf(mintAddress[i])
                );
            }
            return;
        }
    }

    function isUse(address mintUser) internal view returns (bool) {
        for (uint256 i = 0; i < mintAddress.length; i++) {
            if (mintAddress[i] == mintUser) return true;
        }
        return false;
    }

    function priceOfOneMint() external view returns (uint256) {
        return perMint * price;
    }

    function _checkOnTokensReceived(address _to, bytes memory _data) private {}

    function transferWithCallBack(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public {
        transfer(_to, _value);
        if (isContract(_to)) {
            TokensReceive(_to).tokensReceive(msg.sender, _to, _value, _data);
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;

        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
