-include .env

.PHONY: dependency node_dependency uploadnft test coverage gas deploy deploy-dynamic verify_contract mintnft


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

deploy-dynamic:
	forge script script/DeployDynamicNFT.s.sol --fork-url ${SEPOLIA_URL} --private-key ${PRIVATE_KEY} --broadcast


verify_contract:
	forge verify-contract 0x8581831eb74d5ee047f544ba297ee4f7e52d3908 src/MyDynamicNFT.sol:MyDynamicNFT \
  --chain-id 11155111 \
  --etherscan-api-key ${ETHERSCAN_API_KEY} \
  --watch \
  --constructor-args ${CONTRACT_ABI}

mintnft:
	forge script script/Interactions.s.sol:MintNFT \
  --rpc-url ${SEPOLIA_URL} \
  --private-key ${PRIVATE_KEY} \
  --broadcast





