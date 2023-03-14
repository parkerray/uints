// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract PixelTest is ERC721A {

    constructor() ERC721A("PixelTest", "PXL") {}

    struct Snapshot {
        address initiator;
        uint artVersion;
        uint timestamp;
        string canvasStyles;
    }
    mapping(uint => string) tiles;
    mapping(uint => Snapshot) public snapshots;

    uint public versionCounter;
    uint public snapshotCounter;

    function assignTile(uint tileId, uint[3] memory colors) public {
        tiles[tileId] = string(abi.encodePacked(
            'rgb(',
            _toString(colors[0]),
            ',',
            _toString(colors[1]),
            ',',
            _toString(colors[2]),
            ')'
        ));
        versionCounter++;
    }

    function assign81Tiles() public {
        for (uint i = 1; i < 82; i++) {
            assignTile(i, [block.timestamp % 255, i, i + 100]);
        }
    }

    function takeSnapshot() public {
        require(versionCounter > snapshots[snapshotCounter].artVersion, 'Snapshot already taken for this version of art');
        snapshots[snapshotCounter + 1] = Snapshot({
            initiator: msg.sender,
            canvasStyles: getCurrentStyles(),
            artVersion: versionCounter,
            timestamp: block.timestamp
        });
        snapshotCounter++;
    }
    
    function getSnapshotSvg(uint snapId) public view returns (string memory) {
        require(snapId > 0 && snapId <= snapshotCounter, 'Snapshot does not exist');
        return renderSvg(snapshots[snapId].canvasStyles);
    }

    function mintOne() public {
        _mint(msg.sender, 1);
    }

    function getCurrentStyles() internal view returns (string memory styles) {
        for (uint i = 1; i < 82; i++) {
            styles = string(abi.encodePacked(
                styles,
                '#p',
                _toString(i),
                '{fill:',
                tiles[i],
                '}'
            ));
        }
    }

    function getCurrentArt() public view returns (string memory) {
        return renderSvg(getCurrentStyles());
    }

    function renderSvg(string memory fingerprint) internal pure returns (string memory svg) {
        svg = '<svg width="800" height="800" viewBox="0 0 15 15" xmlns="http://www.w3.org/2000/svg"><rect width="15" height="15" fill="#0C0C0C"/><g class="tiles"><rect id="p1" x="3" y="3" fill="#fff"/><rect id="p2" x="4" y="3" fill="#fff"/><rect id="p3" x="5" y="3" fill="#fff"/><rect id="p4" x="6" y="3" fill="#fff"/><rect id="p5" x="7" y="3" fill="#fff"/><rect id="p6" x="8" y="3" fill="#fff"/><rect id="p7" x="9" y="3" fill="#fff"/><rect id="p8" x="10" y="3" fill="#fff"/><rect id="p9" x="11" y="3" fill="#fff"/><rect id="p10" x="3" y="4" fill="#fff"/><rect id="p11" x="4" y="4" fill="#fff"/><rect id="p12" x="5" y="4" fill="#fff"/><rect id="p13" x="6" y="4" fill="#fff"/><rect id="p14" x="7" y="4" fill="#fff"/><rect id="p15" x="8" y="4" fill="#fff"/><rect id="p16" x="9" y="4" fill="#fff"/><rect id="p17" x="10" y="4" fill="#fff"/><rect id="p18" x="11" y="4" fill="#fff"/><rect id="p19" x="3" y="5" fill="#fff"/><rect id="p20" x="4" y="5" fill="#fff"/><rect id="p21" x="5" y="5" fill="#fff"/><rect id="p22" x="6" y="5" fill="#fff"/><rect id="p23" x="7" y="5" fill="#fff"/><rect id="p24" x="8" y="5" fill="#fff"/><rect id="p25" x="9" y="5" fill="#fff"/><rect id="p26" x="10" y="5" fill="#fff"/><rect id="p27" x="11" y="5" fill="#fff"/><rect id="p28" x="3" y="6" fill="#fff"/><rect id="p29" x="4" y="6" fill="#fff"/><rect id="p30" x="5" y="6" fill="#fff"/><rect id="p31" x="6" y="6" fill="#fff"/><rect id="p32" x="7" y="6" fill="#fff"/><rect id="p33" x="8" y="6" fill="#fff"/><rect id="p34" x="9" y="6" fill="#fff"/><rect id="p35" x="10" y="6" fill="#fff"/><rect id="p36" x="11" y="6" fill="#fff"/><rect id="p37" x="3" y="7" fill="#fff"/><rect id="p38" x="4" y="7" fill="#fff"/><rect id="p39" x="5" y="7" fill="#fff"/><rect id="p40" x="6" y="7" fill="#fff"/><rect id="p41" x="7" y="7" fill="#fff"/><rect id="p42" x="8" y="7" fill="#fff"/><rect id="p43" x="9" y="7" fill="#fff"/><rect id="p44" x="10" y="7" fill="#fff"/><rect id="p45" x="11" y="7" fill="#fff"/><rect id="p46" x="3" y="8" fill="#fff"/><rect id="p47" x="4" y="8" fill="#fff"/><rect id="p48" x="5" y="8" fill="#fff"/><rect id="p49" x="6" y="8" fill="#fff"/><rect id="p50" x="7" y="8" fill="#fff"/><rect id="p51" x="8" y="8" fill="#fff"/><rect id="p52" x="9" y="8" fill="#fff"/><rect id="p53" x="10" y="8" fill="#fff"/><rect id="p54" x="11" y="8" fill="#fff"/><rect id="p55" x="3" y="9" fill="#fff"/><rect id="p56" x="4" y="9" fill="#fff"/><rect id="p57" x="5" y="9" fill="#fff"/><rect id="p58" x="6" y="9" fill="#fff"/><rect id="p59" x="7" y="9" fill="#fff"/><rect id="p60" x="8" y="9" fill="#fff"/><rect id="p61" x="9" y="9" fill="#fff"/><rect id="p62" x="10" y="9" fill="#fff"/><rect id="p63" x="11" y="9" fill="#fff"/><rect id="p64" x="3" y="10" fill="#fff"/><rect id="p65" x="4" y="10" fill="#fff"/><rect id="p66" x="5" y="10" fill="#fff"/><rect id="p67" x="6" y="10" fill="#fff"/><rect id="p68" x="7" y="10" fill="#fff"/><rect id="p69" x="8" y="10" fill="#fff"/><rect id="p70" x="9" y="10" fill="#fff"/><rect id="p71" x="10" y="10" fill="#fff"/><rect id="p72" x="11" y="10" fill="#fff"/><rect id="p73" x="3" y="11" fill="#fff"/><rect id="p74" x="4" y="11" fill="#fff"/><rect id="p75" x="5" y="11" fill="#fff"/><rect id="p76" x="6" y="11" fill="#fff"/><rect id="p77" x="7" y="11" fill="#fff"/><rect id="p78" x="8" y="11" fill="#fff"/><rect id="p79" x="9" y="11" fill="#fff"/><rect id="p80" x="10" y="11" fill="#fff"/><rect id="p81" x="11" y="11" fill="#fff"/></g><g class="grid"><line x1="1.005" y1="-2.18557e-10" x2="1.005" y2="15"/><line x1="2.005" y1="-2.18557e-10" x2="2.005" y2="15"/><line x1="3.005" y1="-2.18557e-10" x2="3.005" y2="15"/><line x1="4.005" y1="-2.18557e-10" x2="4.005" y2="15"/><line x1="5.005" y1="-2.18557e-10" x2="5.005" y2="15"/><line x1="6.005" y1="-2.18557e-10" x2="6.005" y2="15"/><line x1="7.005" y1="-2.18557e-10" x2="7.005" y2="15"/><line x1="8.005" y1="-2.18557e-10" x2="8.005" y2="15"/><line x1="9.005" y1="-2.18557e-10" x2="9.005" y2="15"/><line x1="10.005" y1="-2.18557e-10" x2="10.005" y2="15"/><line x1="11.005" y1="-2.18557e-10" x2="11.005" y2="15"/><line x1="12.005" y1="-2.18557e-10" x2="12.005" y2="15"/><line x1="13.005" y1="-2.18557e-10" x2="13.005" y2="15"/><line x1="14.005" y1="-2.18557e-10" x2="14.005" y2="15"/><line x1="15" y1="1.005" y2="1.005"/><line x1="15" y1="2.005" y2="2.005"/><line x1="15" y1="3.005" y2="3.005"/><line x1="15" y1="4.005" y2="4.005"/><line x1="15" y1="5.005" y2="5.005"/><line x1="15" y1="6.005" y2="6.005"/><line x1="15" y1="7.005" y2="7.005"/><line x1="15" y1="8.005" y2="8.005"/><line x1="15" y1="9.005" y2="9.005"/><line x1="15" y1="10.005" y2="10.005"/><line x1="15" y1="11.005" y2="11.005"/><line x1="15" y1="12.005" y2="12.005"/><line x1="15" y1="13.005" y2="13.005"/><line x1="15" y1="14.005" y2="14.005"/></g><style>.tiles rect{width:1px;height:1px;}.grid{stroke:#222;stroke-width:.01;}';
        svg = string(abi.encodePacked(
            svg,
            fingerprint,
            '</style></svg>'
        ));
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory result) {
        string memory svg = getCurrentArt();
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
}