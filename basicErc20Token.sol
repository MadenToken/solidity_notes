//Written according to https://eips.ethereum.org/EIPS/eip-20
//Fabian Vogelsteller <fabian@ethereum.org>, Vitalik Buterin <vitalik.buterin@ethereum.org>, "ERC-20: Token Standard," Ethereum Improvement Proposals, no. 20, November 2015. [Online serial]. Available: https://eips.ethereum.org/EIPS/eip-20.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DenemeToken {
    string constant _name = "Maden Token";
    string constant _symbol = "MATO";
    uint8 constant _decimals = 18;
    uint256 constant _totalSupply = 2000000 * 10 ** uint256(_decimals);

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _account, address indexed _spender, uint256 _value);

    constructor() {
        balances[msg.sender] = _totalSupply; //send all tokens to owner account
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
        require(balances[msg.sender] >= _value, "Insufficient balance" );
        
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }    

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
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowances[_from][msg.sender] >= _value, "Allowance exceeded");

        balances[_from] = balances[_from] - _value;
        balances[_to]= balances[_to] + _value;
        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _value;

        emit Transfer(_from, _to, _value);
        return true;
    }
}
