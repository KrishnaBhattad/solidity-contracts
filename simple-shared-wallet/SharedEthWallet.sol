// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";


contract Allowance is Ownable {

    event AllowanceUpdate(address indexed _forWho, address indexed _byWhom, uint _oldAmount, uint _updatedAmount);

    using SafeMath for uint256;

    mapping (address => uint256) public allowance;

    modifier ownerOrAllowed(uint256 _amount) {
        require(owner() == msg.sender || allowance[msg.sender] >= _amount, "You are not allowed to transact..");
        _;
    }
    function addAllowance(address _address, uint256 _amount) public onlyOwner {
        emit AllowanceUpdate(_address, msg.sender, allowance[_address], _amount);
        allowance[_address] = _amount;
    }

    function reduceAllowance(address _address, uint256 _amount) internal {
        emit AllowanceUpdate(_address, msg.sender, allowance[_address], allowance[_address].sub(_amount));
        allowance[_address] = allowance[_address].sub(_amount);
    }

}

contract SharedEthWallet is Allowance {

    event MoneySent(address indexed _benificiary, uint _amount);
    event MoneyReceived(address indexed _to, uint _amount);

    receive() payable external {
        emit MoneyReceived(msg.sender, msg.value);
    }

    function getBalanceOfAddress(address _address) public view returns(uint256) {
        return _address.balance;
    }

    function withdrawAmount(address payable _to, uint256 _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "Not enough funds stored in smart contract");
        if (owner() != msg.sender) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }

    function renounceOwnership() public virtual override {
        revert("This is not allowed currently..");
    }
}