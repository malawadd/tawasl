const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const TawaslNFT = await hre.ethers.getContractFactory("TawaslNFT");
  const tawaslNFT = await TawaslNFT.deploy(0);

  await tawaslNFT.deployed();

  console.log("tawaslNFT deployed to:", tawaslNFT.address);

  fs.writeFileSync(
    "././tawaslNFT.js", `
    export const tawaslNFT = "${tawaslNFT.address}"`
  )

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run --network {{ $themeConfig.project.rpc_url_testnet }}  scripts/deploy.js