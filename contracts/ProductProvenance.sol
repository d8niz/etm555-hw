// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./StateVerification.sol";

/**
 * @title Product Provenance Contract
 * @author SevgicanV, GorkemA, DenizM
 */
contract ProductProvenance is ERC721 {
  //*********************************************************************
  //  CLASS VARIABLES
  //*********************************************************************

  // The owner of the contract
  address public owner;
  // The incremented token id counter

  uint256 counter;
  // The product history ledger, keeping the previous owners
  mapping(uint256 => ProductHistoryElement[]) productHistoryLedger;

  // The product list
  uint256[] products;

  // The stateverification contract address
  address stateVerificationAddress;

  //*********************************************************************
  //  MODIFIERS
  //*********************************************************************

  /**
   * Require message sender is the owner of the contract.
   *
   */
  modifier isOwner() {
    require(msg.sender == owner, "This function is restricted to the contract owner");
    _;
  }

  /**
   * Require message sender is NOT the owner of the contract.
   *
   */
  modifier isNotOwner() {
    require(msg.sender != owner, "This function is restricted to the contract consumers");
    _;
  }

  /**
   * Require message sender is the owner of the token (product).
   *
   */
  modifier isTokenOwner(uint256 tokenId) {
    require(msg.sender == ownerOf(tokenId), "This function is restricted to the token owner");
    _;
  }

  /**
   * Require message sender is whitelisted by the state authority.
   *
   */
  modifier isCallerValidEntity(address _addr) {
    require(
      checkEntityValidity(_addr) == true,
      "The caller entity of this function is NOT whitelisted by the state authority!"
    );
    _;
  }

  /**
   * Require message sender is whitelisted by the state authority.
   *
   */
  modifier isReceiverValidEntity(address _addr) {
    require(
      checkEntityValidity(_addr) == true,
      "The receiver entity of this function is NOT whitelisted by the state authority!"
    );
    _;
  }

  //*********************************************************************
  //  EVENTS
  //*********************************************************************

  event ProductMinted(uint256 tokenId, address ownerAddress, address manufacturerAdress);

  event TransferApproved(uint256 tokenId, address receiverAddress, address ownerAdress);

  event TransferOccured(uint256 tokenId, address receiverAddress, address ownerAdress);

  //*********************************************************************
  //  STRUCTS
  //*********************************************************************

  /**
   * The product history element.
   *
   */
  struct ProductHistoryElement {
    uint256 tokenId; // Token ID
    address transmitter; // Transmitter address
    address receiver; // Receiver address
    uint256 timestamp; // Timestamp of the transaction
    string state; // State of the product i.e. manufactured, transferred, transfer approved..
  }

  //*********************************************************************
  //  CONSTRUCTOR
  //*********************************************************************

  /**
   * The product provenance contract constructor.
   *
   * @param _stateVerificationAddress : Address of StateVerification contract.
   */
  constructor(address _stateVerificationAddress) ERC721("ProductProvenance", "PRDPRV") {
    owner = msg.sender;
    counter = 0;
    stateVerificationAddress = _stateVerificationAddress;
  }

  /**
   * The method let contract users (message sender) to mint a token (a product).
   * The minted token is transferred to consumer's address, by the built-in function.
   *
   * @notice isNotOwner
   * @notice isValidEntity
   *
   */
  function mintProduct() public isNotOwner() isCallerValidEntity(owner) isReceiverValidEntity(msg.sender) {
    uint256 _id = counter;
    _mint(msg.sender, _id);

    // Update product history
    ProductHistoryElement memory el =
      ProductHistoryElement(counter, owner, msg.sender, block.timestamp, "MANUFACTURED");
    productHistoryLedger[counter].push(el);
    products.push(_id);

    // Emit event productMinted
    emit ProductMinted(counter, msg.sender, owner);

    // Increase the token id counter
    counter++;
  }

  /**
   * The method let contract users (message sender) to approve others before transferring
   * a token.
   *
   * @param _addressTo: The address to transfer the product.
   * @param tokenId: The token (product) to be transferred.
   * @notice isNotOwner
   * @notice isValidEntity
   *
   */
  function approveProductTransfer(address _addressTo, uint256 tokenId)
    public
    isTokenOwner(tokenId)
    isCallerValidEntity(msg.sender)
    isReceiverValidEntity(_addressTo)
  {
    approve(_addressTo, tokenId);

    // Update product history
    ProductHistoryElement memory el =
      ProductHistoryElement(tokenId, msg.sender, _addressTo, block.timestamp, "TRANSFER APPROVED");
    productHistoryLedger[tokenId].push(el);

    // Emit event transferApproved
    emit TransferApproved(tokenId, _addressTo, msg.sender);
  }

  /**
   * The method let contract users (message sender) to transfer a product
   * to another address.
   *
   * @param _addressTo: The address to transfer the product.
   * @param tokenId: The token (product) to be transferred.
   * @notice isValidEntity
   *
   */
  function transferProduct(
    address _addressFrom,
    address _addressTo,
    uint256 tokenId
  ) public isCallerValidEntity(_addressFrom) isReceiverValidEntity(_addressTo) {
    transferFrom(_addressFrom, _addressTo, tokenId);

    // Update product history
    ProductHistoryElement memory el =
      ProductHistoryElement(tokenId, msg.sender, _addressTo, block.timestamp, "TRANSFERRED");
    productHistoryLedger[tokenId].push(el);

    // Emit event transferOccured
    emit TransferOccured(tokenId, _addressTo, msg.sender);
  }

  /**
   * The method let contract users (message sender) to trace the history
   * of a product.
   *
   * @param tokenId : The token ID
   * @notice isValidEntity
   *
   */
  function traceTokenHistory(uint256 tokenId)
    public
    view
    isCallerValidEntity(msg.sender)
    returns (ProductHistoryElement[] memory)
  {
    return productHistoryLedger[tokenId];
  }

  /**
   * The method let contract owner (message sender) to list all products.
   *
   * @notice isValidEntity
   * @notice isOwner
   */
  function getProducts() public view isCallerValidEntity(msg.sender) isOwner() returns (uint256[] memory) {
    return products;
  }

  /**
   * The private method to check if an address is whitelisted by state authority.
   *
   * @param _addressToValidate : The address to be whitelisted
   */
  function checkEntityValidity(address _addressToValidate) private view returns (bool) {
    // StateVerification instance
    StateVerification stateVerifier = StateVerification(stateVerificationAddress);

    // If address exists return the verification result, if not catch and  return false.
    try stateVerifier.verify(_addressToValidate) returns (bool) {
      bool isValid = stateVerifier.verify(_addressToValidate);
      return isValid;
    } catch Error(string memory) {
      return (false);
    }
  }
}
