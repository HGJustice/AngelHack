// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract DecentralisedID {
  uint16 constant Gold_Price = 10;
  uint16 constant Silver_Price = 5;

  enum membership_type {
    Gold,
    Silver,
    Bronze
  }

  struct ID {
    uint64 number_ID;
    string userNAme;
    string picture_link;
    string first_name;
    string last_name;
    string date_of_birth;
    string passport_number;
    address user_address;
    membership_type stage;
  }

  error ID_ALREADY_CREATED();
  error ID_DOESNT_EXIST();
  error ALREADY_GOT_MEMBERSHIP_TYPE();

  event IDCreated(uint64 id, string userName, address userAddy);
  event MembershipAdded();

  mapping(address => ID) ids;
  uint64 current_id_number = 1;

  function createDID(
    string calldata _userName,
    string calldata _pictureLink,
    string calldata _firstName,
    string calldata _lastName,
    string calldata _dob,
    string calldata _passportNumber
  ) external {
    if (ids[msg.sender].user_address != address(0)) {
      revert ID_ALREADY_CREATED();
    }

    ID memory newID = ID(
      current_id_number,
      _userName,
      _pictureLink,
      _firstName,
      _lastName,
      _dob,
      _passportNumber,
      msg.sender,
      membership_type.Bronze
    );

    ids[msg.sender] = newID;
    emit IDCreated(current_id_number, _userName, msg.sender);
    current_id_number++;
  }

  function getDID(address userAddy) external view returns (ID memory) {
    return ids[userAddy];
  }

  function buyMemebership(membership_type new_membership) external payable {
    ID memory currentUser = ids[msg.sender];

    if (currentUser.user_address == address(0)) {
      revert ID_DOESNT_EXIST();
    }
    if (currentUser.stage == new_membership) {
      revert ALREADY_GOT_MEMBERSHIP_TYPE();
    }
    currentUser.stage = new_membership;
    emit MembershipAdded();
  }
}
