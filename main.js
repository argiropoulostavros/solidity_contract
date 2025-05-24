// const { Web3 } = await import("web3");
import Web3 from 'web3';
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

await deployContract(myweb3).then((instance) => {
    // console.log(instance.options.address)
    sendFundsToContract(myweb3, instance.options.address)
});


/**
 * 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
 * 
 */
async function deployContract(myweb3) {
    1
    var contractAbi = [{ "inputs": [{ "internalType": "uint256", "name": "withdraw_amount", "type": "uint256" }], "name": "withdraw", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "stateMutability": "payable", "type": "receive" }];
    var contractBin = '6080604052348015600e575f5ffd5b506101328061001c5f395ff3fe608060405260043610601e575f3560e01c80632e1a7d4d146028576024565b36602457005b5f5ffd5b3480156032575f5ffd5b50604960048036038101906045919060d6565b604b565b005b67016345785d8a0000811115605e575f5ffd5b3373ffffffffffffffffffffffffffffffffffffffff166108fc8290811502906040515f60405180830381858888f1935050505015801560a0573d5f5f3e3d5ffd5b5050565b5f5ffd5b5f819050919050565b60b88160a8565b811460c1575f5ffd5b50565b5f8135905060d08160b1565b92915050565b5f6020828403121560e85760e760a4565b5b5f60f38482850160c4565b9150509291505056fea2646970667358221220707d7ebbe482b09088bcaee0692c6ead8c71be7e3dba27bf4d5e21a6cfbd188164736f6c634300081e0033'
    var FaucetContract = new myweb3.eth.Contract(contractAbi);
    var estimatedGas = await myweb3.eth.estimateGas({ data: contractBin });
    var gasPrice = await myweb3.eth.getGasPrice();
    var accounts = await myweb3.eth.getAccounts()
    var gasLimitNumber = Number(estimatedGas) * 1.3;
    var gasLimit = BigInt(Math.ceil(gasLimitNumber)); 

    return await FaucetContract.deploy({ data: '0x' + contractBin })
        .send({ from: accounts[0], gas: gasLimit, gasPrice: gasPrice })
    // .then((instance) => {
    //     console.log(instance.options.address)
    // });

}

async function sendFundsToContract(myweb3, contractAddress) {
    var contractBalanceBefore = await myweb3.eth.getBalance(contractAddress);
    var accounts = await myweb3.eth.getAccounts()

    console.log("Balance before :" + contractBalanceBefore)
    var amountToSend = myweb3.utils.toWei('2', 'ether');
    sendTx = await myweb3.eth.sendTransaction({ from: accounts[0], to: contractAddress, value: amountToSend });

    var contractBalanceAfter = await myweb3.eth.getBalance(contractAddress);
    console.log("Balance after :" + contractBalanceAfter)
}