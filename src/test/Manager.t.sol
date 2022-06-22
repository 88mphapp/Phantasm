// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.12;

import "./utils/console.sol";
import "../../lib/ds-test/src/test.sol";
import {SpookySwapper} from "../SpookySwap.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {GeistImplementation} from "../geistImplementation.sol";
import {PhantasmManager} from "../PhantasmManager.sol";
import "../interfaces/IlendingPoolAddressesProvider.sol";
import {EEIntegration} from "../EEImplementation.sol";
import {DInterest} from "../interfaces/IDinterest.sol";

interface Vm {
    function prank(address) external;

    function startPrank(address) external;

    function stopPrank() external;
}

contract PhantasmManagertest is DSTest {
    EEIntegration testEEIntegration = new EEIntegration();
    SpookySwapper testSwapper = new SpookySwapper();
    DInterest daiDInterestPool;
    PhantasmManager test;
    GeistImplementation testgeist;


    IERC20 dai;
    IERC20 TOMB;
    IERC20 WFTM;
    IERC20 DAI;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        testgeist = new GeistImplementation();        
        test = new PhantasmManager(address(testgeist), address(testEEIntegration), address(testSwapper));        
        
        DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }

    function testManager() public {
        vm.startPrank(0x27182842E098f60e3D576794A5bFFb0777E025d3);  //dai and weth whale
        uint256 _amount = 10000 * 1e18;
        uint256 _amount2 = 1000 * 1e18;

        DAI.transfer(address(testEEIntegration), 100000 * (10**18));
        DAI.transfer(address(0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1), 80000 * (10**18));

        console.log("sent balance");

        uint64 maturationTimestamp = 1647804453;

        vm.stopPrank();

        vm.startPrank(0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1);  //ftm and wftm whale

        DAI.approve(address(testEEIntegration), _amount2);
        
        daiDInterestPool = DInterest(0xa78276C04D8d807FeB8271fE123C1f94c08A414d); // This Should Be DAI Via Scream Pool: Default - 0xa78276C04D8d807FeB8271fE123C1f94c08A414d

        (uint64 depositId,) = testEEIntegration.makeDeposit(address(daiDInterestPool), _amount2, maturationTimestamp);
        
        console.log("dai balance", DAI.balanceOf(0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1));
        console.log("WFTM balance", WFTM.balanceOf(0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1));

        console.log("depositid", depositId);

        WFTM.approve(address(test), _amount);
        DAI.approve(address(test), _amount2);

        uint256 factor = 2;

        uint256 positionId = test.openInsulatedLongPositionNFT(address(WFTM), factor , _amount, depositId, _amount2);

        console.log(positionId);

        vm.stopPrank();

        assertTrue(0<1);
    }
}

// forge test --fork-url https://rpc.ftm.tools/ -vvv
//ftm and dai whale 0xb6E825727DaE1e3886639FAa29bAcf623E8Ed91E  0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca  0x36cb763573813990DFaE2069c4dF4eefba3aec7F  0x1741403bdDd055D7016dBcD0C3ADCb4BFbFD797c
//ftm and wftm whale 0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1
//forge test --fork-url https://speedy-nodes-nyc.moralis.io/0789fa9194b002fb68a53415/fantom/mainnet -vvv

//dai eth 0xe82906b6B1B04f631D126c974Af57a3A7B6a99d9


