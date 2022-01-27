// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "../console.sol";
import "../../lib/ds-test/src/test.sol";
import {SpookySwapper} from "../SpookySwap.sol";
import {IERC20} from "../interfaces/IERC20.sol";

interface Vm{
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
}
contract SpookySwapperTest is DSTest{
    SpookySwapper testSwapper;
    IERC20  dai;
    IERC20  TOMB;
    IERC20  Weth;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        testSwapper = new SpookySwapper();
        dai = IERC20(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E);
        TOMB = IERC20(0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7);
        Weth = IERC20(0x74b23882a30290451A17c44f4F05243b6b58C76d);
    }

    function testSwap() public {
        vm.startPrank(0x02517411F32ac2481753aD3045cA19D58e448A01);

        TOMB.transfer(address(testSwapper), 1000000);

        console.log(TOMB.balanceOf(address(testSwapper)));

        vm.stopPrank();

        vm.startPrank(0xa7821C3e9fC1bF961e280510c471031120716c3d);

        dai.transfer(address(testSwapper), 1000000);

        console.log(dai.balanceOf(address(testSwapper)));

        vm.stopPrank();


        console.log("Before swap dai balance" , dai.balanceOf(address(testSwapper)));

        testSwapper.Swap(0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7,0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E, 10000, 0, address(this));

        console.log("after swap balance");

        console.log(TOMB.balanceOf(address(this)));
        console.log(dai.balanceOf(address(this)));

         assertTrue(10000 >= dai.balanceOf(address(this)));

    }

}
//forge test --fork-url https://rpc.ftm.tools/ -vvv
