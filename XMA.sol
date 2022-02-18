//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Ownable.sol";
import "./interface/Counters.sol";

contract XMA is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    string public baseExtension = ".json";
    string public baseURI;
    string _initBaseURI = "https://metadata.x-protocol.com/xma/";
    Counters.Counter private currentTokenId;
    mapping(uint256 => string) private _tokenURIs;

    event LockToken(address indexed account, uint256[] tokenId);
    event UnLockToken(address indexed account, uint256[] tokenId);

    constructor() ERC721("X-Metaverse Avatar", "XMA") {
        setBaseURI(_initBaseURI);
        for (uint256 i = 0; i < 31; i++) {
            _mint(msg.sender);
        }
    }

    function _mint(address recipient) public onlyOwner returns (uint256) {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function lock(uint256[] memory tokenIds) public {
        for (uint256 _i = 0; _i < tokenIds.length; _i++) {
            uint256 tokenId = tokenIds[_i];
            require(_checkNftOwner(tokenId) && !nftLock[tokenId]);

            nftLock[tokenId] = true;
        }
        emit LockToken(msg.sender, tokenIds);
    }

    function unlock(uint256[] memory tokenIds) public {
        for (uint256 _i = 0; _i < tokenIds.length; _i++) {
            uint256 tokenId = tokenIds[_i];
            require(_checkNftOwner(tokenId) && nftLock[tokenId]);

            nftLock[tokenId] = false;
        }
        emit UnLockToken(msg.sender, tokenIds);
    }

    function _checkNftOwner(uint256 tokenId) internal view returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return owner == msg.sender;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent NFT"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }
}
