/*//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract PaymentChannel{
    address payable public sender;
    address payable public recipient;
    uint256 public expiration;

    constructor (address payable _recipient, uint256 duration) payable{
        sender = payable(msg.sender);
        recipient = _recipient;
        expiration = block.timestamp + duration;
    }

    function close(uint256 amount, bytes memory signature) public{
        require(msg.sender == recipient);
        require(isValidSignature(amount, signature));
        
        recipient.transfer(amount);
        selfdestruct(sender);
    }

   function extend(uint256 newExpiration) public view{
       require(msg.sender == recipient);
       require(newExpiration > expiration);
   }
    function claimTimeout() public {
        require(block.timestamp >= expiration);
        selfdestruct(sender);
    }

    function isValidSignature(uint256 amount, bytes memory signature)
    internal 
    view
    returns(bool) {
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));

        return recoverSigner(message, signature) == sender;
    }

    function splitSignature(bytes memory sig)
    internal 
    pure
    returns(uint8 v, bytes32 r, bytes32 s){
        require(sig.length == 65);
        
        assembly{
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := mload(add(sig, 96))
        }
        return(v, r, s);
    }
    function recoverSigner(bytes32 message, bytes memory sig)
    internal 
    pure 
    returns(address){
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    } 

    function prefixed(bytes32 hash) internal pure returns(bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum signed Message:\n32", hash));
    }
}*/