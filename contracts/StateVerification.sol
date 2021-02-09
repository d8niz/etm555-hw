// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

/**
 * @title State Verification Contract
 * @author SevgicanV, GorkemA, DenizM
 */
contract StateVerification {
  // A list of verified entity addresses.
  mapping(address => bool) public verifiedEntityAdressList;

  // The address of the owner of the contract.
  address owner;

  // Modifiers

  modifier isOwner() {
    require(msg.sender == owner, "This function is restricted to the contract owner");
    _;
  }

  constructor() {
    owner = msg.sender;
  }

  /**
   * The method verifies a given address.
   *
   * @param _address : Address to be verified
   * @return bool : True if is verified, false otherwise
   */
  function verify(address _address) public view returns (bool) {
    return (verifiedEntityAdressList[_address]);
  }

  /**
   * The method inserts an adress to the verified entity list.
   *
   * @param _address: Address to be inserted
   */
  function insertVerifiedEntity(address _address) public isOwner() {
    verifiedEntityAdressList[_address] = true;
  }

  /**
   * The method inserts an adress to the verified entity list.
   *
   * @param _address: Address to be inserted
   */
  function removeVerifiedEntity(address _address) public isOwner() {
    verifiedEntityAdressList[_address] = false;
  }
}
