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
    uint64 id;
    string userNAme;
    string first_name;
    string last_name;
    string date_of_birth;
    string document_number;
    string nationality;
    address user_address;
    membership_type stage;
  }

  error ID_ALREADY_CREATED();
  error ID_DOESNT_EXIST();
  error ALREADY_GOT_MEMBERSHIP_TYPE();
  error INVALID_AMOUNT();

  event IDCreated(uint64 id, string userName, address userAddy);
  event MembershipAdded(
    uint64 id,
    string userName,
    address userAddy,
    membership_type stage
  );

  mapping(address => ID) ids;
  uint64 current_id_number = 1;

  function createDID(
    string calldata _userName,
    string calldata _firstName,
    string calldata _lastName,
    string calldata _dob,
    string calldata _documentNumber,
    string calldata _nationality
  ) external {
    if (ids[msg.sender].user_address != address(0)) {
      revert ID_ALREADY_CREATED();
    }

    ID memory newID = ID(
      current_id_number,
      _userName,
      _firstName,
      _lastName,
      _dob,
      _documentNumber,
      _nationality,
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
    ID storage currentUser = ids[msg.sender];

    if (currentUser.user_address == address(0)) {
      revert ID_DOESNT_EXIST();
    }
    if (currentUser.stage == new_membership) {
      revert ALREADY_GOT_MEMBERSHIP_TYPE();
    }

    uint16 requiredPrice;

    if (new_membership == membership_type.Gold) {
      requiredPrice = Gold_Price;
    } else if (new_membership == membership_type.Silver) {
      requiredPrice = Silver_Price;
    }

    if (msg.value < requiredPrice) {
      revert INVALID_AMOUNT();
    }

    currentUser.stage = new_membership;
    emit MembershipAdded(
      currentUser.id,
      currentUser.userNAme,
      msg.sender,
      new_membership
    );
  }
}
