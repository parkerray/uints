/*

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░                                                        ░░
░░    . . . . .    P P P P P    O O O O O    B B B B B    ░░
░░   .         .  P         P  O         O  B         B   ░░
░░   .         .  P         P  O         O  B         B   ░░
░░   .         .  P         P  O         O  B         B   ░░
░░    . . . . .    P P P P P    . . . . .    B B B B B    ░░
░░   .         .  P         .  O         O  B         B   ░░
░░   .         .  P         .  O         O  B         B   ░░
░░   .         .  P         .  O         O  B         B   ░░
░░    . . . . .    . . . . .    O O O O O    B B B B B    ░░
░░                                                        ░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "erc721a/contracts/ERC721A.sol";
import "./BroadcastUtilities.sol";

contract UintsProofOfBroadcast is ERC721A, Ownable {

    struct Receipt {
        uint counter;
        uint timestamp;
        uint duration;
        uint uintsId;
        address recipient;
        uint number;
        string color;
        uint gratuity;
    }

    mapping (uint => Receipt) receipts;

    address _editionContract;

    constructor() ERC721A("UINTS PROOF OF BROADCAST", "UPB") {}

    function setEditionContract(address contractAddress) public onlyOwner {
        _editionContract = contractAddress;
    }

    function mint(uint counter, uint timestamp, uint duration, uint uintsId, address recipient, uint number, uint red, uint green, uint blue, uint gratuity) external {
        require(msg.sender == _editionContract, 'Unapproved minting source');
        string memory color = string(abi.encodePacked(
            'RGB(',
            _toString(red),
            ',',
            _toString(green),
            ',',
            _toString(blue),
            ')'
        ));

        receipts[counter] = Receipt({
            counter: counter,
            timestamp: timestamp,
            duration: duration,
            uintsId: uintsId,
            recipient: recipient,
            number: number,
            color: color,
            gratuity: gratuity / 1000000000 // WEI >> GWEI
        });

        _mint(recipient, 1);
    }

    function getReceipt(uint tokenId) public view returns (Receipt memory) {
        require(_exists(tokenId), 'Token does not exist');
        return receipts[tokenId];
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory result) {
        require(_exists(tokenId), 'Token does not exist');

        string memory svg = string(abi.encodePacked(
            '<svg width="900" height="900" viewBox="0 0 300 300" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="300" height="300" fill="#0C0C0C"/><rect x="76" y="46" width="148" height="210" fill="white"/><rect id="colorBar" y="294" width="300" height="6" fill="#0c0c0c"><animate attributeName="width" values="0;300" dur="1s"/></rect><path d="M141.5 59.2886L143 57.7886L144.5 59.2886V69.2889L143 70.789L141.5 69.2889V59.2886Z" fill="black"/><path d="M155.5 59.2886L157 57.7886L158.5 59.2886V69.2889L157 70.789L155.5 69.2889V59.2886Z" fill="black"/><path d="M155 69.7887L156.5 71.2887L155 72.7888L145 72.7888L143.5 71.2887L145 69.7887L155 69.7887Z" fill="black"/><line x1="88" y1="84.2347" x2="212" y2="84.2347" stroke="black"/><line x1="88" y1="103.675" x2="212" y2="103.675" stroke="black"/><text fill="black" font-family="sans-serif" font-size="8" font-weight="bold"><tspan x="88.793" y="96.9586">UINTS PROOF OF BROADCAST</tspan></text><text text-anchor="middle" fill="black" font-family="sans-serif" font-size="12"><tspan x="147.16" y="119.239">#',
            _toString(receipts[tokenId].counter),
            '</tspan></text><line x1="88.5" y1="125.481" x2="211.5" y2="125.481" stroke="#0C0C0C" stroke-linecap="square" stroke-dasharray="2 4"/><text fill="#0C0C0C" font-family="sans-serif" font-size="7"><tspan x="88.5" y="140.098">NUMBER BROADCAST: ',
            _toString(receipts[tokenId].number),
            '</tspan></text><text fill="#0C0C0C" font-family="sans-serif" font-size="7"><tspan x="88.5" y="153.733">COLOR: ',
            receipts[tokenId].color,
            '</tspan></text><text fill="#0C0C0C" font-family="sans-serif" font-size="7"><tspan x="88.5" y="167.368">ARTIST: ',
            utils.abbreviateAddress(receipts[tokenId].recipient),
            '</tspan></text><text fill="#0C0C0C" font-family="sans-serif" font-size="7"><tspan x="88.5" y="181.003">UINTS TOKEN ID: ',
            _toString(receipts[tokenId].uintsId),
            '</tspan></text><text fill="#0C0C0C" font-family="sans-serif" font-size="7"><tspan x="88.5" y="194.638">BLOCK TIMESTAMP: ',
            _toString(receipts[tokenId].timestamp),
            '</tspan></text><text fill="#0C0C0C" font-family="sans-serif" font-size="7"><tspan x="88.5" y="208.273">LOCK DURATION: ',
            _toString(receipts[tokenId].duration),
            ' MINUTES',
            '</tspan></text><text fill="#0C0C0C" font-family="sans-serif" font-size="7"><tspan x="88.5" y="221.908">GRATUITY PAID: ',
            _toString(receipts[tokenId].gratuity),
            ' GWEI',
            '</tspan></text><line x1="88.5" y1="232.787" x2="211.5" y2="232.787" stroke="black" stroke-linecap="square" stroke-dasharray="2 4"/><text fill="black" font-family="sans-serif" font-size="5"><tspan x="98.5352" y="245.511">NUMBERS ARE ART, AND WE ARE ARTISTS</tspan></text><style>#colorBar{fill:',
            receipts[tokenId].color,
            '}</style></svg>'
        ));
        
        string memory json = string(abi.encodePacked(
            '{"name": "UINTS Proof of Broadcast ',
            _toString(tokenId),
            '", "description": "UINTS Proof of Broadcast tokens are digital receipts sent to UINTS holders when they broadcast to the UINTS Edition collection. Numers are art, and we are artists.", "image": "data:image/svg+xml;base64,',
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
}