# NFT Foundry

A Foundry-based ERC-721 Collection that demonstrates how to build, test, and deploy a NFT smart contract using `forge`, using the anvil, sepolia and mainnet configurations.

Repo: https://github.com/Chijulybuilds/ERC721-CHIJULY.git

## Quick Start

### Fork and clone

1. Fork the repository on GitHub from:
   - `https://github.com/Chijulybuilds/ERC721-CHIJULY.git`
2. Clone your fork locally:
   ```bash
   git clone https://github.com/<your-username>/ERC721-CHIJULY.git
   cd ERC721-CHIJULY
   ```
3. Create a new branch for your changes:
   ```bash
   git checkout -b feature/my-update
   ```

### Contribute

1. Make changes in your branch.
2. Run tests locally:
   ```bash
   make test
   ```
3. Add and commit your work:
   ```bash
   git add .
   git commit -m "Describe your change"
   ```
4. Push your branch:
   ```bash
   git push origin feature/my-update
   ```
5. Open a pull request on GitHub.

## Project Overview

This repository contains:

- `src/MyNFT.sol` — builds an nft collection of static ERC-721 Tokens.
- `src/MyDynamicNFT.sol` — builds an nft collection of dynamic ERC-721 Tokens using flipMood.
- `test/unit/MyNFTtest.t.sol` — unit tests for static NFTs
- `test/unit/MyDynamicNFTtest.t.sol` — unit tests for dynamic NFTs
- `test/fuzz/MyNFTfuzztest.t.sol` — fuzz tests for static  NFTs that runs on 100.
- `script/DeployMyNFT.s.sol` — deployment script for static NFT collection.
- `script/DeployDynamicNFT.s.sol` — deployment script for dynaic NFT collection
- `Makefile` — common commands for test, gas report, and deploy.

## Requirements

- Foundry installed (`forge`, `cast`, `anvil`)
- Node/npm is not required unless you use extra tools, but Foundry is the main toolchain.
- `.env` file with network variables when running remote tests or deploys.

## Setup

Install dependencies:

```bash
forge install
```

## Common Commands

### Build

```bash
forge build
```

### Test

Run all tests locally and on configured forks:

```bash
make test
```

If you want only the local tests:

```bash
forge test -vvv
```

### Gas report

```bash
make gas
```

Or directly:

```bash
forge test -vvv --gas-report
```

### Deploy to Sepolia

```bash
make deploy
```


## How to Use This Project

- `src/MyNFT.sol` is the NFT collection that creates room for nft IPFS NFT minting.
- `script/DeployMyNFT.s.sol` deploys the NFT collection contract that allows for Nft minting.
- `src/MyDynamicyNFT.sol` is the NFT collection that creates room for nft IPFS Dynamic NFT minting using the flipMood function.
- `script/DeployDynamicNFT.s.sol` deploys the NFT collection contract that allows for Nft minting by automaically reading the svg files using the vm.readfile() to generate the Nft_URI.



## Project Structure

```text
foundry.toml
Makefile
README.md
script/
  DeployDynamicNFT.s.sol
  DeployMyNFT.s.sol
src/
  MyNFT.sol
  MyDynamicNFT.sol
test/
   unit/
      MyNFTtest.t.sol
      MyDynamicNFTtest.t.sol
   fuzz/
      MyNFTfuzztest.t.sol
lib/
   forge-std/
   foundry-devops/
   openzeppelin-contracts/
```

## Notes

- Use `forge fmt` to format Solidity files.
- Use `forge coverage` for coverage reports.
- Keep constructor parameters aligned with network-specific VRF settings for flexibility.

## License

This project is released under the MIT License.
