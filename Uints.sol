/*

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░                                                        ░░
░░    9 9 9 9 9    9 9 9 9 9    9 9 9 9 9    9 9 9 9 9    ░░
░░   9         9  9         9  9         9  9         9   ░░
░░   9         9  9         9  9         9  9         9   ░░
░░   9         9  9         9  9         9  9         9   ░░
░░    9 9 9 9 9    9 9 9 9 9    9 9 9 9 9    9 9 9 9 9    ░░
░░   .         9  .         9  .         9  .         9   ░░
░░   .         9  .         9  .         9  .         9   ░░
░░   .         9  .         9  .         9  .         9   ░░
░░    . . . . .    . . . . .    . . . . .    . . . . .    ░░
░░                                                        ░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Utilities.sol";
import "./Segments.sol";
import "./IERC4906.sol";

contract Uints is ERC721A, Ownable, IERC4906 {
    event CountdownExtended(uint _finalBlock);

    uint public price = 0; //.002 eth 2000000000000000
    bool public isCombinable = true;
    uint public finalMintingBlock;

    string[] baseColorNames = ["White", "Red", "Green", "Blue"];

    mapping(uint => uint) newValues;
    mapping(uint => uint) baseColors;
    mapping(address => uint) freeMints;

    constructor() ERC721A("UINTS", "UINTS") {}

    function mint(uint quantity) public payable {
        require(msg.value >= quantity * price, "not enough eth");
        handleMint(msg.sender, quantity);
    }

    function freeMint(uint quantity) public {
        require(quantity <= freeMints[msg.sender], "not enough free mints");
        handleMint(msg.sender, quantity);
        freeMints[msg.sender] -= quantity;
    }

    function handleMint(address recipient, uint quantity) internal {
        uint supply = _totalMinted();
        if (supply >= 1000) {
            require(
                utils.secondsRemaining(finalMintingBlock) > 0,
                "mint is closed"
            );
            if (supply < 5000 && (supply + quantity) >= 5000) {
                // Start phase 3! IT'S THE FINAL COUNTDOWN
                finalMintingBlock = block.timestamp + 24 hours;
                emit CountdownExtended(finalMintingBlock);
            }
        } else if (supply + quantity >= 1000) {
            // Start phase 2!
            finalMintingBlock = block.timestamp + 24 hours;
            emit CountdownExtended(finalMintingBlock);
        }
        _mint(recipient, quantity);
    }

    function combine(uint[] memory tokens) public {
        require(isCombinable, "combining function not active");
        uint sum;
        for (uint i = 0; i < tokens.length; i++) {
            require(ownerOf(tokens[i]) == msg.sender, "must own all tokens to combine");
            sum = sum + getValue(tokens[i]);
        }
        if (sum > 9999) {
            revert("cannot combine for a sum larger than 9999");
        }
        for (uint i = 1; i < tokens.length; i++) {
            _burn(tokens[i]);
            newValues[tokens[i]] = 0;
            baseColors[tokens[i]] = 0;
            emit MetadataUpdate(tokens[i]);
        }

        // Why was 6 afraid of 7? Because 7 8 9!
        newValues[tokens[0]] = sum;
        baseColors[tokens[0]] = utils.random(tokens[0], 1, 4);
        emit MetadataUpdate(tokens[0]);
    }

    function getRgbs(
        uint tokenId
    ) public view returns (uint256[3] memory rgbValues) {
        if (baseColors[tokenId] > 0) {
            for (uint i = 0; i < 3; i++) {
                if (baseColors[tokenId] == i + 1) {
                    rgbValues[i] = 255;
                } else {
                    rgbValues[i] = utils.random(tokenId + i, 0, 256);
                }
            }
        } else {
            for (uint i = 0; i < 3; i++) {
                rgbValues[i] = 255;
            }
        }
        return rgbValues;
    }

    function getSvg(uint tokenId) public view returns (string memory) {
        require(_exists(tokenId), "token does not exist");
        return segments.renderSvg(tokenId, getRgbs(tokenId));
    }

    function getValue(uint256 tokenId) public view returns (uint) {
        require(_exists(tokenId), "token does not exist");
        if (newValues[tokenId] > 0) {
            return newValues[tokenId];
        } else {
            return utils.initValue(tokenId);
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        string memory burned;
        uint mintPhase;
        uint value;
        uint[3] memory rgbs = getRgbs(tokenId);

        if (tokenId <= 1000) {
            mintPhase = 1;
        } else if (tokenId <= 5000) {
            mintPhase = 2;
        } else {
            mintPhase = 3;
        }

        if (newValues[tokenId] > 0) {
            value = newValues[tokenId];
            burned = "No";
        } else if (newValues[tokenId] == 0 && !_exists(tokenId)) {
            value = 0;
            burned = "Yes";
        } else {
            value = utils.initValue(tokenId);
            burned = "No";
        }

        string memory svg = segments.renderSvg(value, rgbs);
        string memory json = string(
            abi.encodePacked(
                '{"name": "UINTS ',
                _toString(tokenId),
                '", "description": "numbers are art, and we are artists.", "attributes":[{"trait_type": "Number", "value": ',
                _toString(value),
                '},{"trait_type": "Mint Phase", "value": ',
                _toString(mintPhase),
                '},{"trait_type": "Burned", "value": "',
                burned,
                '"},{"trait_type": "Base Color", "value": "',
                baseColorNames[baseColors[tokenId]],
                '"},{"trait_type": "R", "value": ',
                _toString(rgbs[0]),
                '},{"trait_type": "G", "value": ',
                _toString(rgbs[1]),
                '},{"trait_type": "B", "value": ',
                _toString(rgbs[2]),
                '}], "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(svg)),
                '"}'
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(json))
                )
            );
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function getMinutesRemaining() public view returns (uint) {
        return utils.minutesRemaining(finalMintingBlock);
    }

    function mintCount() public view returns (uint) {
        return _totalMinted();
    }

    function burnCount() public view returns (uint) {
        return _totalBurned();
    }

    function toggleCombinable() public onlyOwner {
        isCombinable = !isCombinable;
    }

    function withdraw() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    function freeMintBalance(address addy) public view returns (uint) {
        return freeMints[addy];
    }

    function addFreeMints(
        address[] calldata addresses,
        uint quantity
    ) public onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            freeMints[addresses[i]] = quantity;
        }
    }
}
