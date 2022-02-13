// SPDX-License-Identifier: MIT  

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Freelance{

    struct Freelancer{
        address payable owner;
        string name;
        string imageURL;
        string jobDescription;
        uint amount;
        bool isHired;
        uint ratings;
        uint ratingLength;
        uint averageRating;
    }

    // new Message struct
    struct Message {
        address sender;
        string text;
        uint256 timestamp;
    }

    mapping(uint => Freelancer) freelancers;
    mapping(address => mapping(uint256 => Message)) internal messages;

    uint freelancerLength = 0;

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    // changed the mainAddress to owner and added fee unit variable
    address internal owner;
    uint internal fee;
    // addresses and messageAmounts mapping
    mapping(address => address) internal addresses;
    mapping(address => uint256) internal messageAmounts;

    // creating a constructor to handle the owner and fee
    constructor(uint _fee){
        owner = msg.sender;
        fee = _fee;
    }

    // returns a boolean that says if the address has a recipient / is assigned
    function isAddressAssigned() public view returns (bool) {
        return addresses[msg.sender] != address(0);
    }

    // returns assigned address
    function getAssignedAddress() public view returns (address) {
        return addresses[msg.sender];
    }

    // writes a message to someone
    function writeMessage(string memory _text) public {
        if (isAddressAssigned()) {
            address destination = addresses[msg.sender];
            messages[destination][messageAmounts[destination]++] = Message(
                msg.sender,
                _text,
                block.timestamp
            );
        }
    }

        // transfers funds and sends a confirmation message to someone
    function transferFunds(uint256 _amount) public payable {
        if (isAddressAssigned()) {
            require(
                IERC20Token(cUsdTokenAddress).transferFrom(
                    msg.sender,
                    addresses[msg.sender],
                    _amount
                ),
                "Transfer failed."
            );
            writeMessage(string(abi.encodePacked("cUSD--", uint2str(_amount))));
        }
    }

    // gets the length of the received message mapping of an adress
    function getReceivedMessageCount() public view returns (uint256) {
        return (messageAmounts[msg.sender]);
    }

    // gets the length of the sent message mapping of an adress
    function getSentMessageCount() public view returns (uint256) {
        return (messageAmounts[addresses[msg.sender]]);
    }

    // gets a received message based on index
    function getReceivedMessage(uint256 _index)
        public
        view
        returns (string memory, uint256)
    {
        return (
            messages[msg.sender][_index].text,
            messages[msg.sender][_index].timestamp
        );
    }

    // gets a sent message based on index
    function getSentMessage(uint256 _index)
        public
        view
        returns (string memory, uint256)
    {
        return (
            messages[addresses[msg.sender]][_index].text,
            messages[addresses[msg.sender]][_index].timestamp
        );
    }

    function addFreelancer(
        string memory _name,
        string memory _imageUrl,
        string memory _jobDescription,
        uint _amount,
        // removed the _isHired bool init
        uint _ratingLength    
    )public{
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                owner,
                fee
            ),
            "Transaction could not be performed"
        );
        freelancers[freelancerLength] = Freelancer(
            payable(msg.sender),
            _name,
            _imageUrl,
            _jobDescription,
            _amount,
            false, // changes _isHired to a boolean false default value
            0,
            _ratingLength,
            0
        );
        freelancerLength++;       
    }

    function getFreelancer(uint _index)public view returns(
        address payable,
        string memory,
        string memory,
        string memory,
        uint,
        bool,
        uint,
        uint,
        uint
    ){
        Freelancer storage freelancer = freelancers[_index];
        return(
            freelancer.owner,
            freelancer.name,
            freelancer.imageURL,
            freelancer.jobDescription,
            freelancer.amount,
            freelancer.isHired,
            freelancer.ratings,
            freelancer.ratingLength,
            freelancer.averageRating
        );
    }

    function rateFreelancer(uint _index, uint rating) public{
        require((_index <= 5 && _index >= 0), "Must not be greater than 5 and not less than 0");
        freelancers[_index].ratings = (freelancers[_index].ratings + rating) ;
        freelancers[_index].averageRating = freelancers[_index].ratings / (freelancers[_index].ratingLength);
        freelancers[_index].ratingLength++;
    }

    function hireFreelancer(uint _index)public{
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                freelancers[_index].owner,
                freelancers[_index].amount
            ),
            "Transaction could not be performed"
        );
        freelancers[_index].isHired = true;
    }

    // function to update the fee value
    function updateFee(uint _fee) public{
        require(msg.sender == owner, "Only owner can call this function");
        fee = _fee;
    }

    function getFreelancerLength() public view returns (uint) {
        return (freelancerLength);
    }

    // converts a number into a string
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
