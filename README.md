# Decentralized Dispute Handler
 EVM based Decentralized Dispute handler with 51% attack prevention using the power of Chainlink VRF technology.
![image](https://github.com/SabariGanesh-K/Decentralized-Dispute-Handler/assets/64348740/9f963347-e77d-437e-952b-23575061b11c)


# Sequence Diagram
![image](https://github.com/SabariGanesh-K/Decentralized-Dispute-Handler/assets/64348740/4f8dbf8d-d05c-4d19-b3f2-c38dd183eb67)



# Setting up Chainlink VRF V2

Checkout the link below to set up Chainlink with sepolia testnet
[https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number](url)

# Setting up Testnets and deploying contracts through endpoints

Add sepolia testnet to metamask
[https://www.alchemy.com/overviews/how-to-add-sepolia-to-metamask](url)
Get some Testnet Eth from Sepolia Faucets from Chainlink,Alchemy,Infura,etc

Configure Hardhat with either Infura / Alchemy endpoints through ``` hardhat.config.js ``` file located at root folder by following the given instructions there.
Use the below commands to compile and run the deploy scripts which deploys both contract
```shell
npx hardhat compile
npx hardhat run scripts/deploy.js
```

# Actors

## Admin
Responsible for facilitating the disputes. Gets logistics duties but will not have power to interfere between disputes or manipulate disputes. Can trigger refresh of voting process in case of any errors with Chainlink VRF oracles response delay. Allows to call a function that triggers fetching "fullfilled" status of request ID given that gets random numbers , if fulfilled fetches random numbers and intiiates voting. Also whitelists the ```DisputeHandler.sol``` contract inside ```VRFv2Consumer.sol``` contract that allows it to request random numbers.

## Filer
Files a dispute in the system by giving needed informations necessary and also stakes ether into contract that will be used for processing fee and penalties (If dispute is lost). Targets a Reciever against whom dispute is filed. Once he files a dispute using ```StartDispute()``` , 2 days time is given for "Reciever" to counter reply before voting starts. Filer Gets back 50% of his staked fund if he wins the dispute (For votes > Against votes as per 51% rule )

## Reciever
Once he files a counter reply to dispute filed against him using ```counterReplyDispute()``` , admin initiates vote process that lasts for 2 days. Gets 50% of Filers stakes if he wins the disputes (Against votes > For against as per 51% rule).

## Tie rule
If voting gets tied up , either Dispute can be filed again with better description and counter replies. But staked funds will be taken completely by contract as processing fee.

## Randomness flow
When a dispute is filed using ```startDispute()``` function in ```DisputeHandler.sol ``` , a private function embedded in the same ```requestRandomAndGetId()``` is called that connects with the VRF contract ```VRFv2Consumer.sol``` and calls the ```requestRandomWords()``` function that returns a requestId which is used in Dispute struct  to track random words fullfill status.
Following by it , when admin calls ```verifyFullfillnessAndStartVoting()``` function , it uses the request ID to check the fullfill status . If it is true , it takes in random words (number) and modulo divides by participants length to use the random words as a random index taken into participants array to choose n voters who will be whitelisted to vote in the dispute.
``` randomNumber % participants.length ```



