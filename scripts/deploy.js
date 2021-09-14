// Deploying the contract on the local blockchain
async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account: ", deployer.address);
    console.log("Account balance: ", (await deployer.getBalance()).toString());

    const spellContractFactory = await hre.ethers.getContractFactory("CastSpellPortal");
    const spellContract = await spellContractFactory.deploy({value: hre.ethers.utils.parseEther("0.1")});
    await spellContract.deployed();

    console.log("CastSpellPortal address: ", spellContract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });