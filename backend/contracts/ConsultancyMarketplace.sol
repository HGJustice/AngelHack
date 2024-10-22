// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import './DecentralisedID.sol';

contract Marketplace {
  DecentralisedID private IDContract;

  struct Consultant {
    uint64 id;
    string full_name;
    string description;
    address user_addy;
    uint32 monthly_rate;
    bool available;
  }

  constructor(address _IDAddy) {
    IDContract = DecentralisedID(_IDAddy);
  }

  error NO_ID_CREATED();
  error CONSULUTED_ALREADY_CREATED();
  error INVALID_AMOUNT();
  error NOT_OWNER();

  event ConsultantCreated();
  event ConsutlantPaid();

  mapping(address => Consultant) consultants;
  uint64 current_consultant_id = 1;

  function createConsultant(
    string calldata _fullName,
    string calldata _description,
    uint32 _monthly_rate
  ) external {
    DecentralisedID.ID memory currentUser = IDContract.getDID(msg.sender);
    if (currentUser.user_address == address(0)) {
      revert NO_ID_CREATED();
    }
    if (consultants[msg.sender].user_addy != address(0)) {
      revert CONSULUTED_ALREADY_CREATED();
    }

    Consultant memory newConsultant = Consultant(
      current_consultant_id,
      _fullName,
      _description,
      msg.sender,
      _monthly_rate,
      true
    );

    consultants[msg.sender] = newConsultant;
    emit ConsultantCreated();
    current_consultant_id++;
  }

  function getConsultant(
    address _userAddy
  ) external view returns (Consultant memory) {
    return consultants[_userAddy];
  }

  function deactiviateConsultant() external {}

  function payConsultant() external payable {}
}
