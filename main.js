const { Web3 } = await import("web3");
const myweb3 = new Web3("http://localhost:8545");


await callContractMethod(myweb3).then((instance) => {
    console.log("Call ended")
});
// await deployContract(myweb3).then((instance) => {
//     // console.log(instance.options.address)
//     sendFundsToContract(myweb3, instance.options.address)
// });

async function callContractMethod(myweb3) {
    var accounts = await myweb3.eth.getAccounts()
    const balance = await myweb3.eth.getBalance(accounts[0]);
    console.log("Sender balance before withdraw:", myweb3.utils.fromWei(balance, "ether"));

    var contractAbi = [{ "inputs": [{ "internalType": "uint256", "name": "withdraw_amount", "type": "uint256" }], "name": "withdraw", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "stateMutability": "payable", "type": "receive" }];
    var contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
    var FaucetContract = new myweb3.eth.Contract(contractAbi, contractAddress);
    var amountToWithdraw = myweb3.utils.toWei('0.1', 'ether');

    await FaucetContract.methods.withdraw(amountToWithdraw)
        .send({ from: accounts[0] }, function (error, receipt) {
            console.log(receipt);
        });

    const newbalance = await myweb3.eth.getBalance(accounts[0]);
    console.log("Sender balance after withdraw:", myweb3.utils.fromWei(newbalance, "ether"));
}

async function deployContract(myweb3) {
    var contractAbi = [{ "inputs": [{ "internalType": "uint256", "name": "withdraw_amount", "type": "uint256" }], "name": "withdraw", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "stateMutability": "payable", "type": "receive" }];
    var contractBin = '6080604052348015600e575f5ffd5b506101328061001c5f395ff3fe608060405260043610601e575f3560e01c80632e1a7d4d146028576024565b36602457005b5f5ffd5b3480156032575f5ffd5b50604960048036038101906045919060d6565b604b565b005b67016345785d8a0000811115605e575f5ffd5b3373ffffffffffffffffffffffffffffffffffffffff166108fc8290811502906040515f60405180830381858888f1935050505015801560a0573d5f5f3e3d5ffd5b5050565b5f5ffd5b5f819050919050565b60b88160a8565b811460c1575f5ffd5b50565b5f8135905060d08160b1565b92915050565b5f6020828403121560e85760e760a4565b5b5f60f38482850160c4565b9150509291505056fea26469706673582212206dbe1896322fcbcd692f9d444d6801602df3c738fc6bc934d60fee98654076ac64736f6c634300081e0033'
    var faucetContract = new myweb3.eth.Contract(contractAbi);
    var gasPrice = await myweb3.eth.getGasPrice();
    var accounts = await myweb3.eth.getAccounts()

    try {
        // Get gas estimate
        const estimatedGas = await faucetContract.deploy({
            data: '0x' + contractBin
        }).estimateGas({ from: accounts[0] });

        // Add 50% buffer to estimated gas
        // const gasLimit = Math.floor(estimatedGas * 1.5);
        var gasLimit = Number(estimatedGas) * 2;
        // const gasPrice = await myweb3.eth.getGasPrice();
        console.log(`Deploying with gas limit: ${gasLimit}, gas price: ${gasPrice}`);

        // Deploy the contract
        const deployedContract = await faucetContract.deploy({
            data: '0x' + contractBin
        }).send({
            from: accounts[0],
            gas: 5000000,
            gasPrice: gasPrice
        });

        console.log('Contract deployed at:', deployedContract.options.address);
        return deployedContract;

    } catch (error) {
        console.error('Deployment failed:', error);
        throw error;
    }

}

async function sendFundsToContract(myweb3, contractAddress) {
    var contractBalanceBefore = await myweb3.eth.getBalance(contractAddress);
    var accounts = await myweb3.eth.getAccounts()

    console.log("Contract balance before :" + contractBalanceBefore)
    var amountToSend = myweb3.utils.toWei('0.1', 'ether');

    const balance = await myweb3.eth.getBalance(accounts[0]);
    console.log("Sender balance:", myweb3.utils.fromWei(balance, "ether"));

    // Use proper gas parameters
    const gasPrice = await myweb3.eth.getGasPrice();
    const gasLimit = 50000; // Increased from standard 21000 for contract interactions
    try {
        const receipt = await myweb3.eth.sendTransaction({
            from: accounts[0],
            to: contractAddress,
            value: amountToSend,
            gas: gasLimit,
            gasPrice: gasPrice
        });

        console.log("Transaction successful:", receipt.transactionHash);
        var contractBalanceAfter = await myweb3.eth.getBalance(contractAddress);
        console.log("Balance after :" + contractBalanceAfter)
    } catch (error) {
        console.error('Send funds failed:', error);
    }
}

async function deployContract2(myweb3) {
    const contractAbi = [{
        "inputs": [{ "internalType": "uint256", "name": "withdraw_amount", "type": "uint256" }],
        "name": "withdraw",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }, {
        "stateMutability": "payable",
        "type": "receive"
    }];

    const contractBin = '6080604052348015600e575f5ffd5b506101328061001c5f395ff3fe608060405260043610601e575f3560e01c80632e1a7d4d146028576024565b36602457005b5f5ffd5b3480156032575f5ffd5b50604960048036038101906045919060d6565b604b565b005b67016345785d8a0000811115605e575f5ffd5b3373ffffffffffffffffffffffffffffffffffffffff166108fc8290811502906040515f60405180830381858888f1935050505015801560a0573d5f5f3e3d5ffd5b5050565b5f5ffd5b5f819050919050565b60b88160a8565b811460c1575f5ffd5b50565b5f8135905060d08160b1565b92915050565b5f6020828403121560e85760e760a4565b5b5f60f38482850160c4565b9150509291505056fea26469706673582212206dbe1896322fcbcd692f9d444d6801602df3c738fc6bc934d60fee98654076ac64736f6c634300081e0033';

    const accounts = await myweb3.eth.getAccounts();
    const sender = accounts[0];

    try {
        // Use fixed gas parameters (works for local development)
        const gasPrice = await myweb3.eth.getGasPrice();
        const gasLimit = 3000000; // 3 million gas (more than enough)

        console.log(`Deploying with gas limit: ${gasLimit}, gas price: ${gasPrice}`);

        const deployedContract = await new myweb3.eth.Contract(contractAbi)
            .deploy({ data: '0x' + contractBin })
            .send({
                from: sender,
                gas: gasLimit,
                gasPrice: gasPrice
            });

        console.log('Contract successfully deployed at:', deployedContract.options.address);
        return deployedContract;

    } catch (error) {
        console.error('Deployment failed:', error);
        throw error;
    }
}

async function sendFundsToContract2(myweb3, contractAddress) {
    const accounts = await myweb3.eth.getAccounts();
    const sender = accounts[0];

    try {
        // Verify balances first
        const senderBalance = await myweb3.eth.getBalance(sender);
        console.log("Sender balance:", myweb3.utils.fromWei(senderBalance, 'ether'), "ETH");

        const contractBalanceBefore = await myweb3.eth.getBalance(contractAddress);
        console.log("Contract balance before:", myweb3.utils.fromWei(contractBalanceBefore, 'ether'), "ETH");

        const amountToSend = myweb3.utils.toWei('0.1', 'ether');

        // Use proper gas parameters
        const gasPrice = await myweb3.eth.getGasPrice();
        const gasLimit = 50000; // Increased from standard 21000 for contract interactions

        console.log(`Sending 0.1 ETH with gas limit: ${gasLimit}, gas price: ${gasPrice}`);

        const receipt = await myweb3.eth.sendTransaction({
            from: sender,
            to: contractAddress,
            value: amountToSend,
            gas: gasLimit,
            gasPrice: gasPrice
        });

        console.log("Transaction successful:", receipt.transactionHash);

        const contractBalanceAfter = await myweb3.eth.getBalance(contractAddress);
        console.log("Contract balance after:", myweb3.utils.fromWei(contractBalanceAfter, 'ether'), "ETH");

    } catch (error) {
        console.error('Send funds failed:', error);
        throw error;
    }
}