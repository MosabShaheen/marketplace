// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC165.sol';
import './interfaces/IERC721.sol';
import './Libraries/Counters.sol';

/*

building out the minting function:
a. nft to point to an address
b. keep track of the token ids
c. keep track of token owner address to token ids
d. keep track of how many token an owner address has
e. create an event that emits a transfer log - contract address, where it is being minted to, the id

*/

contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;


    // mapping in solidity create a hash table of key pair values

    // Mapping for token id to the owner

    mapping (uint256 => address) private _tokenOwner;

    // Mapping from owner to number of owned tokens
    mapping (address => Counters.Counter) private _OwnedTokensCount;

    // Mapping from token id to approved addresses
    mapping (uint256 => address) private _tokenApprovals;

    constructor() {
        _registerInterface(bytes4(keccak256('balanceOf(bytes4)')^
        keccak256('ownerOf(bytes4)')^
        keccak256('transferFrom(bytes4)')));
    }

        function balanceOf(address _owner) public override view returns(uint256) {
            require(_owner != address(0), 'owner query for non-existant token');
            return _OwnedTokensCount[_owner].current();
        }

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) public override view returns (address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), 'owner query for non-existant token');
        return owner;
    }

    function _exists(uint256 tokenId) internal view returns(bool){
        // setting the address of nft owner to check the mapping
        // of the address from tokenOwner at the tokenId
        address owner = _tokenOwner[tokenId];
        // return the trutheness the address is not zero
        return owner != address(0);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        // requires that address isn't zero
        require(to != address(0), 'ERC721: minting to the zero addres');
        // requires that token does not already exist
        require(!_exists(tokenId), 'ERC721: token already minted');
        // we are adding new address with a new token id for minting
        _tokenOwner[tokenId] = to;
        // keeping track of each address that is minting and adding one to the count
        _OwnedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    /// @notice Transfer ownership of an NFT 
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(_to != address(0), 'Error! ERC721 Transfer to the zero address');
        require(ownerOf(_tokenId) == _from, 'Trying to transfer a token the address does not own!');

        _OwnedTokensCount[_from].decrement();
        _OwnedTokensCount[_to].increment();

        _tokenOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) override public {
        _transferFrom(_from, _to, _tokenId);
    }
    // 1. require that the preson approving is the owner
    // 2. we are approving an address to a token (tokenId)
    // 3. require that we cant approve sending tokens of the owner to the owner (current caller)
    // 4. update the map of the approval addresses 

    function approve(address _to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(_to != owner, 'Error - approval to current owner');
        require(msg.sender == owner, 'Current caller is not the owner of the token');
        _tokenApprovals[tokenId] = _to;
        emit Approval(owner, _to, tokenId);
    } 
}