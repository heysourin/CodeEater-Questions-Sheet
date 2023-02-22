// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    struct Item {
        uint256 id;
        string name;
        uint256 quantity;
        address payable supplier;
        address payable buyer;
        uint256 price;
        bool isDelivered;
        bool isPaid;
    }

    struct Receivable {
        address payable supplier;
        address buyer;
        uint256 amount;
        bool financed;
    }

    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    mapping(uint256 => Receivable) public receivables;
    uint256 public numReceivables;

    event ItemAdded(
        uint256 id,
        string name,
        uint256 quantity,
        address supplier,
        uint256 price
    );
    event ItemDelivered(uint256 id);
    event ItemPaid(uint256 id);
    event ReceivableFinanced(uint256 indexed id, address indexed funder);

    function addItem(
        string memory _name,
        uint256 _quantity,
        uint256 _price
    ) public returns (uint256) {
        itemCount++;
        items[itemCount] = Item(
            itemCount,
            _name,
            _quantity,
            payable(msg.sender),
            payable(address(0)),
            _price,
            false,
            false
        );
        emit ItemAdded(itemCount, _name, _quantity, msg.sender, _price);
        return itemCount;
    }

    function deliverItem(uint256 _id) public {
        require(
            items[_id].supplier == msg.sender,
            "Only supplier can deliver item"
        );
        require(!items[_id].isDelivered, "Item already delivered");
        items[_id].isDelivered = true;
        emit ItemDelivered(_id);
    }

    function payForItem(uint256 _id) public payable {
        require(items[_id].buyer == msg.sender, "Only buyer can pay for item");
        require(items[_id].isDelivered, "Item not delivered yet");
        require(!items[_id].isPaid, "Item already paid for");
        require(msg.value >= items[_id].price, "Insufficient payment");
        items[_id].isPaid = true;
        items[_id].supplier.transfer(msg.value);

        emit ItemPaid(_id);
    }

    function getItem(uint256 _id)
        public
        view
        returns (
            string memory name,
            uint256 quantity,
            address supplier,
            address buyer,
            uint256 price,
            bool isDelivered,
            bool isPaid
        )
    {
        Item storage item = items[_id];
        return (
            item.name,
            item.quantity,
            item.supplier,
            item.buyer,
            item.price,
            item.isDelivered,
            item.isPaid
        );
    }

    function createReceivable(
        address _supplier,
        address _buyer,
        uint256 _amount
    ) public {
        require(_supplier != address(0), "Invalid supplier address");
        require(_buyer != address(0), "Invalid buyer address");
        require(_amount > 0, "Invalid receivable amount");

        receivables[numReceivables] = Receivable(
            payable(_supplier),
            _buyer,
            _amount,
            false
        );
        numReceivables++;
    }

    function financeReceivable(uint256 _id) public payable {
        require(_id < numReceivables, "Invalid receivable ID");
        require(
            msg.value == receivables[_id].amount,
            "Incorrect financing amount"
        );
        require(
            receivables[_id].financed == false,
            "Receivable has already been financed"
        );

        receivables[_id].financed = true;
        emit ReceivableFinanced(_id, msg.sender);

        receivables[_id].supplier.transfer(msg.value);
    }
}
/*       Receivables refer to the money owed to a company by its customers for goods or services that have been delivered but 
       not yet paid for. In the context of supply chain financing, the supplier can use their receivables as collateral to 
       obtain financing from a financial institution or a third-party investor. The financing is provided based on the value 
       of the receivables, and the supplier is required to pay back the financing along with interest and any applicable fees.
*/
