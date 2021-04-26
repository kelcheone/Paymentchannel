//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract ReceiverPays {
    address owner = msg.sender;

    mapping(uint256 => bool) usedNonces;
    constructor() payable{}

    function claimPayment(uint256 amount, uint256 nonce, bytes memory signature) 
    public{
        require(!usedNonces[nonce]);
        usedNonces[nonce] = true;
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));
        require(recoverSigner(message, signature) == owner);
        payable( msg.sender).transfer(amount);    
    }

    function shutdown () public{
        require(msg.sender == owner);
        selfdestruct(payable(msg.sender));
    }

    function splitSignature(bytes memory sig) internal pure returns(uint8 v, bytes32 r, bytes32 s ){
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := mload(add(sig, 96))
        }
        return (v,r,s);
    }
    function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns(address){
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }
    function prefixed(bytes32 hash) internal pure returns (bytes32){
        return keccak256(abi.encodePacked("x19Ethereum Signed Message:\n32", hash));
    }
    
}