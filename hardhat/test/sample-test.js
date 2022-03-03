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


describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {


    const Greeter = await ethers.getContractFactory("GeistImplementation");


    const greeter = await Greeter.deploy();


    await greeter.deployed();

    // await network.provider.request({
    //   method: "hardhat_impersonateAccount",
    //   params: ["0x36cb763573813990DFaE2069c4dF4eefba3aec7F"]
    // });

    let AssetAmount = BigNumber.from("100000000000000000000")

    let test = await greeter.getBalance()
    console.log("Balance");
    console.log(test);


    await ethers.provider.send("hardhat_impersonateAccount", [
      "0x36cb763573813990DFaE2069c4dF4eefba3aec7F",
    ]);
    const impersonatedAccount = await ethers.provider.getSigner(
      "0x36cb763573813990DFaE2069c4dF4eefba3aec7F"
    );
    console.log("we");

    //await greeter.connect(impersonatedAccount).deposit();
    const provider = ethers.provider;

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x36cb763573813990DFaE2069c4dF4eefba3aec7F"],
    });

    const signer = await ethers.getSigner("0x36cb763573813990DFaE2069c4dF4eefba3aec7F")
    
    var DAI = new ethers.Contract("0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E", daiAbi , signer);

    


    const resultw = await greeter.connect(signer).getBalance();
    console.log(resultw);



 

      console.log("before  approve");
      let ee = await DAI.approve(greeter.address, AssetAmount);
      console.log("after approve");
  

      const d = await DAI.transfer(greeter.address, AssetAmount);

      console.log("transfer complete");



      const result = await greeter.connect(signer).getBalance();
      console.log(result);


    test = await greeter.connect(signer).deposit();
    console.log("Eth Collateral");
    
    const resultq = await greeter.connect(signer).getValue();
    console.log(resultq);

    
    expect(await greeter.connect(signer).getValue() >= AssetAmount);


  });
});
