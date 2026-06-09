-include .env

.PHONY: dependency node_dependency uploadnft test coverage gas deploy verify_contract mintnft

dependency:
	forge install smartcontractkit/chainlink-brownie-contracts && forge install Cyfrin/foundry-devops@0.4.0 && forge install openzeppelin/openzeppelin-contracts@v5.6.1

node_dependency:
	npm install

uploadnft:
	npm run upload:nft

test:
	forge test -vvv && forge test -vvv --fork-url ${SEPOLIA_URL} 

coverage:
	forge coverage && forge coverage --fork-url ${SEPOLIA_URL} 

gas:
	forge test -vvv --gas-report

deploy:
	forge script script/DeployMyNFT.s.sol --fork-url ${SEPOLIA_URL} --private-key ${PRIVATE_KEY} --broadcast

verify_contract:
	forge verify-contract 0x88dbaf6208877f994be09d038f90a3bcb4c9b2fe src/MyNFT.sol:MyNFT \
  --chain-id 11155111 \
  --etherscan-api-key ${ETHERSCAN_API_KEY} \
  --watch \
  --constructor-args ${CONTRACT_ABI}

mintnft:
	forge script script/Interactions.s.sol:MintNFT \
  --rpc-url ${SEPOLIA_URL} \
  --private-key ${PRIVATE_KEY} \
  --broadcast





