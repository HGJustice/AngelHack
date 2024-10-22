// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import './DecentralisedID.sol';

contract Marketplace {
  uint256 constant Fee = 0.0001 ether;

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
    owner = msg.sender;
  }

  error NO_ID_CREATED();
  error CONSULTANT_DOESNT_EXISIT();
  error CONSULUTED_ALREADY_CREATED();
  error INVALID_AMOUNT();
  error NOT_OWNER_OF_PROFILE();
  error NOT_OWNER_OF_MARKETPLACE();
  error CONSULTANT_UNAVAILABLE();
  error INVALID_CONSULTANT_ID();
  error PAYMENT_TO_CONSULTANT_FAILED();
  error PAYMENT_TO_OWNER_FAILED();

  event ConsultantCreated();
  event ConsultantPaid();
  event AviabilityChanged();
  event MonthlyRateChanged();

  mapping(address => Consultant) consultantsToAddress;
  mapping(uint64 => Consultant) consultantsToID;
  uint64 current_consultant_id = 1;
  address owner;

  function createConsultant(
    string calldata _fullName,
    string calldata _description,
    uint32 _monthly_rate
  ) external {
    DecentralisedID.ID memory currentUser = IDContract.getDID(msg.sender);
    if (currentUser.user_address == address(0)) {
      revert NO_ID_CREATED();
    }
    if (consultantsToAddress[msg.sender].user_addy != address(0)) {
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

    consultantsToAddress[msg.sender] = newConsultant;
    consultantsToID[current_consultant_id] = newConsultant;
    emit ConsultantCreated();
    current_consultant_id++;
  }

  function getConsultant(
    address _userAddy
  ) external view returns (Consultant memory) {
    return consultantsToAddress[_userAddy];
  }

  function toggleAviability() external {
    Consultant storage current = consultantsToAddress[msg.sender];
    if (msg.sender != current.user_addy) {
      revert NOT_OWNER_OF_PROFILE();
    }
    if (current.available == false) {
      current.available = true;
    } else {
      current.available = false;
    }

    emit AviabilityChanged();
  }

  function changeRate(uint32 _newRate) external {
    Consultant storage current = consultantsToAddress[msg.sender];
    if (current.user_addy != msg.sender) {
      revert NOT_OWNER_OF_PROFILE();
    }

    current.monthly_rate = _newRate;
    emit MonthlyRateChanged();
  }

  function payConsultant(uint64 _chosenConsultant) external payable {
    if (_chosenConsultant > current_consultant_id) {
      revert INVALID_CONSULTANT_ID();
    }
    Consultant memory current = consultantsToID[_chosenConsultant];
    if (current.user_addy == address(0)) {
      revert CONSULTANT_DOESNT_EXISIT();
    }
    if (current.available == false) {
      revert CONSULTANT_UNAVAILABLE();
    }
    if (msg.value < current.monthly_rate) {
      revert INVALID_AMOUNT();
    }

    uint256 amountToUser = msg.value - Fee;
    (bool sent, ) = payable(current.user_addy).call{ value: amountToUser }('');
    if (!sent) {
      revert PAYMENT_TO_CONSULTANT_FAILED();
    }
  }

  function withdrawFees() external {
    if (owner != msg.sender) {
      revert NOT_OWNER_OF_MARKETPLACE();
    }
    (bool sent, ) = payable(owner).call{ value: address(this).balance }('');
    if (!sent) {
      revert PAYMENT_TO_OWNER_FAILED();
    }
  }
}
