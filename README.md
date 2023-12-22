# UnDefi

[![test](https://github.com/veri5/undefi/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/veri5/undefi/actions/workflows/test.yml)

### Empowering Confidential and Cost-Effective Transactions through a Self-Service Platform

Undefi is a self-service platform designed for executing undisclosed transactions, offering convenience and cost-effectiveness while broadening accessibility to a wider audience. Easily transfer your assets in a confidential, single real-time operation. Take control of your finances and redefine your privacy.

## Requirements

- [Foundry](https://getfoundry.sh/): Confirm installation by running `forge --version` and you should see a response like 
```bash
forge 0.2.0 (a839414 2023-10-26T09:23:16.997527000Z)
```
- [Make](https://www.gnu.org/software/make/): Confirm installation by running `make --version` and you should see a response like 
```bash
GNU Make 3.81
Copyright (C) 2006  Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty, not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

This program built for i386-apple-darwin11.3.0
```

## Installation

1. Clone the repository:

```bash
git clone https://github.com/axelarnetwork/foundry-axelar-gmp-example.git
```

2. Navigate into the project directory:

```bash
cd foundry-axelar-gmp-example
```

3. Install the dependencies and build the project:

```bash
make all
```
The command above will install the required dependencies, create a `.env` file from `.env.example`, and update and build the project.

4. Update the PRIVATE_KEY variable with your private key

```bash
PRIVATE_KEY=<your-private-key-here>
```
> ⚠️ WARNING: Never commit your `PRIVATE_KEY` to any public repository or share it with anyone. Exposing your private key compromises the security of your assets and can result in loss or theft. Always keep it confidential and store it securely. If you believe your private key has been exposed, take immediate action to secure your accounts.


# Usage

The repository provides a set of [Makefile](https://opensource.com/article/18/8/what-how-makefile) commands to facilitate common tasks:

- `make all` : Install dependencies, build, and update the project.
- `make setup-env` : Create a `.env` file from `.env.example`.
- `make install` : Install the dependencies.
- `make build` : Compile the contracts.
- `make update` : Update the project.
- `make deploy` : Deploy a specific contract to a given network.
- `make execute` : Execute a specific contract on a given network.
- `make format` : Format the codebase using the Foundry formatter.
- `make test` : Run tests with increased verbosity.
- `make clean` : Clean any generated artifacts.
- `make rpc` : Display RPC URLs for various networks.
- `make help` : Display the help menu.

# Deployment to testnet
To deploy to any of your preferred test networks this project supports, ensure you have tokens from a faucet for the respective network. You can acquire faucet tokens for the Polygon Mumbai testnet [here](https://faucet.polygon.technology/), for Avalanche [here](https://docs.avax.network/build/dapp/smart-contracts/get-funds-faucet), and for Scroll Sepolia [here](https://docs.scroll.io/en/user-guide/faucet/). For Binance, faucet tokens can be obtained on their Discord server, and for [Base](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet), use this link. Make sure that these tokens are in the account linked to the private key you have provided in your `.env` file.

Next, run the following command. 

```bash
make deploy NETWORK=network SCRIPT=script
``` 
The `SCRIPT` parameter specifies which smart contract or script you wish to deploy to the blockchain network. Think of it as the "what" you're deploying, whereas the `NETWORK` parameter is the "where" you're deploying to.

Example:

```bash
make deploy NETWORK=polygon SCRIPT=ExecutableSample
```
The above command deploys the `ExecutableSample` contract to the Polygon Mumbai testnet. This script can also be used to target other contracts within the project.

# Testnet networks
The supported testnet networks are

- Polygon
- Avalanche
- Binance
- Scroll Sepolia
- Base

Note: Additional networks can be added based on your specific needs.