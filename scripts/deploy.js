const deploy = async () => {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying the account: ", deployer.address);

  const PlatziPunks = await ethers.getContractFactory("PlatziPunks");
  const deployed = await PlatziPunks.deploy(1000);

  console.log("Deployed contract: ", deployed.address);
};

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
