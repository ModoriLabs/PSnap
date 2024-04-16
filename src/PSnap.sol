// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PSnap is ERC20Burnable {
    constructor() ERC20("PSnap", "PXNAP") {
        _mint(msg.sender, 500_000_000e18);
    }
}
