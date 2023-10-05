// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { Migrator } from "src/Migrator.sol";
import { MockERC20 } from "src/test/MockERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestBase is PRBTest, StdCheats {
    IERC20 internal mach;
    IERC20 internal dsp;

    address internal MANAGER = address(0x1);
    address internal PAUSER = address(0x2);
    address internal alice = address(0x3);
    address internal bob = address(0x4);

    function setUp() public virtual {
        mach = new MockERC20("MACH", "MACH", 18);
        dsp = new MockERC20("DSP", "DSP", 18);

        uint256 initialBalance = 1_000_000e18;

        _faucet(mach, alice, initialBalance);
        _faucet(mach, bob, initialBalance * 3);
    }

    function _faucet(IERC20 token, address receiver, uint256 amount) internal {
        uint256 balance = token.balanceOf(receiver);
        deal(address(token), receiver, balance + amount, true);
    }
}
