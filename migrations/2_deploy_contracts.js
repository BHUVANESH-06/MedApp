const MedicalRecord = artifacts.require("MedicalRecord");

module.exports = async function (deployer) {
  console.log("Starting deployment...");
  await deployer.deploy(MedicalRecord);
  console.log("MedicalRecord deployed at:", MedicalRecord.address);
};
