// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Base64.sol";
import "./PlatziPunksDNA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PlatziPunks is ERC721, ERC721Enumerable, PlatziPunksDNA {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _idCounter;
    uint256 public maxSupply;
    mapping(uint256 => uint256) public tokenDNA;

    constructor(uint256 _maxSupply) ERC721("PlatziPunks", "PLZPK") {
        maxSupply = _maxSupply;
    }

    function mint() public {
        uint256 current = _idCounter.current();
        require(current < maxSupply, "No PlatziPunks left");
        _safeMint(msg.sender, current);
        tokenDNA[current] = deterministicPseudoRandomDNA(current, msg.sender);
        _idCounter.increment();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://avataaars.io/";
    }

    function imageByDNA(uint256 _dna) public view returns (string memory) {
        string memory baseURI = _baseURI();
        string memory paramsURI = _paramsURI(_dna);

        return string(abi.encodePacked(baseURI, paramsURI));
    }

    function _paramsURI(uint256 _dna) internal view returns (string memory) {
        string memory params;
        {
            params = string(
                abi.encodePacked(
                    "accessoriesType=",
                    getAccessoriesType(_dna),
                    getAccessoriesType(_dna),
                    "&clotheColor=",
                    getClotheColor(_dna),
                    "&clotheType=",
                    getClotheType(_dna),
                    "&eyeType=",
                    getEyeType(_dna),
                    "&eyebrowType=",
                    getEyeBrowType(_dna),
                    "&facialHairColor=",
                    getFacialHairColor(_dna),
                    "&facialHairType=",
                    getFacialHairType(_dna),
                    "&hairColor=",
                    getHairColor(_dna),
                    "&hatColor=",
                    getHatColor(_dna),
                    "&graphicType=",
                    getGraphicType(_dna),
                    "&mouthType=",
                    getMouthType(_dna)
                )
            );
        }
        return
            string(abi.encodePacked(params, "&skinColor=", getSkinColor(_dna)));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721 Metadata: URI query for non-existent token"
        );

        uint256 dna = tokenDNA[tokenId];
        string memory image = imageByDNA(dna);

        string memory jsonUri = Base64.encode(
            abi.encodePacked(
                '{ "name" : "PlatziPunks #',
                tokenId.toString(),
                '", "description": "Platzi Punk", "image": "',
                image,
                '"}'
            )
        );

        return
            string(abi.encodePacked("data:application/json;base64.", jsonUri));
    }

    function deterministicPseudoRandomDNA(uint256 _tokenId, address _minter)
        public
        pure
        returns (uint256)
    {
        uint256 combineParams = _tokenId + uint160(_minter);
        bytes memory encodedParams = abi.encodePacked(combineParams);
        bytes32 hashedParams = keccak256(encodedParams);

        return uint256(hashedParams);
    }

    // Override required
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
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