/*

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░                             ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░   ░░ ░░ ██ ░░ ░░ ░░ ░░ ░░   ░░
░░   ░░ ██ ██ ██ ██ ██ ██ ░░   ░░
░░   ░░ ██ ░░ ░░ ░░ ░░ ██ ░░   ░░
░░   ░░ ██ ░░ ░░ ██ ░░ ██ ░░   ░░
░░   ░░ ██ ░░ ░░ ░░ ░░ ██ ░░   ░░
░░   ░░ ██ ██ ██ ██ ██ ██ ░░   ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░                             ░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IUintsOE {
    function getCurrentStyles() external view returns (string memory);
    function renderSvg(string memory styles) external pure returns (string memory);
    function changeCounter() external pure returns (uint);
}

contract UintsOESnapshots is ERC721A, Ownable {

    constructor() ERC721A("UINTS Edition Snapshots", "UINTSEDSS") {}

    IUintsOE _editionContract = IUintsOE(0x05A8d17EAFa10EA149788c67a8e9A028B8241334);

    struct Snapshot {
        address capturedBy;
        uint artVersion;
        uint timestamp;
        string canvasStyles;
    }

    mapping(uint => Snapshot) public snapshots;
    uint public snapshotCounter;

    function takeSnapshot() public {
        snapshots[snapshotCounter + 1] = Snapshot({
            capturedBy: msg.sender,
            canvasStyles: _editionContract.getCurrentStyles(),
            artVersion: _editionContract.changeCounter(),
            timestamp: block.timestamp
        });
        _mint(msg.sender, 1);
        snapshotCounter++;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory result) {
        string memory svg = _editionContract.renderSvg(snapshots[tokenId].canvasStyles);
        string memory json = string(abi.encodePacked(
            '{"name": "UINTS Edition Snapshot ',
            _toString(tokenId),
            '", "description": "UINTS Edition Snapshots are on-chain records of artwork from the UINTS Edition collection.", ',
            '"attributes": [{"trait_type": "Captured by", "value": "0x',
            toAsciiString(snapshots[tokenId].capturedBy),
            '"},{"display_type": "number", "trait_type": "Art version", "value": ',
            _toString(snapshots[tokenId].artVersion),
            '},{"display_type": "date", "trait_type": "Date", "value": ',
            _toString(snapshots[tokenId].timestamp),
            '}], "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(svg)),
            '"}'
        ));

        result = string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function withdraw() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

}