// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract DID {
  struct ID {
    uint64 number_ID;
    string picture_link;
    string first_name;
    string last_name;
    string DOB;
    string passport_number;
    address user_address;
  }

  error ID_ALREADY_CREATED();

  mapping(address => DID) ids;
  uint64 current_id_number = 1;

  function createDID(
    string calldata _pictureLink,
    string calldata firstName,
    string calldata lastName,
    string calldata _dob,
    string calldata passportNumber
  ) external {
    if (ids[msg.sender].user_address != address(0)) {
      revert ID_ALREADY_CREATED();
    }
  }
}
