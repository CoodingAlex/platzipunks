const { expect } = require("chai");

describe("PlatziPlunks Contract", () => {
  const setup = async ({ maxSupply = 1000 }) => {
    const [owner] = await ethers.getSigners();
    const PlatziPunks = await ethers.getContractFactory("PlatziPunks");
    const deployed = await PlatziPunks.deploy(maxSupply);
    return {
      deployed,
      owner,
    };
  };
  const maxSupply = 4000;
  describe("Deployment", () => {
    it("Sets max supply to passed param", async () => {
      const { deployed } = await setup({ maxSupply });
      const returnedMaxSupply = await deployed.maxSupply();
      expect(maxSupply).to.equal(returnedMaxSupply);
    });
  });

  describe("Minting", () => {
    it("Mints tokens to the owner", async () => {
      const { deployed, owner } = await setup({ maxSupply });

      await deployed.mint();
      const ownerOfMinted = await deployed.ownerOf(0);
      expect(ownerOfMinted).to.equal(owner.address);
    });

    it("Has a minting limit", async () => {
      const { deployed, owner } = await setup({ maxSupply: 2 });

      await deployed.mint();
      await deployed.mint();

      await expect(deployed.mint()).to.be.revertedWith("No PlatziPunks left");
    });
  });

  describe("Token URI", () => {
    it("Returns the correct token URI", async () => {
      const { deployed } = await setup({ maxSupply });
      await deployed.mint();
      const tokenURI = await deployed.tokenURI(0);
      const stringifiedTokenURI = await tokenURI.toString();

      const [, base64JSON] = stringifiedTokenURI.split(
        "data:application/json;base64."
      );
      const stringifiedMetadata = await Buffer.from(
        base64JSON,
        "base64"
      ).toString("ascii");

      const metadata = JSON.parse(stringifiedMetadata);
      expect(metadata).to.have.all.keys(
        "name",
        "description",
        "image"
      );
    });
  });
});
