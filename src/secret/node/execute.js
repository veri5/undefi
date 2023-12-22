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
let contractCodeHash = "129ce787a42b73312000a325b769b3af1e5b2d6414916dec040c20a8bcf79163";
let contractAddress = "secret12qa82nrzvpqjk07fcdfn42qxgcfnxvd5jgcyus";

//send_message_evm variables
let destinationChain = "Polygon";
let destinationAddress = "0x137e4fba036bf10cd737f054786f1bf0dad1d7e5";
let myMessage = "UnDefi rules back!";

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