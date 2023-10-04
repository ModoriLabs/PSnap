// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UpgradeableBase } from "./UpgradeableBase.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Migrator is UpgradeableBase {
    IERC20 internal srcToken;
    IERC20 internal destToken;
    uint256 internal exchangeRatio;
    uint256 internal maturity;
    uint256 internal bonusPeriod;
    mapping(address user => mapping(uint256 id => Vault)) internal vaults;
    mapping(address user => uint256 id) public nextVaultId;
    uint256 constant WAD = 1e18;

    using SafeERC20 for IERC20;

    struct Vault {
        uint256 amount;
        uint256 depositTs;
        bool claimed;
    }

    constructor() {
        _disableInitializers();
    }

    /// @dev Use portfolio.paused() for pausable
    function initialize(
        IERC20 _src,
        IERC20 _dest,
        uint256 _exchangeRatio,
        uint256 _maturity,
        uint256 _bonusPeriod,
        address manager,
        address pauser
    ) public initializer {
        __UpgradeableBase_init(manager, pauser);
        _grantManagerRole(manager);

        srcToken = _src;
        destToken = _dest;
        exchangeRatio = _exchangeRatio;
        maturity = _maturity;
        bonusPeriod = _bonusPeriod;
    }

    function deposit(uint256 amount) public {
        address sender = _msgSender();
        uint256 vaultId = nextVaultId[sender];

        // Use SafeTransfer
        srcToken.safeTransferFrom(sender, address(this), amount);

        vaults[sender][vaultId] = Vault(amount, block.timestamp, false);
        nextVaultId[sender] += 1;
    }

    // @dev Set vault.claimed true, not delete the vault
    function claim(uint256 id) public {
        address sender = _msgSender();

        require(nextVaultId[sender] <= id, "Vault Not Found");
        Vault memory vault = vaults[sender][id];

        require(!vault.claimed, "Vault Already Claimed");

        uint256 srcTokenAmount = 0;
        uint256 destTokenAmount = 0;
        uint256 depositTs = vault.depositTs;
        uint256 duration = block.timestamp - depositTs;

        // calculate (srcAmount, destAmount) to transfer
        if (block.timestamp <= depositTs + maturity) {
            // case1. Before Maturity(143 weeks)
            uint256 srcTokenAmountToExchange = vault.amount * duration / maturity;
            destTokenAmount = srcTokenAmountToExchange * exchangeRatio / WAD;
            srcTokenAmount = vault.amount - srcTokenAmountToExchange;
        } else if (block.timestamp <= depositTs + maturity + bonusPeriod) {
            // case2. In Bonus period (37 weeks)
            uint256 srcTokenAmountToExchange = vault.amount * duration / maturity;
            destTokenAmount = srcTokenAmountToExchange * exchangeRatio / WAD;
            // srcTokenAmount is 0
        } else {
            // case3. After Bonus period (37 weeks)
            uint256 srcTokenAmountToExchange = vault.amount * (maturity + bonusPeriod) / maturity;
            destTokenAmount = vault.amount * exchangeRatio / WAD;
            // srcTokenAmount is 0
        }

        vault.claimed = true;

        if (srcTokenAmount != 0) {
            srcToken.safeTransfer(sender, srcTokenAmount);
        }
        if (destTokenAmount != 0) {
            destToken.safeTransfer(sender, destTokenAmount);
        }
    }
}
