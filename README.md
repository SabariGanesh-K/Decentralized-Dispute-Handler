# Decentralized Dispute Handler
 EVM based Decentralized Dispute handler with 51% attack prevention using the power of Chainlink VRF technology.
![image](https://github.com/SabariGanesh-K/Decentralized-Dispute-Handler/assets/64348740/f0b53bcb-8887-40bb-8368-7443b833053b)

# Sequence Diagram
![image](https://github.com/SabariGanesh-K/Decentralized-Dispute-Handler/assets/64348740/51651bd4-acd7-4bac-8b3b-95e0ceb4b280)

#Setting up Chainlink VRF V2

Checkout the link below to set up Chainlink with sepolia testnet
[https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number](url)

Add sepolia testnet to metamask
[https://www.alchemy.com/overviews/how-to-add-sepolia-to-metamask](url)
Get some Testnet Eth from Sepolia Faucets from Chainlink,Alchemy,Infura,etc

Configure Hardhat with either Infura / Alchemy endpoints through ``` hardhat.config.js ``` file located at root folder by following the given instructions there.
Use the below commands to compile and run the deploy scripts which deploys both contract
```shell
npx hardhat compile
npx hardhat run scripts/deploy.js
```
