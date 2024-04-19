// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Web3Builders is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 maxSupply =1;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    mapping(address => bool)public allowList;

    constructor(address initialOwner)
        ERC721("Web3Builders", "WE3")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner {
    publicMintOpen = _publicMintOpen;
    allowListMintOpen = _allowListMintOpen;

}

  function internalMint() internal {
         require(totalSupply() < maxSupply, "We Sold Out");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }


    // Add public Mnt and AllowListMintOpen Variables
    function allowListMint() public payable {
        require(allowListMintOpen, "AllowList Mint Closed");
        require(allowList[msg.sender], "You are not on the Allow List");
        require(msg.value == 0.001 ether, 'not enough ETH');
        internalMint();
    }

    function publicMint() public payable {
        require(publicMintOpen, "public mint is closed");
        require(msg.value == 0.01 ether, 'not enough ETH');
        internalMint();
    }

    //get the balance of the contract
    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);

    }

    // populate the Allow List
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i <addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}