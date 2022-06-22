//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.12;

import "./utils/console.sol";
import "../../lib/ds-test/src/test.sol";
import {AaveSwap} from "../AaveSwap.sol";
import {AaveImplementation} from "../AaveImplementation.sol";
import {EEIntegration} from "../EEImplementation.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import "../interfaces/IlendingPoolAddressesProvider.sol";
import "../interfaces/IAave.sol";

interface Vm {
    function prank(address) external;

    function startPrank(address) external;

    function warp(uint256) external;

    function stopPrank() external;
}

contract AaveSwapTest is DSTest {
    AaveSwap testSwapper;
    AaveImplementation test;

    IERC20 DAI;
    IERC20 WETH;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        testSwapper = new AaveSwap();
        test = new AaveImplementation();
        EEIntegration testEEIntegration = new EEIntegration();

        DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }

    // function testSwap() public {
    //     //swap dai for weth
    //     vm.startPrank(0x6F3F68525E5EdaD6F06f8b0EaE0DD7B9F695aF13); //dai whale
    //     uint256 _amount = 10000 * (10**18);
    //     uint256 _amount2 = 1000 * (10**18);

    //     console.log(address(DAI));

    //     IERC20(address(DAI)).transfer(address(this), _amount);
    //     vm.stopPrank();

    //     console.log("Before swap dai balance", DAI.balanceOf(address(this)));
    //     console.log("Before swap TOMB balance", WETH.balanceOf(address(this)));

    //     IERC20(address(DAI)).approve(address(testSwapper), _amount);

    //     testSwapper.swap(
    //         address(DAI),
    //         address(WETH),
    //         _amount,
    //         0,
    //         address(this)
    //     );

    //     console.log("after swap balance");

    //     console.log(WETH.balanceOf(address(this)));
    //     console.log(DAI.balanceOf(address(this)));

    //     assertTrue(DAI.balanceOf(address(this)) == 0);
    // }
    // //forge test --fork-url https://rpc.ankr.com/eth -vvv

    // function testAavedepositDAI() public {

    //     vm.startPrank(0x6F3F68525E5EdaD6F06f8b0EaE0DD7B9F695aF13);  //test dais

    //     uint256 _amount = 10000 * (10**18);
    //     uint256 _amount2 = 100 * 1e18;

    //     console.log(
    //         "DAI balance of prank caller ",
    //         DAI.balanceOf(0x6F3F68525E5EdaD6F06f8b0EaE0DD7B9F695aF13)
    //     );
    //     console.log(
    //         "DAI balance of geist before transfer",
    //         DAI.balanceOf(address(test))
    //     );

    //     IERC20(address(DAI)).approve(address(test), _amount);
    //     IERC20(address(DAI)).transfer(address(test), _amount);

    //     console.log(
    //         "DAI balance of geist after transfer",
    //         DAI.balanceOf(address(test))
    //     );

    //     test.depositMoney(_amount, _amount2);

    //     ILendingPool geistLender = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    //     (, ,uint256 b, , , ) = geistLender.getUserAccountData(address(test));

    //     console.log(b, "data");

    //     console.log(
    //         "DAI balance of geist after transfer",
    //         DAI.balanceOf(address(test))
    //     );
    //     vm.stopPrank();

    // }

    // function testLeverageLongDAI() public {
    //     vm.startPrank(0x1C11BA15939E1C16eC7ca1678dF6160Ea2063Bc5); //test weth

    //     console.log("WETH balance of gesit", WETH.balanceOf(address(test)));
    //     console.log(
    //         "DAI balance of geist before transfer",
    //         DAI.balanceOf(address(test))
    //     );

    //     console.log("aaveswap address", (address(testSwapper)));

    //     uint256 _amount = 1000 * 1e18;

    //     WETH.approve(address(test), _amount);

    //     test.leverageLong(address(WETH), address(testSwapper), _amount);

    //     console.log(
    //         "WETH balance of geist after transfer",
    //         WETH.balanceOf(address(test))
    //     );

    //     ILendingPool geistLender = ILendingPool(
    //         0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9
    //     );

    //     (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, , , ) = geistLender.getUserAccountData(address(test));

    //     console.log("availableBorrowsETH ", availableBorrowsETH)
    //     console.log("totalCollateralETH ", totalCollateralETH)
    //     console.log("totalDebtETH ", totalDebtETH)

    //     vm.stopPrank();
    // }

    //     function testopenPositionNFT() public {
    //     vm.startPrank(0x1C11BA15939E1C16eC7ca1678dF6160Ea2063Bc5); //test weth

    //     console.log("WETH balance of gesit", WETH.balanceOf(address(test)));
    //     console.log(
    //         "DAI balance of geist before transfer",
    //         DAI.balanceOf(address(test))
    //     );

    //     console.log("aaveswap address", (address(testSwapper)));

    //     uint256 _amount = 1000 * 1e18;

    //     WETH.approve(address(test), _amount);

    //     test.leverageLong(address(WETH), address(testSwapper), _amount);

    //     console.log(
    //         "WETH balance of geist after transfer",
    //         WETH.balanceOf(address(test))
    //     );

    //     ILendingPool geistLender = ILendingPool(
    //         0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9
    //     );

    //     (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, , , ) = geistLender.getUserAccountData(address(test));

    //     console.log("availableBorrowsETH ", availableBorrowsETH)
    //     console.log("totalCollateralETH ", totalCollateralETH)
    //     console.log("totalDebtETH ", totalDebtETH)

    //     vm.stopPrank();
    // }

    // function testMakeDeposit() public {
    //     vm.startPrank(0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca); //dai and ftm whale

    //     //IERC20(address(DAI)).approve(address(tester), 10000);

    //     console.log(
    //         "dai balance before makedeposit  ",
    //         IERC20(DAI).balanceOf(
    //             address(0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca)
    //         )
    //     );

    //     uint256 _amount = 100000 * 1e18;
    //     uint256 _amount2 = 100 * 1e18;

    //     DAI.approve(address(test), _amount);

    //     IERC20(address(DAI)).approve(address(test), _amount);

    //     test.depositMoney(_amount, _amount2);
    //     ILendingPool geistLender = ILendingPool(0x9FAD24f572045c7869117160A571B2e50b10d068);

    //     (, ,uint256 b, , , ) = geistLender.getUserAccountData(address(test));

    //     vm.stopPrank();

    //     assertTrue(b > 30000000158240500);
    // }

    // function testSwapWETH() public {
    //     vm.startPrank(0x93C08a3168fC469F3fC165cd3A471D19a37ca19e);
    //     uint256 _amount = 10000 * (10**18);

    //     uint256 _amount2 = 1000 * (10**18);

    //     console.log(
    //         "WETH balance ",
    //         WETH.balanceOf(0xdDf169Bf228e6D6e701180E2e6f290739663a784)
    //     );

    //     WETH.approve(
    //         address(testSwapper),
    //         _amount2
    //     );

    //     console.log("Before swap dai balance", dai.balanceOf(address(this)));
    //     console.log("Before swap WETH balance", WETH.balanceOf(address(this)));

    //     testSwapper.Swap(
    //         address(WETH),
    //         address(DAI),
    //         _amount2,
    //         0,
    //         address(this)
    //     );

    //     console.log("after swap balance");

    //     console.log(WETH.balanceOf(address(this)));
    //     console.log(dai.balanceOf(address(this)));

    //     vm.stopPrank();

    //     assertTrue(dai.balanceOf(address(this)) >= _amount2);
    // }

    // function testSwapCRV() public {
    //     vm.startPrank(0xc62A0781934744E05927ceABB94a3043CdCfEA89);
    //     uint256 _amount = 1000 * (10**18);

    //     uint256 _amount2 = 1000 * (10**18);

    //     console.log(
    //         "CRV balance ",
    //         CRV.balanceOf(0xc62A0781934744E05927ceABB94a3043CdCfEA89)
    //     );

    //     CRV.approve(
    //         address(testSwapper),
    //         _amount2
    //     );

    //     console.log("Before swap dai balance", dai.balanceOf(address(this)));
    //     console.log("Before swap CRV balance", TOMB.balanceOf(address(this)));

    //     testSwapper.Swap(
    //         address(CRV),
    //         address(DAI),
    //         _amount2,
    //         0,
    //         address(this)
    //     );

    //     console.log("after swap balance");

    //     console.log(CRV.balanceOf(address(this)));
    //     console.log(dai.balanceOf(address(this)));

    //     vm.stopPrank();

    //     assertTrue(dai.balanceOf(address(this)) >= _amount2);
    // }

    // function testGesitdepositFTM() public {
    //     //ftm
    //     uint256 _amount = 10000 * (10**18);

    //     vm.startPrank(0x36cb763573813990DFaE2069c4dF4eefba3aec7F); //test dai

    //     console.log(
    //         "dai balance ",
    //         dai.balanceOf(0x36cb763573813990DFaE2069c4dF4eefba3aec7F)
    //     );

    //     IERC20(address(dai)).approve(address(test), _amount);
    //     IERC20(address(dai)).transfer(address(test), _amount);
    //     console.log(
    //         "dai balance of geist before transfer",
    //         dai.balanceOf(address(address(test)))
    //     );
    //     test.deposit(address(dai), 1000);

    //     console.log(
    //         "dai balance of geist after transfer",
    //         dai.balanceOf(address(test))
    //     );
    //     vm.stopPrank();
    // }

    // function testGesitdepositDAI() public {

    //     vm.startPrank(0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1);  //test wftm
    //     IERC20(address(WFTM)).approve(address(test), 1000);
    //     IERC20(address(WFTM)).transfer(address(test), 1000);

    //     console.log(
    //         "wftm balance of prank caller ",
    //         WFTM.balanceOf(0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1)
    //     );
    //     console.log(
    //         "wftm balance of geist before transfer",
    //         WFTM.balanceOf(address(test))
    //     );

    //     test.deposit(address(WFTM), 1000);

    //     console.log(
    //         "wftm balance of geist after transfer",
    //         WFTM.balanceOf(address(test))
    //     );
    //     vm.stopPrank();

    // }

    // function testMakeDeposit() public {
    //     vm.startPrank(0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca); //dai and ftm whale

    //     //IERC20(address(DAI)).approve(address(tester), 10000);

    //     console.log(
    //         "dai balance before makedeposit  ",
    //         IERC20(DAI).balanceOf(
    //             address(0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca)
    //         )
    //     );

    //     uint256 _amount = 100000 * 1e18;
    //     uint256 _amount2 = 100 * 1e18;

    //     DAI.approve(address(test), _amount);

    //     IERC20(address(DAI)).approve(address(test), _amount);

    //     test.depositMoney(_amount, _amount2);
    //     ILendingPool geistLender = ILendingPool(0x9FAD24f572045c7869117160A571B2e50b10d068);

    //     (, ,uint256 b, , , ) = geistLender.getUserAccountData(address(test));

    //     vm.stopPrank();

    //     assertTrue(b > 30000000158240500);
    // }

    // function testMakeDepositRepay() public {
    //     vm.startPrank(0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca); //dai and ftm whale

    //     //IERC20(address(DAI)).approve(address(tester), 10000);

    //     console.log(
    //         "dai balance b efore makedeposit  ",
    //         IERC20(DAI).balanceOf(
    //             address(0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca)
    //         )
    //     );

    //     uint256 _amount = 100000 * 1e18;
    //     uint256 _amount2 = 100 * 1e18;

    //     DAI.approve(address(test), _amount);

    //     IERC20(address(DAI)).approve(address(test), _amount);

    //     test.depositMoney(_amount, _amount2);

    //     ILendingPool geistLender = ILendingPool(0x9FAD24f572045c7869117160A571B2e50b10d068);

    //     (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e , uint256 f) = geistLender.getUserAccountData(address(test));

    //     vm.stopPrank();

    //     assertTrue(b > 30000000158240500);
    // }

    // function testLeverageLongLINK() public {
    //     vm.startPrank(0x8588b7ceCD39527Afb1447621Ad65c078e3f14De); //test wftm

    //     console.log(
    //         "wftm balance of prank caller ",
    //         LINK.balanceOf(0x8588b7ceCD39527Afb1447621Ad65c078e3f14De)
    //     );
    //     console.log(
    //         "wftm balance of geist before transfer",
    //         LINK.balanceOf(address(test))
    //     );
    //     uint256 _amount = 1000 * 1e18;

    //     LINK.approve(address(test), _amount);

    //     test.leverageLong(address(LINK), address(testSwapper), _amount);

    //     console.log(
    //         "wftm balance of geist after transfer",
    //         LINK.balanceOf(address(test))
    //     );
    //     vm.stopPrank();
    // }

    // function testLeverageLongWFTM() public {
    //     vm.startPrank(0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1); //test wftm

    //     console.log(
    //         "wftm balance of prank caller ",
    //         WFTM.balanceOf(0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1)
    //     );
    //     console.log(
    //         "wftm balance of geist before transfer",
    //         WFTM.balanceOf(address(test))
    //     );
    //     uint256 _amount = 1000 * 1e18;

    //     WFTM.approve(address(test), _amount);

    //     test.leverageLong(address(WFTM), address(testSwapper), _amount);

    //     console.log(
    //         "wftm balance of geist after transfer",
    //         WFTM.balanceOf(address(test))
    //     );
    //     vm.stopPrank();
    // }

    // function testLeverageLongCRV() public {
    //     vm.startPrank(0xc62A0781934744E05927ceABB94a3043CdCfEA89); //test wftm

    //     console.log(
    //         "wftm balance of prank caller ",
    //         CRV.balanceOf(0xc62A0781934744E05927ceABB94a3043CdCfEA89)
    //     );
    //     console.log(
    //         "wftm balance of geist before transfer",
    //         CRV.balanceOf(address(test))
    //     );
    //     uint256 _amount = 1000 * 1e18;

    //     CRV.approve(address(test), _amount);

    //     test.leverageLong(address(CRV), address(testSwapper), _amount);

    //     console.log(
    //         "wftm balance of geist after transfer",
    //         CRV.balanceOf(address(test))
    //     );
    //     vm.stopPrank();
    // }

    // function testLeverageLongWETH() public {
    //     vm.startPrank(0x93C08a3168fC469F3fC165cd3A471D19a37ca19e); //test wftm

    //     console.log(
    //         "WETH balance of prank caller ",
    //         WETH.balanceOf(0x93C08a3168fC469F3fC165cd3A471D19a37ca19e)
    //     );
    //     console.log(
    //         "WETH balance of geist before transfer",
    //         WETH.balanceOf(address(test))
    //     );
    //     uint256 _amount = 1000 * 1e18;

    //     WETH.approve(address(test), _amount);

    //     test.leverageLong(address(WETH), address(testSwapper), _amount);

    //     console.log(
    //         "wftm balance of geist after transfer",
    //         WETH.balanceOf(address(test))
    //     );
    //     vm.stopPrank();
    // }

    // function testLeverageShortWETH() public {
    //     vm.startPrank(0x36cb763573813990DFaE2069c4dF4eefba3aec7F); //test wftm

    //     console.log(
    //         "DAI balance of prank caller ",
    //         DAI.balanceOf(0x36cb763573813990DFaE2069c4dF4eefba3aec7F)
    //     );
    //     console.log(
    //         "DAI balance of geist before transfer",
    //         DAI.balanceOf(address(test))
    //     );
    //     uint256 _amount = 10000 * 1e18;
    //     uint256 _amount2 = 1000 * 1e18;

    //     DAI.approve(address(test), _amount);

    //     test.leverageShort(address(LINK), address(testSwapper), _amount, _amount2);

    //     console.log(
    //         "wftm balance of geist after transfer",
    //         WETH.balanceOf(address(test))
    //     );
    //     vm.stopPrank();
    // }

    // function testLeverageShortWFTM() public {
    //     vm.startPrank(0x36cb763573813990DFaE2069c4dF4eefba3aec7F); //test wftm

    //     console.log(
    //         "DAI balance of prank caller ",
    //         DAI.balanceOf(0x36cb763573813990DFaE2069c4dF4eefba3aec7F)
    //     );
    //     console.log(
    //         "DAI balance of geist before transfer",
    //         DAI.balanceOf(address(test))
    //     );
    //     uint256 _amount = 50000 * 1e18;
    //     uint256 _amount2 = 1000 * 1e18;

    //     DAI.approve(address(test), _amount);

    //     test.leverageShort(address(CRV), address(testSwapper), _amount, _amount2);

    //     console.log(
    //         "wftm balance of geist after transfer",
    //         WETH.balanceOf(address(test))
    //     );
    //     vm.stopPrank();
    // }
}

//                             forge test --fork-url https://rpc.ankr.com/eth -vvv
//ftm and dai whale 0xb6E825727DaE1e3886639FAa29bAcf623E8Ed91E  0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca  0x36cb763573813990DFaE2069c4dF4eefba3aec7F  0x1741403bdDd055D7016dBcD0C3ADCb4BFbFD797c
//ftm and wftm whale 0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1
//gwbtc and ftm whale 0x4282890fF9661a51EA367AeddF341C6f6395d4E1
//dai eth 0xe82906b6B1B04f631D126c974Af57a3A7B6a99d9

//forge test --fork-url https://speedy-nodes-nyc.moralis.io/0789fa9194b002fb68a53415/fantom/mainnet -vvv
//forge test --fork-url https://speedy-nodes-nyc.moralis.io/0789fa9194b002fb68a53415/fantom/mainnet -vvv
// forge test --fork-url https://rpc3.fantom.network -vvv
//  forge test --fork-url https://ftmrpc.ultimatenodes.io/ -vvv
//  forge test --fork-url https://rpc.ankr.com/fantom -vvv
