async function main() {
    const [owner, randoPerson] = await hre.ethers.getSigners();

    // Compiles and generates files necessary for contract to work under artifacts directory
    const spellContractFactory = await hre.ethers.getContractFactory("CastSpellPortal");

    // Hardhat creates a local ETH network for this contract only. After the script completes, it destroys
    // the network. A fresh blockchain each time this is run.
    const spellContract = await spellContractFactory.deploy({ value: hre.ethers.utils.parseEther("0.1")});

    // Waits until the contract is deployed to the local blockchain.
    await spellContract.deployed();

    // Shows the address of the deployed contract
    console.log("Contract deployed to: ", spellContract.address);
    console.log("Contract deployed by: ", owner.address);

    let contractBalance = await hre.ethers.provider.getBalance(spellContract.address);
    console.log("Contract balance: ", hre.ethers.utils.formatEther(contractBalance));

    // Manually calling our functions
    let spellCount;
    spellCount = await spellContract.getTotalSpells();

    let spellTxn = await spellContract.getSpell(owner.address, "msg");
    await spellTxn.wait();

    spellCount = await spellContract.getTotalSpells();
    console.log(spellCount.toNumber());
    spellTxn = await spellContract.connect(randoPerson).getSpell(randoPerson.address, "msg");
    await spellTxn.wait();

    spellCount = await spellContract.getTotalSpells();
    console.log(spellCount.toNumber());

    contractBalance = await hre.ethers.provider.getBalance(spellContract.address);
    console.log("Contract balance: ", hre.ethers.utils.formatEther(contractBalance));

    let allSpellsCast = await spellContract.getAllSpellsCast();
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });