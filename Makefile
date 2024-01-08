# Include environment variables from .env file
-include .env
export

# PHONY Targets declaration
.PHONY: setup-env build deploy format test clean rpc help all install update createTransferRecord readTransferRecord

# Supported networks and scripts
NETWORKS = anvil polygon avalanche binance scroll_sepolia base
SCRIPTS = TransferTracker

# Help target - Displays available commands with descriptions
help:
	@echo "\033[0;32mAvailable targets:\033[0m"
	@echo "setup-env              - Set up the environment by creating a .env file from .env.example."
	@echo "install                - Install dependencies using the forge tool."
	@echo "build                  - Build using the forge tool." 
	@echo "update                 - Update dependencies using the forge tool."
	@echo "deploy                 - Deploy the specified script to the specified network."
	@echo "execute                - Execute the specified script manually."
	@echo "format                 - Format using the forge tool."
	@echo "test                   - Run tests using the forge tool."
	@echo "clean                  - Clean using the forge tool."
	@echo "rpc                    - Display the RPC URLs for all supported networks." 
	@echo "help                   - Display this help message."


all: clean setup-env build

setup-env: 
	@if [ ! -f .env ]; then \
		echo "\033[0;33m⤵ Reading .env.example.\033[0m"; \
		cp .env.example .env; \
		echo "\033[0;33m⤵ Creating .env file.\033[0m"; \
		echo "\033[0;32m📨 Created .env file successfully!\033[0m"; \
	else \
		echo "\033[0;34mA .env file already exists, not modifying it.\033[0m"; \
	fi

# Install Dependencies
install:
	forge install axelarnetwork/axelar-gmp-sdk-solidity@v5.5.2 --no-commit && forge install openzeppelin/openzeppelin-contracts@v5.0.0 --no-commit && forge install foundry-rs/forge-std@v1.7.1 --no-commit

# Update Dependencies
update:
	forge update
   
# Build target   
build:
	@forge build

# Determine the script path outside of the recipe
ifeq ($(SCRIPT),TransferTracker)
SCRIPT_PATH=script/TransferTracker.s.sol:TransferTrackerScript
endif

# Deploy target
deploy:
ifndef NETWORK
	$(error NETWORK is undefined.)
endif
ifndef SCRIPT
	$(error SCRIPT is undefined.)
endif
	@echo "Current NETWORK: $(NETWORK)"
	@NETWORK=$(NETWORK) forge script $(SCRIPT_PATH) --rpc-url $($(shell echo $(NETWORK) | tr a-z A-Z)_TESTNET_RPC_URL) --broadcast --legacy
	@echo "Script executed successfully!"

# Format target
format: 
	@forge fmt
   
# Test target   
test:
	@forge test -vvvv
  
# Clean target
clean:
	@:; forge clean

# Display RPC URLs 
rpc:
	@echo "\033[0;33mAnvil RPC URL:\033[0m" $(ANVIL_TESTNET_RPC_URL)
	@echo "\033[0;32mPolygon RPC URL:\033[0m" $(POLYGON_TESTNET_RPC_URL)     
	@echo "\033[0;34mAvalanche RPC URL:\033[0m" $(AVALANCHE_TESTNET_RPC_URL)
	@echo "\033[0;35mBinance RPC URL:\033[0m" $(BINANCE_TESTNET_RPC_URL)     
	@echo "\033[0;36mScroll RPC URL:\033[0m" $(SCROLL_SEPOLIA_TESTNET_RPC_URL)       
	@echo "\033[0;33mBase RPC URL:\033[0m" $(BASE_TESTNET_RPC_URL)

createTransferRecord:
# Validate required environment variables
ifndef PUBLIC_ADDRESS
	$(error PUBLIC_ADDRESS is undefined. Please set it in your .env file.)
endif
ifndef PRIVATE_KEY
	$(error PRIVATE_KEY is undefined. Please set it in your .env file.)
endif
ifndef EVM_CONTRACT_ADDRESS
	$(error EVM_CONTRACT_ADDRESS is undefined. Please set it in your .env file.)
endif

# Calculate amounts in wei and use the network-specific RPC URL from the environment
	@:; network_upper=$$(echo $(NETWORK) | tr '[:lower:]' '[:upper:]'); \
	amount_in_wei=$$(echo "scale=0; 16*10^18/1" | bc -l); \
	rpc_url_var=$${network_upper}_TESTNET_RPC_URL; \
	rpc_url=$${!rpc_url_var}; \
	cast send $(EVM_CONTRACT_ADDRESS) "createTransferRecord(address payable, uint256)(uint256)" $(PUBLIC_ADDRESS) $$amount_in_wei --rpc-url $$rpc_url --private-key "$(PRIVATE_KEY)" || \
	echo "\033[31mTransaction failed. Please check the provided details and try again.\033[0m"; \

readTransferRecord:
# Validate required environment variables
ifndef TRANSFER_ID
	$(error TRANSFER_ID is undefined. Please set it in your .env file.)
endif
ifndef EVM_CONTRACT_ADDRESS
	$(error EVM_CONTRACT_ADDRESS is undefined. Please set it in your .env file.)
endif
	@:; network_upper=$$(echo $(NETWORK) | tr '[:lower:]' '[:upper:]'); \
	rpc_url_var=$${network_upper}_TESTNET_RPC_URL; \
	rpc_url=$${!rpc_url_var}; \
	cast call $(EVM_CONTRACT_ADDRESS) "readTransferRecord(uint256)(address payable, uint256, uint256, uint256)" $(TRANSFER_ID) --rpc-url $$rpc_url || \
	echo "\033[31mTransaction failed. Please check the provided details and try again.\033[0m";