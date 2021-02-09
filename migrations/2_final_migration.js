const ProductProvenance = artifacts.require("ProductProvenance");
const StateVerification = artifacts.require("StateVerification");

module.exports = function (deployer) {
  deployer.deploy(StateVerification).then(function() {
    return deployer.deploy(ProductProvenance, StateVerification.address);
  });
};
