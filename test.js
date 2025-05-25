const { Web3 } = await import("web3");
const myweb3 = new Web3("http://localhost:8545");

// Gas and wei 
// var gas = await myweb3.eth.getGasPrice();
// var wei  = await myweb3.utils.toWei('1', 'ether');
// console.log(gas);
// console.log(wei);


// Accounts 10000 ETH each --> 10^18 wei
// 10000000000000000000000n
// var accounts = await myweb3.eth.getAccounts()
// var balance0 = await myweb3.eth.getBalance(accounts[1])
// console.log(balance0)


// Transactions
// var transaction = await myweb3.eth.sendTransaction({from: accounts[0], to: accounts[1], value: 10})
// console.log(transaction);

// var contractAbi = [{"inputs":[{"internalType":"uint256","name":"withdraw_amount","type":"uint256"}],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}];
// var FaucetContract = new myweb3.eth.Contract(contractAbi);
// var estimatedGas = await myweb3.eth.estimateGas({data: contractBin});
// console.log(estimatedGas)

// await deployContract(myweb3).then((instance) => {
//     // console.log(instance.options.address)
//     sendFundsToContract(myweb3, instance.options.address)
// });

// Accounts 10000 ETH each --> 10^18 wei
// 10000000000000000000000n
// var accounts = await myweb3.eth.getAccounts()
// const balance = await myweb3.eth.getBalance(accounts[0]);
// console.log("Sender balance:", myweb3.utils.fromWei(balance, "ether"));
