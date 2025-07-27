//Written according to https://eips.ethereum.org/EIPS/eip-20
//Fabian Vogelsteller <fabian@ethereum.org>, Vitalik Buterin <vitalik.buterin@ethereum.org>, "ERC-20: Token Standard," Ethereum Improvement Proposals, no. 20, November 2015. [Online serial]. Available: https://eips.ethereum.org/EIPS/eip-20.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MadenToken {
    string constant _name = "Maden Token";
    string constant _symbol = "MATO";
    uint8 constant _decimals = 18;
    uint256 constant _totalSupply = 2000000 * 10 ** uint256(_decimals);

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _account, address indexed _spender, uint256 _value);

    address public owner;
    address public dev;   //Developer address for development.
    address public tax;   //Tax address for the ecosystem.

    uint8 public taxRate = 1;

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = _totalSupply; //send all tokens to owner account
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function name() public pure returns (string memory){
        return _name;
    }

    function symbol() public pure returns (string memory){
        return _symbol;
    }

    function decimals() public pure  returns (uint8){
        return _decimals;
    }

    function totalSupply() public pure returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _account) public view returns (uint256){
        return balances[_account];
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(_to != address(0), "Cannot transfer to zero address");
        require(balances[msg.sender] >= _value, "Insufficient balance" );
        require(tax != address(0), "Tax address not set");

        uint256 taxAmount = (_value * taxRate) / 100;
        uint256 sendAmount = _value - taxAmount;

        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + sendAmount;
        balances[tax] = balances[tax] + taxAmount;

        emit Transfer(msg.sender, _to, sendAmount);
        emit Transfer(msg.sender, tax, taxAmount);

        return true;
    }    

    //
    function approve(address _spender, uint256 _value) public returns (bool success){
        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //this function  is to check the allowance. Dex and scan sites can use this function.
    function allowance(address _account, address _spender) public view returns (uint256 remaining){
        return allowances[_account][_spender];
    }

    //this function is for third party usage. Dexes and wallets can use this function to transfer approved amount.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowances[_from][msg.sender] >= _value, "Allowance exceeded");
        require(tax != address(0), "Tax address not set");

        uint256 taxAmount = (_value * taxRate) / 100;
        uint256 sendAmount = _value - taxAmount;

        balances[_from] = balances[_from] - _value;
        balances[_to]= balances[_to] + sendAmount;
        balances[tax] = balances[tax] + taxAmount;
        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _value;

        emit Transfer(_from, _to, sendAmount);
        emit Transfer(_from, tax, taxAmount);
        return true;
    }

    //Below codes not related with erc 20. it is related with our token.
    //Set taxrate!!! max tax can be up to 10 percent. 
    function setTaxRate(uint8 _taxRate) public onlyOwner {
        require(_taxRate <= 10, "You can not set tax rate bigger than 10. DAO will not like it.");
        require(_taxRate >= 1, "you need to get tax, otherwise Maden Token will die.");
        taxRate = _taxRate;
    }

    function setTaxAddress(address _newTaxAddress) public onlyOwner{
        require(_newTaxAddress != address(0), "Tax address not set");
        tax = _newTaxAddress;
    }
}
