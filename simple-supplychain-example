// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.11;

contract Ownable {

    address public _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(isOwner(), "You are not owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }
}

contract Item {

    uint public priceInWei;
    uint public pricePaid;
    uint public index;

    ItemManager parentContract;

    constructor(ItemManager _parentContract, uint _priceInWei, uint _index) {
        priceInWei = _priceInWei;
        index =_index;
        parentContract= _parentContract;
    }

    receive() external payable {
        require(pricePaid == 0, "Already paid for the product");
        require(priceInWei == msg.value, "Please send exact price of product");
        pricePaid += msg.value;
        (bool success, ) = address(parentContract).call{value: msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "Transaction wasn't successful, cancelling");
    }
    
    fallback() external {}
}

contract ItemManager is Ownable{

    enum ItemState{Created, Paid, Delivered}

    struct S_Item {
        Item _item;
        string _identifier;
        uint _price;
        ItemManager.ItemState _state;
    }

    uint itemIndex;

    mapping (uint => S_Item) public items;
    event SupplyChainStep(uint _itemIndex, uint _step, address _address);

    function createItem(string memory _identifier, uint _itemPrice) public onlyOwner {
        Item item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex]._item = item;
        items[itemIndex]._identifier = _identifier;
        items[itemIndex]._price = _itemPrice;
        items[itemIndex]._state = ItemState.Created;
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state), address(item));
        itemIndex++;
    }

    function triggerPayment(uint _itemIndex) public payable {
        require(items[_itemIndex]._price == msg.value, "Only full payment is accepted");
        require(items[_itemIndex]._state == ItemState.Created, "Payment for items in created state are accepted");
        items[_itemIndex]._state = ItemState.Paid;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }

    function triggerDelivery(uint _itemIndex) public onlyOwner {
        require(items[_itemIndex]._state == ItemState.Paid, "Item is further in the chain");
        items[_itemIndex]._state = ItemState.Delivered;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }
}
