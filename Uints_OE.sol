/*

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░                             ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░   ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░   ░░
░░                             ░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IUints {
    function getValue(uint id) external view returns (uint);
    function ownerOf(uint id) external view returns (address);
}

interface IProofOfChange {
    function mint(uint counter, uint timestamp, uint duration, uint uintsId, address recipient, uint number, uint red, uint green, uint blue, uint gratuity) external;
}

contract UintsOE is ERC721A, Ownable {

    constructor() ERC721A("UINTS - OE", "UOE") {}

    uint public changeCounter;

    mapping(uint => string) colors;
    mapping(uint => bool) usedTokens;

    address _uintsAddress = 0x9d83e140330758a8fFD07F8Bd73e86ebcA8a5692;
    IUints _uintsContract = IUints(_uintsAddress);

    address _pocAddress = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;
    IProofOfChange _pocContract = IProofOfChange(_pocAddress);

    function changeColor(uint position, uint[3] memory rgbColors) public {
        require(position > 0 && position < 65, 'Invalid position');
        colors[position] = string(abi.encodePacked(
            'rgb(',
            _toString(rgbColors[0]),
            ',',
            _toString(rgbColors[1]),
            ',',
            _toString(rgbColors[2]),
            ')'
        ));
        changeCounter++;
    }

    function changeAllColors() public {
        for (uint i = 1; i < 65; i++) {
            changeColor(i, [block.timestamp % 255, i, i + 100]);
        }
    }

    function mintOne() public {
        _mint(msg.sender, 1);
    }

    function getCurrentStyles() public view returns (string memory styles) {
        for (uint i = 1; i < 65; i++) {
            styles = string(abi.encodePacked(
                styles,
                '#p',
                _toString(i),
                '{fill:',
                colors[i],
                '}'
            ));
        }
    }

    function renderSvg(string memory styles) public pure returns (string memory) {
        return string(abi.encodePacked(
            '<svg width="840" height="840" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="14" height="14" fill="#0C0C0C"/><g class="tiles"><rect id="p1" x="3" y="3" fill="#fff"/><rect id="p2" x="4" y="3" fill="#fff"/><rect id="p3" x="5" y="3" fill="#fff"/><rect id="p4" x="6" y="3" fill="#fff"/><rect id="p5" x="7" y="3" fill="#fff"/><rect id="p6" x="8" y="3" fill="#fff"/><rect id="p7" x="9" y="3" fill="#fff"/><rect id="p8" x="10" y="3" fill="#fff"/><rect id="p9" x="3" y="4" fill="#fff"/><rect id="p10" x="4" y="4" fill="#fff"/><rect id="p11" x="5" y="4" fill="#fff"/><rect id="p12" x="6" y="4" fill="#fff"/><rect id="p13" x="7" y="4" fill="#fff"/><rect id="p14" x="8" y="4" fill="#fff"/><rect id="p15" x="9" y="4" fill="#fff"/><rect id="p16" x="10" y="4" fill="#fff"/><rect id="p17" x="3" y="5" fill="#fff"/><rect id="p18" x="4" y="5" fill="#fff"/><rect id="p19" x="5" y="5" fill="#fff"/><rect id="p20" x="6" y="5" fill="#fff"/><rect id="p21" x="7" y="5" fill="#fff"/><rect id="p22" x="8" y="5" fill="#fff"/><rect id="p23" x="9" y="5" fill="#fff"/><rect id="p24" x="10" y="5" fill="#fff"/><rect id="p25" x="3" y="6" fill="#fff"/><rect id="p26" x="4" y="6" fill="#fff"/><rect id="p27" x="5" y="6" fill="#fff"/><rect id="p28" x="6" y="6" fill="#fff"/><rect id="p29" x="7" y="6" fill="#fff"/><rect id="p30" x="8" y="6" fill="#fff"/><rect id="p31" x="9" y="6" fill="#fff"/><rect id="p32" x="10" y="6" fill="#fff"/><rect id="p33" x="3" y="7" fill="#fff"/><rect id="p34" x="4" y="7" fill="#fff"/><rect id="p35" x="5" y="7" fill="#fff"/><rect id="p36" x="6" y="7" fill="#fff"/><rect id="p37" x="7" y="7" fill="#fff"/><rect id="p38" x="8" y="7" fill="#fff"/><rect id="p39" x="9" y="7" fill="#fff"/><rect id="p40" x="10" y="7" fill="#fff"/><rect id="p41" x="3" y="8" fill="#fff"/><rect id="p42" x="4" y="8" fill="#fff"/><rect id="p43" x="5" y="8" fill="#fff"/><rect id="p44" x="6" y="8" fill="#fff"/><rect id="p45" x="7" y="8" fill="#fff"/><rect id="p46" x="8" y="8" fill="#fff"/><rect id="p47" x="9" y="8" fill="#fff"/><rect id="p48" x="10" y="8" fill="#fff"/><rect id="p49" x="3" y="9" fill="#fff"/><rect id="p50" x="4" y="9" fill="#fff"/><rect id="p51" x="5" y="9" fill="#fff"/><rect id="p52" x="6" y="9" fill="#fff"/><rect id="p53" x="7" y="9" fill="#fff"/><rect id="p54" x="8" y="9" fill="#fff"/><rect id="p55" x="9" y="9" fill="#fff"/><rect id="p56" x="10" y="9" fill="#fff"/><rect id="p57" x="3" y="10" fill="#fff"/><rect id="p58" x="4" y="10" fill="#fff"/><rect id="p59" x="5" y="10" fill="#fff"/><rect id="p60" x="6" y="10" fill="#fff"/><rect id="p61" x="7" y="10" fill="#fff"/><rect id="p62" x="8" y="10" fill="#fff"/><rect id="p63" x="9" y="10" fill="#fff"/><rect id="p64" x="10" y="10" fill="#fff"/></g><g class="grid"><line x1="1.005" y1="-2.18557e-10" x2="1.005" y2="14"/><line x1="2.005" y1="-2.18557e-10" x2="2.005" y2="14"/><line x1="3.005" y1="-2.18557e-10" x2="3.005" y2="14"/><line x1="4.005" y1="-2.18557e-10" x2="4.005" y2="14"/><line x1="5.005" y1="-2.18557e-10" x2="5.005" y2="14"/><line x1="6.005" y1="-2.18557e-10" x2="6.005" y2="14"/><line x1="7.005" y1="-2.18557e-10" x2="7.005" y2="14"/><line x1="8.005" y1="-2.18557e-10" x2="8.005" y2="14"/><line x1="9.005" y1="-2.18557e-10" x2="9.005" y2="14"/><line x1="10.005" y1="-2.18557e-10" x2="10.005" y2="14"/><line x1="11.005" y1="-2.18557e-10" x2="11.005" y2="14"/><line x1="12.005" y1="-2.18557e-10" x2="12.005" y2="14"/><line x1="13.005" y1="-2.18557e-10" x2="13.005" y2="14"/><line x1="14" y1="1.005" y2="1.005"/><line x1="14" y1="2.005" y2="2.005"/><line x1="14" y1="3.005" y2="3.005"/><line x1="14" y1="4.005" y2="4.005"/><line x1="14" y1="5.005" y2="5.005"/><line x1="14" y1="6.005" y2="6.005"/><line x1="14" y1="7.005" y2="7.005"/><line x1="14" y1="8.005" y2="8.005"/><line x1="14" y1="9.005" y2="9.005"/><line x1="14" y1="10.005" y2="10.005"/><line x1="14" y1="11.005" y2="11.005"/><line x1="14" y1="12.005" y2="12.005"/><line x1="14" y1="13.005" y2="13.005"/></g><style>.tiles rect{width:1px;height:1px;}.grid{stroke:#222;stroke-width:.01;}',
            styles,
            '</style></svg>'
        ));
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory result) {
        string memory svg = renderSvg(getCurrentStyles());
        string memory json = string(abi.encodePacked(
            '{"name": "PixelTest ',
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