import "./App.css";
import { useState, useEffect, useCallback } from "react";
import Web3 from "web3";
import { newKitFromWeb3 } from "@celo/contractkit";
import BigNumber from "bignumber.js";

import freelancer from "./contracts/freelancer.abi.json";
import IERC from "./contracts/ierc.abi.json";
import Header from "./components/Header";
import Main from "./components/Main";
import Form from "./components/Form";

const ERC20_DECIMALS = 18;

const contractAddress = "0x7Df5f6906A9b4298f0767b1c2d79f8d6Cb84Bdef";
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1";

function App() {
  const [contract, setcontract] = useState(null);
  const [address, setAddress] = useState(null);
  const [kit, setKit] = useState(null);
  const [freelancers, setFreelancers] = useState([]);
  const [cUSDBalance, setcUSDBalance] = useState(0);

  useEffect(() => {
    celoConnect();
  }, []);

  useEffect(() => {
    if (kit && address) {
      getBalance();
    } else {
      console.log("no kit");
    }
  }, [kit, address]);

  useEffect(() => {
    if (contract) {
      getFreelancer();
    }
  }, [contract]);

  const celoConnect = async () => {
    if (window.celo) {
      try {
        await window.celo.enable();
        const web3 = new Web3(window.celo);
        let kit = newKitFromWeb3(web3);

        const accounts = await kit.web3.eth.getAccounts();
        const user_address = accounts[0];

        kit.defaultAccount = user_address;

        await setAddress(user_address);
        await setKit(kit);
        console.log(user_address);
      } catch (error) {
        console.log(error);
      }
    } else {
      console.log("Error");
    }
  };

  const getBalance = async () => {
    try {
      const balance = await kit.getTotalBalance(address);
      const USDBalance = balance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2);

      const contract = new kit.web3.eth.Contract(freelancer, contractAddress);
      setcontract(contract);
      console.log(contract);
      setcUSDBalance(USDBalance);
    } catch (error) {
      console.log(error);
    }
  };

  const getFreelancer = async () => {
    try {
      const freelancerLength = await contract.methods
        .getFreelancerLength()
        .call();
      const _freelancers = [];

      for (let index = 0; index < freelancerLength; index++) {
        let _freelancer = new Promise(async (resolve, reject) => {
          let freelancer = await contract.methods.getFreelancer(index).call();
          resolve({
            index: index,
            owner: freelancer[0],
            name: freelancer[1],
            imageUrl: freelancer[2],
            jobDescription: freelancer[3],
            amount: freelancer[4],
            isHired: freelancer[5],
          });
        });
        _freelancers.push(_freelancer);
      }
      const freelancers = await Promise.all(_freelancers);
      setFreelancers(freelancers);
    } catch (error) {
      console.log(error);
    }
  };

  const hireFreelancer = async (index,_amount) => {
    const cUSDContract = new kit.web3.eth.Contract(IERC, cUSDContractAddress);
    try {
      await cUSDContract.methods
        .approve(contractAddress, _amount)
        .send({ from: address });
      await contract.methods.hireFreelancer(index).send({ from: address });
      getFreelancer();
    } catch (error) {
      console.log(error);
    }
  };

  const addFreelancer = async (name, description, image, _amount) => {
    const cUSDContract = new kit.web3.eth.Contract(IERC, cUSDContractAddress);
    try {
      const amount = new BigNumber(1).shiftedBy(ERC20_DECIMALS).toString();
      await cUSDContract.methods
        .approve(contractAddress, amount)
        .send({ from: address });
      await contract.methods
        .addFreelancer(name, image, description, amount, false)
        .send({ from: address });
      getFreelancer();
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <div>
      <Header balance={cUSDBalance} />
      <Main freelancers={freelancers} hireFreelancer = {hireFreelancer}/>
      <Form addFreelancer={addFreelancer} />
    </div>
  );
}

export default App;
