// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { TestBase } from "test/TestBase.sol";

contract Migrator_Test is TestBase {
    function setUp() public virtual override {

    }
}

contract Migrator_Basic_Test is Migrator_Test {
    function setUp() public override {
        super.setUp();
    }

    function test_RevertWhen_Not_Admin_Initialize() public {

    }

    function test_RevertWhen_Not_Admin_Upgrade() public {

    }
}


contract Migrator_Pause is Migrator_Test {
}

contract Migrator_Deposit is Migrator_Test {
    function setUp() public override {
        super.setUp();

        // approve
    }

    // Q. What if two tx in one block? Simply different
    function test_TwoDeposits_ShouldBeDifferent() public {
        // deposit
        // deposit
    }

}

contract Migrator_Claim_BeforeMaturity is Migrator_Test {
    function setUp() public override {
        super.setUp();
    }

    function test_ExchangeRatio() public {

    }

    function test_vault_deleted() public {

    }

    function test_claim_the_same_vault_twice() public {

    }

    function test_Claim_TwoDifferentVaults() public {

    }

    // rounding error
    function test_RevertWhen_ZeroIn_OneOut() public {

    }
}

contract Migrator_Claim_AfterMaturity_InBonusPeriod is Migrator_Test {
    function test_ExchangeRatio_PlusBonus() public {

    }

    function test_vault_deleted() public {

    }
}

contract Migrator_Claim_AfterMaturity_AfterBonusPeriod is Migrator_Test {
    function test_ExchangeRatio_PlusMaxBonus() public {
        // emit Transfer
        // emit Transfer
    }

    function test_vault_deleted() public {

    }
}

