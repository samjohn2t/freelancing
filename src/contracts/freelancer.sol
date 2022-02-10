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

    mapping(uint => Freelancer) freelancers;
    uint freelancerLength = 0;

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address internal mainAddress = 0xb7BF999D966F287Cd6A1541045999aD5f538D3c6;

    function addFreelancer(
        string memory _name,
        string memory _imageUrl,
        string memory _jobDescription,
        uint _amount,
        bool _isHired,
        uint _ratingLength    
    )public{
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                mainAddress,
                1000000000000000000
            ),
            "Transaction could not be performed"
        );
        freelancers[freelancerLength] = Freelancer(
            payable(msg.sender),
            _name,
            _imageUrl,
            _jobDescription,
            _amount,
            _isHired,
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

    function getFreelancerLength() public view returns (uint) {
        return (freelancerLength);
    }
}