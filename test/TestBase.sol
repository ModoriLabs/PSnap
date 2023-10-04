// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { Migrator } from "src/Migrator.sol";

contract TestBase is PRBTest, StdCheats {
    Migrator internal migrator;

    function setUp() public virtual {
        migrator = new Migrator();
    }
}
