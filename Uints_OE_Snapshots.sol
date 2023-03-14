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

    constructor() ERC721A("UINTS - OE Snapshots", "UOESNAPS") {}

    IUintsOE _editionContract = IUintsOE(0x93f8dddd876c7dBE3323723500e83E202A7C96CC);

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
            '{"name": "UINTS OE - SNAPSHOT ',
            _toString(tokenId),
            '", "description": "This is a test", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(svg)),
            '"}'
        ));

        result = string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function withdraw() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

}