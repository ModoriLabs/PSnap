// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { TestBase } from "test/TestBase.sol";
import { Migrator } from "src/Migrator.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UpgradeableBase } from "src/UpgradeableBase.sol";

// 1 MACH -> 10 DSP
contract Migrator_Test is TestBase {
    Migrator internal migrator;
    Migrator internal migratorImpl;

    struct TestConfig {
        uint256 exchangeRatio;
        uint256 maturity;
        uint256 bonusPeriod;
        uint256 minDeposit;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public virtual override {
        super.setUp();

        migratorImpl = new Migrator();
        migrator = Migrator(address(new ERC1967Proxy(address(migratorImpl), "")));

        TestConfig memory config = TestConfig({
            exchangeRatio: 10,
            maturity: 143 weeks,
            bonusPeriod: 37 weeks,
            minDeposit: 10000
        });

        migrator.initialize(
            IERC20(mach),
            IERC20(dsp),
            config.exchangeRatio,
            config.maturity,
            config.bonusPeriod,
            config.minDeposit,
            MANAGER,
            PAUSER
        );
    }
}

contract Migrator_Basic_Test is Migrator_Test {
    function setUp() public override {
        super.setUp();
    }

    function test_RevertWhen_InitializeTwice() public {
        vm.expectRevert("Initializable: contract is already initialized");
        migrator.initialize(
            IERC20(mach),
            IERC20(dsp),
            0,
            0,
            0,
            0,
            MANAGER,
            PAUSER
        );
    }

    function test_RevertWhen_Not_Admin_Upgrade() public {
        vm.expectRevert(UpgradeableBase.NotManager.selector);
        migrator.upgradeTo(address(0));
    }

    function test_UpgradeImpl() public {
        vm.expectRevert("Function must be called through delegatecall");
        migratorImpl.upgradeTo(address(0));
    }
}


contract Migrator_Pause is Migrator_Test {
}

contract Migrator_Deposit is Migrator_Test {
    function setUp() public override {
        super.setUp();

        vm.startPrank(alice);
        mach.approve(address(migrator), type(uint256).max);
    }

    function test_RevertWhen_AmountLessthanMinDeposit() public {
        uint256 amount = migrator.minDeposit();
        vm.expectRevert("Less than minDeposit");
        migrator.deposit(amount);
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
    function setUp() public override {
        super.setUp();
    }

    function test_ExchangeRatio_PlusMaxBonus() public {
        /*
        uint256 amount = 100;
        vm.startPrank(alice);
        mach.approve(address(migrator), amount);
        migrator.deposit(amount);

        migrator.claim(0);
        vm.expectEmit(true, true, true, true, address(mach));
        emit Transfer(address(migrator), alice, amount);
//        vm.expectEmit(true, true, true, true, address(dsp));
//        emit Transfer(address(migrator), alice, 1);

        vm.stopPrank();
*/
    }

    function test_vault_deleted() public {

    }
}

contract Migrator_SetConfig is Migrator_Test {
    function test_RevertWhen_Not_Admin() public {

    }
}

