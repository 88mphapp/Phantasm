const { BigNumber } =require("@ethersproject/bignumber");
const { IERC20 } =require("../artifacts/contracts/interfaces/IERC20.sol/IERC20.json");
const { expect } = require("chai");
const { ethers, networks, upgrades } = require("hardhat");

const daiAbi = [
  {
      "constant": true,
      "inputs": [],
      "name": "name",
      "outputs": [
          {
              "name": "",
              "type": "string"
          }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
  },
  {
      "constant": false,
      "inputs": [
          {
              "name": "_spender",
              "type": "address"
          },
          {
              "name": "_value",
              "type": "uint256"
          }
      ],
      "name": "approve",
      "outputs": [
          {
              "name": "",
              "type": "bool"
          }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
  },
  {
      "constant": true,
      "inputs": [],
      "name": "totalSupply",
      "outputs": [
          {
              "name": "",
              "type": "uint256"
          }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
  },
  {
      "constant": false,
      "inputs": [
          {
              "name": "_from",
              "type": "address"
          },
          {
              "name": "_to",
              "type": "address"
          },
          {
              "name": "_value",
              "type": "uint256"
          }
      ],
      "name": "transferFrom",
      "outputs": [
          {
              "name": "",
              "type": "bool"
          }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
  },
  {
      "constant": true,
      "inputs": [],
      "name": "decimals",
      "outputs": [
          {
              "name": "",
              "type": "uint8"
          }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
  },
  {
      "constant": true,
      "inputs": [
          {
              "name": "_owner",
              "type": "address"
          }
      ],
      "name": "balanceOf",
      "outputs": [
          {
              "name": "balance",
              "type": "uint256"
          }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
  },
  {
      "constant": true,
      "inputs": [],
      "name": "symbol",
      "outputs": [
          {
              "name": "",
              "type": "string"
          }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
  },
  {
      "constant": false,
      "inputs": [
          {
              "name": "_to",
              "type": "address"
          },
          {
              "name": "_value",
              "type": "uint256"
          }
      ],
      "name": "transfer",
      "outputs": [
          {
              "name": "",
              "type": "bool"
          }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
  },
  {
      "constant": true,
      "inputs": [
          {
              "name": "_owner",
              "type": "address"
          },
          {
              "name": "_spender",
              "type": "address"
          }
      ],
      "name": "allowance",
      "outputs": [
          {
              "name": "",
              "type": "uint256"
          }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
  },
  {
      "payable": true,
      "stateMutability": "payable",
      "type": "fallback"
  },
  {
      "anonymous": false,
      "inputs": [
          {
              "indexed": true,
              "name": "owner",
              "type": "address"
          },
          {
              "indexed": true,
              "name": "spender",
              "type": "address"
          },
          {
              "indexed": false,
              "name": "value",
              "type": "uint256"
          }
      ],
      "name": "Approval",
      "type": "event"
  },
  {
      "anonymous": false,
      "inputs": [
          {
              "indexed": true,
              "name": "from",
              "type": "address"
          },
          {
              "indexed": true,
              "name": "to",
              "type": "address"
          },
          {
              "indexed": false,
              "name": "value",
              "type": "uint256"
          }
      ],
      "name": "Transfer",
      "type": "event"
  }
];


// describe("Deposit", function () {
//   it("Deposit DAI", async function () {

//     const Greeter = await ethers.getContractFactory("GeistImplementation");

//     const greeter = await Greeter.deploy();

//     await greeter.deployed();

//     let AssetAmount = BigNumber.from("1000000000000000000000")
//     let BorrowAmount = BigNumber.from("100000000000000000000")


//     await ethers.provider.send("hardhat_impersonateAccount", [
//       "0x36cb763573813990DFaE2069c4dF4eefba3aec7F",
//     ]);
//     const impersonatedAccount = await ethers.provider.getSigner(
//       "0x36cb763573813990DFaE2069c4dF4eefba3aec7F"
//     );

//     const provider = ethers.provider;

//     await hre.network.provider.request({
//       method: "hardhat_impersonateAccount",
//       params: ["0x36cb763573813990DFaE2069c4dF4eefba3aec7F"],
//     });

//     const signer = await ethers.getSigner("0x36cb763573813990DFaE2069c4dF4eefba3aec7F")
    
//     var DAI = new ethers.Contract("0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E", daiAbi , signer);

//     const bal = await DAI.balanceOf("0x36cb763573813990DFaE2069c4dF4eefba3aec7F");
//     console.log("balance of address before makedeposit", bal);  

//     let ee = await DAI.approve(greeter.address, AssetAmount);
//     console.log("greeter address", greeter.address)
//     console.log(ee);

//     test = await greeter.connect(signer).depositMoney(AssetAmount, BorrowAmount);
//     let after =DAI.balanceOf("0x36cb763573813990DFaE2069c4dF4eefba3aec7F")
    
//     console.log("balance of address after makedeposit", after );  

//     expect((bal-after)==AssetAmount);


//   });
// });

// describe("Leverage Long", function () {
//     it("leveerage long WFTM", async function () {
  
  
//       const GeistImplementation = await ethers.getContractFactory("GeistImplementation");
//       const SpookySwap = await ethers.getContractFactory("SpookySwapper");

  
//       const geist = await GeistImplementation.deploy();
//       const spooky = await SpookySwap.deploy();

//       await spooky.deployed();
//       await geist.deployed();
  

  
//       let AssetAmount = BigNumber.from("1000000000000000000000") //1000
  
  
//       await ethers.provider.send("hardhat_impersonateAccount", [
//         "0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1",
//       ]);
//       const impersonatedAccount = await ethers.provider.getSigner(
//         "0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1"
//       );
  
//       const provider = ethers.provider;
  
//       await hre.network.provider.request({
//         method: "hardhat_impersonateAccount",
//         params: ["0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1"],
//       });
  
//       const signer = await ethers.getSigner("0xcDc39431BFa67BCfDD6158BE5a74AE1cd37Bd1D1")
      
//       var DAI = new ethers.Contract("0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E", daiAbi , signer);
//       var WFTM = new ethers.Contract("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", daiAbi , signer);

      
//       let ee = await WFTM.approve(geist.address, AssetAmount);
  
//        let totalBorrow;
//        let totalBought;
//       // totalBorrow = await geist.connect(signer).leverageLong("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", spooky.address, AssetAmount);
//       console.log(await geist.connect(signer).callStatic.leverageLong("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", spooky.address, AssetAmount));
//       //console.log(totalBorrow);
//       console.log("leverage long done")

      
//       expect(1>0);
  
  
//     });

// });


// describe("openInsulatedLongPositionNFT", function () {
//     it("openInsulatedLongPositionNFT with WFTM", async function () {
  
  
//       const GeistImplementation = await ethers.getContractFactory("GeistImplementation");
//       const SpookySwap = await ethers.getContractFactory("SpookySwapper");
//       const EEIntegration = await ethers.getContractFactory("EEIntegration");
//       const PhantasmManager = await ethers.getContractFactory("PhantasmManager");

  
//       const geist = await GeistImplementation.deploy();
//       const spooky = await SpookySwap.deploy();
//       const ee = await EEIntegration.deploy();
//       const phantasm = await PhantasmManager.deploy(geist.address, ee.address, spooky.address);

//       await spooky.deployed();
//       await geist.deployed();
//       await ee.deployed();
//       await phantasm.deployed();


  
//       let AssetAmount = BigNumber.from("4000000000000000000000") //4000
//       let AssetAmount2 = BigNumber.from("500000000000000000000") //500


  
//       await ethers.provider.send("hardhat_impersonateAccount", [
//         "0x36cb763573813990DFaE2069c4dF4eefba3aec7F",
//       ]);
//       const impersonatedAccount = await ethers.provider.getSigner(
//         "0x36cb763573813990DFaE2069c4dF4eefba3aec7F"
//       );
  
//       const provider = ethers.provider;
  
//       await hre.network.provider.request({
//         method: "hardhat_impersonateAccount",
//         params: ["0x36cb763573813990DFaE2069c4dF4eefba3aec7F"],
//       });
  
//       const signer = await ethers.getSigner("0x36cb763573813990DFaE2069c4dF4eefba3aec7F")
      
//       var DAI = new ethers.Contract("0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E", daiAbi , signer);
//       var WFTM = new ethers.Contract("0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E", daiAbi , signer);
      
//       await DAI.transfer(ee.address, AssetAmount);

//       console.log("after transfer")

      


//       let a = await phantasm.connect(signer).getContractHealth();

//       console.log(a);
//       // totalBorrow = await geist.connect(signer).leverageLong("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", spooky.address, AssetAmount);
//       //(await phantasm.connect(signer).openInsulatedLongPositionNFT("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", 2, AssetAmount, 118, AssetAmount2));
//       let appro2 = await DAI.approve(phantasm.address, AssetAmount);

//       (await phantasm.connect(signer).testshit(AssetAmount));
//       console.log("open insulated long done!")

//       a = await phantasm.connect(signer).getContractHealth();

//       console.log(a);

//       a = await phantasm.connect(signer).getContractHealth();

//       console.log(a);

  
//     });
//   });
  
//   describe("openInsulatedLongPositionNFT", function () {
//     it("openInsulatedLongPositionNFT with WFTM", async function () {
  
  
//       const GeistImplementation = await ethers.getContractFactory("GeistImplementation");
//       const SpookySwap = await ethers.getContractFactory("SpookySwapper");
//       const EEIntegration = await ethers.getContractFactory("EEIntegration");
//       const PhantasmManager = await ethers.getContractFactory("PhantasmManager");

  
//       const geist = await GeistImplementation.deploy();
//       const spooky = await SpookySwap.deploy();
//       const ee = await EEIntegration.deploy();
//       const phantasm = await PhantasmManager.deploy(geist.address, ee.address, spooky.address);

//       await spooky.deployed();
//       await geist.deployed();
//       await ee.deployed();
//       await phantasm.deployed();


  
//       let AssetAmount = BigNumber.from("4000000000000000000000") //4000
//       let AssetAmount2 = BigNumber.from("500000000000000000000") //500


  
//       await ethers.provider.send("hardhat_impersonateAccount", [
//         "0x4dCA1fb2a8B49ccFa7c71aC0050b888874fAbbE9",
//       ]);
//       const impersonatedAccount = await ethers.provider.getSigner(
//         "0x4dCA1fb2a8B49ccFa7c71aC0050b888874fAbbE9"
//       );
  
//       const provider = ethers.provider;
  
//       await hre.network.provider.request({
//         method: "hardhat_impersonateAccount",
//         params: ["0x4dCA1fb2a8B49ccFa7c71aC0050b888874fAbbE9"],
//       });
  
//       const signer = await ethers.getSigner("0x4dCA1fb2a8B49ccFa7c71aC0050b888874fAbbE9")
      
//       var DAI = new ethers.Contract("0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E", daiAbi , signer);
//       var WFTM = new ethers.Contract("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", daiAbi , signer);
      
//       await DAI.transfer(ee.address, AssetAmount);

//       console.log("after transfer")

      
//       let appro = await WFTM.approve(ee.address, AssetAmount);

       
//       console.log("after deposit");

//       let a = await phantasm.connect(signer).getContractHealth();

//       console.log(a); 
  
      
//       let appro2 = await WFTM.approve(phantasm.address, AssetAmount);

//       (await phantasm.connect(signer).openLongPositionNFT("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", 2, AssetAmount));
//       //(await phantasm.connect(signer).testshit(AssetAmount,"0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E" ));

//       console.log("open insulated long done!")

//       a = await phantasm.connect(signer).getContractHealth();

//       console.log(a);

//     });
//   });













  describe("Long position NFT ", function () {
    it("Test long and close", async function () {
  
  
      const GeistImplementation = await ethers.getContractFactory("GeistImplementation");
      const SpookySwap = await ethers.getContractFactory("SpookySwapper");
      const EEIntegration = await ethers.getContractFactory("EEIntegration");
      const PhantasmManager = await ethers.getContractFactory("PhantasmManager");

  
      const geist = await GeistImplementation.deploy();
      const spooky = await SpookySwap.deploy();
      const ee = await EEIntegration.deploy();
      const phantasm = await PhantasmManager.deploy(geist.address, ee.address, spooky.address);

      await spooky.deployed();
      await geist.deployed();
      await ee.deployed();
      await phantasm.deployed();


  
      let AssetAmount = BigNumber.from("1000000000000000000000") //4000
      let AssetAmount2 = BigNumber.from("500000000000000000000") //500

      const impersonaterAddress = "0xc62A0781934744E05927ceABB94a3043CdCfEA89"  //whale


  
      await ethers.provider.send("hardhat_impersonateAccount", [impersonaterAddress]);
      const impersonatedAccount = await ethers.provider.getSigner(impersonaterAddress);
  
      const provider = ethers.provider;
  
      await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [impersonaterAddress],
      });
  
      const signer = await ethers.getSigner(impersonaterAddress)
      
      var DAI  = new ethers.Contract("0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E", daiAbi , signer);
      var WFTM = new ethers.Contract("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", daiAbi , signer);
      var WETH = new ethers.Contract("0x74b23882a30290451A17c44f4F05243b6b58C76d", daiAbi , signer);
      var LINK = new ethers.Contract("0xb3654dc3D10Ea7645f8319668E8F54d2574FBdC8", daiAbi , signer);
      var CRV = new ethers.Contract("0x1E4F97b9f9F913c46F1632781732927B9019C68b", daiAbi , signer);
      var MIM = new ethers.Contract("0x82f0B8B456c1A451378467398982d4834b6829c1", daiAbi , signer);


      let appro = await MIM.approve(ee.address, AssetAmount);
       
      console.log("after deposit");

      let a = await phantasm.connect(signer).getContractHealth();

      console.log(a); 

      
      let appro2 = await CRV.approve(phantasm.address, AssetAmount);

      (await phantasm.connect(signer).openLongPositionNFT("0x1E4F97b9f9F913c46F1632781732927B9019C68b", 2, AssetAmount));
      //(await phantasm.connect(signer).testshit(AssetAmount,"0x1E4F97b9f9F913c46F1632781732927B9019C68b" ));

      (await phantasm.connect(signer).closeLongPosition("0x1E4F97b9f9F913c46F1632781732927B9019C68b", 2, AssetAmount));



      console.log("open insulated long done!")

      a = await phantasm.connect(signer).getContractHealth();

      console.log(a);

    });
  });






























  
// describe("openLongPositionNFT", function () {
//     it("openLongPositionNFT with WFTM", async function () {
  
  
//       const GeistImplementation = await ethers.getContractFactory("GeistImplementation");
//       const SpookySwap = await ethers.getContractFactory("SpookySwapper");
//       const EEIntegration = await ethers.getContractFactory("EEIntegration");
//       const PhantasmManager = await ethers.getContractFactory("PhantasmManager");

//       const geist = await GeistImplementation.deploy();
//       const spooky = await SpookySwap.deploy();
//       const ee = await EEIntegration.deploy();
//       const phantasm = await PhantasmManager.deploy(geist.address, ee.address, spooky.address);

//       await spooky.deployed();
//       await geist.deployed();
//       await ee.deployed();
//       await phantasm.deployed();


  
//       let AssetAmount = BigNumber.from("4000000000000000000000") //4000
//       let AssetAmount2 = BigNumber.from("500000000000000000000") //500


  
//       await ethers.provider.send("hardhat_impersonateAccount", [
//         "0x4dCA1fb2a8B49ccFa7c71aC0050b888874fAbbE9",
//       ]);
//       const impersonatedAccount = await ethers.provider.getSigner(
//         "0x4dCA1fb2a8B49ccFa7c71aC0050b888874fAbbE9"
//       );
  
//       const provider = ethers.provider;
  
//       await hre.network.provider.request({
//         method: "hardhat_impersonateAccount",
//         params: ["0x4dCA1fb2a8B49ccFa7c71aC0050b888874fAbbE9"],
//       });
  
//       const signer = await ethers.getSigner("0x4dCA1fb2a8B49ccFa7c71aC0050b888874fAbbE9")
      
//       var DAI = new ethers.Contract("0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E", daiAbi , signer);
//       var WFTM = new ethers.Contract("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", daiAbi , signer);
      


//       let appro2 = await WFTM.approve(phantasm.address, AssetAmount);

//       totalBorrow = await geist.connect(signer).leverageLong("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", spooky.address, AssetAmount);
//       //let positionid=(await phantasm.connect(signer).callStatic.openLongPositionNFT("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", 2,  AssetAmount2));
//       console.log("open leverage long done")



      
//       expect(positionid>=1);

//     });
//   });
  


