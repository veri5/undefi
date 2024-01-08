import { SecretNetworkClient, Wallet } from "secretjs";
import dotenv from "dotenv";
dotenv.config();

const wallet = new Wallet(process.env.MNEMONIC);

const secretjs = new SecretNetworkClient({
  chainId: "pulsar-3",
  url: "https://api.pulsar3.scrttestnet.com",
  wallet: wallet,
  walletAddress: wallet.address,
});

// secret contract info
let contractCodeHash = "db52ac888c67b1715c32b750f3e718da138f36ef6c4c870a956d12774e7a8305";
let contractAddress = "secret1xellx0nty80cr92fynf928e5fy0dj6dd2g2f8r";

//send_message_evm variables
let destinationChain = "Polygon";
let destinationAddress = "0xdC6726BBE49c852Cf5E1EC6EaE8467C029724e68";
let myMessage = "77441867501911094552758180949755689375269979576562133636519309172089474839469";

let send_message_evm = async () => {
  const tx = await secretjs.tx.compute.executeContract(
    {
      sender: wallet.address,
      contract_address: contractAddress,
      msg: {
        send_message_evm: {
          destination_chain: destinationChain,
          destination_address: destinationAddress,
          message: myMessage,
        },
      },
      code_hash: contractCodeHash,
      sent_funds: [
        {
          amount: "150000",
          denom:
            "ibc/9463E39D230614B313B487836D13A392BD1731928713D4C8427A083627048DB3",
        },
      ],
    },
    { gasLimit: 100_000 }
  );

  console.log(tx);
};
send_message_evm();