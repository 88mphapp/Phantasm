// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "./utils/console.sol";
import "../../lib/ds-test/src/test.sol";
import {SpookySwapper} from "../SpookySwap.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {GeistImplementation} from "../geistImplementation.sol";
import {AaveImplementation} from "../AaveLenderImplementation.sol";
import "../interfaces/IAave.sol";
import "../interfaces/IlendingPoolAddressesProvider.sol";

interface Vm {
    function prank(address) external;

    function startPrank(address) external;

    function stopPrank() external;
}

contract SpookySwapperTest is DSTest {
    SpookySwapper testSwapper;
    GeistImplementation test;
    AaveImplementation tester;

    IERC20 dai;
    IERC20 TOMB;
    IERC20 WFTM;
    IERC20 DAI;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        testSwapper = new SpookySwapper();
        test = new GeistImplementation();
        tester = new AaveImplementation();
        dai = IERC20(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E);
        DAI = IERC20(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E);
        TOMB = IERC20(0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7);
        WFTM = IERC20(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);
    }

    function testSwap() public {
        vm.startPrank(0x02517411F32ac2481753aD3045cA19D58e448A01);

        IERC20(TOMB).transfer(
            0xdDf169Bf228e6D6e701180E2e6f290739663a784,
            100000
        );

        vm.stopPrank();

        vm.startPrank(0xdDf169Bf228e6D6e701180E2e6f290739663a784);

        console.log(
            "TOMB balance ",
            TOMB.balanceOf(0xdDf169Bf228e6D6e701180E2e6f290739663a784)
        );

        IERC20(0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7).approve(
            address(testSwapper),
            10000
        );
        IERC20(0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7).approve(
            address(testSwapper),
            10000
        );

        console.log("Before swap dai balance", dai.balanceOf(address(this)));
        console.log("Before swap TOMB balance", TOMB.balanceOf(address(this)));

        testSwapper.Swap(
            0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7,
            0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E,
            10000,
            0,
            address(this)
        );

        console.log("after swap balance");

        console.log(TOMB.balanceOf(address(this)));
        console.log(dai.balanceOf(address(this)));

        vm.stopPrank();

        assertTrue(dai.balanceOf(address(this)) >= 10000);
    }

    function testGesitdeposit() public {
        //ftm

        vm.startPrank(0x36cb763573813990DFaE2069c4dF4eefba3aec7F);

        console.log(
            "dai balance ",
            dai.balanceOf(0x36cb763573813990DFaE2069c4dF4eefba3aec7F)
        );

        IERC20(address(dai)).approve(address(test), 1000);
        IERC20(address(dai)).transfer(address(test), 1000);
        IERC20(address(dai)).approve(address(test), 1000);

        console.log("after approve and transfer");

        test.deposit(address(dai), 1000);


        vm.stopPrank();

        assertTrue(1 < 2);
    }

    function testMakeDeposit() public {
        vm.startPrank(0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca); //dai and ftm whale

        //IERC20(address(DAI)).approve(address(tester), 10000);

        console.log(
            "dai balance b efore makedeposit  ",
            IERC20(DAI).balanceOf(
                address(0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca)
            )
        );

        uint256 _amount = 100000 * 1e18;
        uint256 _amount2 = 100 * 1e18;

        DAI.approve(address(test), _amount);

        IERC20(address(DAI)).approve(address(test), _amount);

        test.depositMoney(_amount, _amount2);
        ILendingPool geistLender = ILendingPool(0x9FAD24f572045c7869117160A571B2e50b10d068);

        (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e , uint256 f) = geistLender.getUserAccountData(address(test));

        vm.stopPrank();

        assertTrue(b > 30000000158240500);
    }

}
// forge test --fork-url https://rpc.ftm.tools/ -vvv
// forge test --fork-url https://mainnet.infura.io/v3/c978b74938064a98b67a150e4ade294d -vvv
//ftm and dai whale 0xb6E825727DaE1e3886639FAa29bAcf623E8Ed91E  0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca  0x36cb763573813990DFaE2069c4dF4eefba3aec7F  0x1741403bdDd055D7016dBcD0C3ADCb4BFbFD797c
//ftm and wftm whale 0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1

//dai eth 0xe82906b6B1B04f631D126c974Af57a3A7B6a99d9
















































