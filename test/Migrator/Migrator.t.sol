// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { TestBase } from "test/TestBase.sol";
import { Migrator, IMigrator } from "src/Migrator.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UpgradeableBase } from "src/UpgradeableBase.sol";
import { console } from "forge-std/console.sol";

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

    TestConfig internal config;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public virtual override {
        super.setUp();

        migratorImpl = new Migrator();
        migrator = Migrator(address(new ERC1967Proxy(address(migratorImpl), "")));

        config = TestConfig({
            exchangeRatio: 10e18,
            maturity: 100 weeks,
            bonusPeriod: 50 weeks,
            minDeposit: 10000e18
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

        uint256 sufficientAmount = 1_000_000_000e18;
        _faucet(dsp, address(migrator), sufficientAmount);
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

    function test_InitializeImpl() public {
        vm.expectRevert("Initializable: contract is already initialized");
        migratorImpl.initialize(
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

    function test_RevertWhen_AmountLessThanMinDeposit() public {
        uint256 amount = migrator.minDeposit() - 1;
        vm.expectRevert("Less than minDeposit");
        migrator.deposit(amount);
    }

    function test_TwoDeposits_ShouldBeDifferent() public {
        uint256 amount = migrator.minDeposit();
        vm.startPrank(alice);
        migrator.deposit(amount);
        migrator.deposit(amount * 2);

        (uint256 amount1,,) = migrator.vaults(alice, 0);
        (uint256 amount2,,) = migrator.vaults(alice, 1);
        assertEq(amount1, amount);
        assertEq(amount2, amount * 2);
    }

    function test_vault_become_active() public {
        uint256 amount = migrator.minDeposit();
        vm.startPrank(alice);
        migrator.deposit(amount);

        (,, bool active) = migrator.vaults(alice, 0);
        assertTrue(active);
    }
}

contract Migrator_Claim_BeforeDeposit is Migrator_Test {
    function test_RevertWhen_Claim_BeforeDeposit() public {
        vm.prank(alice);
        vm.expectRevert("Vault Not Found");
        migrator.claim(0);
    }
}

contract Migrator_One_Deposit_Scenario is Migrator_Test {
    uint256 internal depositAmount;

    function setUp() public virtual override {
        super.setUp();

        vm.startPrank(alice);
        mach.approve(address(migrator), type(uint256).max);
        depositAmount = migrator.minDeposit();
        migrator.deposit(depositAmount);
    }
}

contract Migrator_Claim_BeforeMaturity is Migrator_One_Deposit_Scenario {
    uint256 internal elapsed = 1 weeks;

    function setUp() public override {
        super.setUp();
        skip(elapsed);
    }

    // TODO: fuzz test
    function test_ExchangeRatio() public {
        uint256 srcAmount = depositAmount - depositAmount * elapsed / config.maturity;
        uint256 destAmount = depositAmount * config.exchangeRatio * elapsed / config.maturity / WAD;

        vm.expectEmit(true, true, true, true, address(mach));
        emit Transfer(address(migrator), alice, srcAmount);

        vm.expectEmit(true, true, true, true, address(dsp));
        emit Transfer(address(migrator), alice, destAmount);

        migrator.claim(0);
    }

    function test_vault_become_inactive() public {
        migrator.claim(0);

        (,, bool active) = migrator.vaults(alice, 0);
        assertFalse(active);
    }

    function test_claim_the_same_vault_twice() public {
        migrator.claim(0);
        vm.expectRevert("Vault Already Claimed");
        migrator.claim(0);
    }
}

contract Migrator_Claim_TwoVaults_BeforeMaturity is Migrator_Test {
    uint256 internal depositAmount;
    uint256 internal elapsed = 1 weeks;

    function setUp() public override {
        super.setUp();

        vm.startPrank(alice);
        mach.approve(address(migrator), type(uint256).max);
        depositAmount = migrator.minDeposit();
        // deposit twice
        migrator.deposit(depositAmount);
        migrator.deposit(depositAmount * 3);

        skip(elapsed);
    }

    function test_Claim_TwoDifferentVaults() public {
        migrator.claim(0);
        migrator.claim(1);

        (,, bool active) = migrator.vaults(alice, 0);
        assertFalse(active);

        (,, active) = migrator.vaults(alice, 1);
        assertFalse(active);
    }
}

contract Migrator_Claim_AfterMaturity_InBonusPeriod is Migrator_One_Deposit_Scenario {
    uint256 internal elapsed;

    function setUp() public override {
        super.setUp();
        elapsed = config.maturity + 1 weeks;
        skip(elapsed);
    }

    function test_ExchangeRatio_PlusBonus() public {
        uint256 destAmount = depositAmount * config.exchangeRatio * elapsed / config.maturity / WAD;
        assertEq(destAmount, 101000e18); // 10000 -> 10000 * 1010% = 101000e18
        uint256 beforeMachBalance = mach.balanceOf(alice);

        vm.expectEmit(true, true, true, true, address(dsp));
        emit Transfer(address(migrator), alice, destAmount);

        migrator.claim(0);

        uint256 afterMachBalance = mach.balanceOf(alice);
        assertEq(beforeMachBalance, afterMachBalance);
    }

    function test_vault_become_inactive() public {
        migrator.claim(0);

        (,, bool active) = migrator.vaults(alice, 0);
        assertFalse(active);
    }

}

contract Migrator_Claim_AfterMaturity_AfterBonusPeriod is Migrator_One_Deposit_Scenario {
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

