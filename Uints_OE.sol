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
import "@openzeppelin/contracts/token/common/ERC2981.sol";

interface IUints {
    function getValue(uint id) external view returns (uint);
    function ownerOf(uint id) external view returns (address);
    function balanceOf(address owner) external view returns (uint);
}

interface IChanges {
    function mint(
        uint counter,
        uint position,
        string memory color,
        address initiator,
        uint uintsId,
        uint timestamp
        ) external;
}

contract UintsEdition is ERC721A, Ownable, ERC2981 {

    constructor() ERC721A("UINTS Edition", "UINTSED") {}

    uint64 public stopPrivateMintTime;
    uint64 public stopPublicMintTime;
    uint public changeCounter;

    mapping(uint => uint32) public colors;
    mapping(uint => bool) public usedTokens;

    address _uintsContract;
    address _changesContract;

    function setUintsContract(address contractAddress) public onlyOwner {
        _uintsContract = contractAddress;
        iUintsContract = IUints(contractAddress);
    }

    function setChangesContract(address contractAddress) public onlyOwner {
        _changesContract = contractAddress;
        iChangesContract = IChanges(contractAddress);
    }

    IUints iUintsContract = IUints(_uintsContract);
    IChanges iChangesContract = IChanges(_changesContract);

    function startMint() public onlyOwner {
        stopPrivateMintTime = uint64(block.timestamp + 24 hours);
        stopPublicMintTime = uint64(block.timestamp + 48 hours);
    }

    function checkValueOfUints(uint tokenId) public view returns (uint) {
        return iUintsContract.getValue(tokenId);
    }

    function mint(uint quantity) public {
        if (block.timestamp < stopPrivateMintTime) {
            // private mint
            require(iUintsContract.balanceOf(msg.sender) > 0, 'Must own UINTS during private mint phase');
            stopPublicMintTime -= uint64(quantity * 6);
        } else {
            // public mint
            require(block.timestamp < stopPublicMintTime, 'Mint has closed');
        }
        batchMint(quantity);
    }

    function batchMint(uint quantity) internal {
        // batch minting is optimized for ERC721A
        if (quantity > 30) {
            uint fullRuns = quantity / 30;
            uint remainder = quantity % 30;
            for (uint i = 0; i < fullRuns; i++) {
                _mint(msg.sender, 30);
            }
            if (remainder > 0) {
                _mint(msg.sender,remainder);
            }
        } else {
            _mint(msg.sender,quantity);
        }
    }

    function changeColor(uint position, uint8[3] memory rgbColors, uint uintsId) public {
        require(position > 0 && position < 65, 'Invalid position');
        require(iUintsContract.ownerOf(uintsId) == msg.sender, 'UINTS not owned');
        require(usedTokens[uintsId] == false, 'UINTS already used');
        require(balanceOf(msg.sender) > 0, 'Must own at least 1 UINTS Edition');

        uint32 colorValue = uint32(rgbColors[0]) << 16 | uint32(rgbColors[1]) << 8 | uint32(rgbColors[2]);

        colors[position] = colorValue;

        iChangesContract.mint(
            changeCounter + 1,
            position,
            getRgbColor(colorValue),
            msg.sender,
            uintsId,
            block.timestamp
        );

        changeCounter++;
        usedTokens[uintsId] = true;
    }

    function getRgbColor(uint32 color) public pure returns (string memory) {
        uint8 r = uint8(color >> 16);
        uint8 g = uint8(color >> 8);
        uint8 b = uint8(color);
        return string(abi.encodePacked(
            'RGB(',
            _toString(r),
            ',',
            _toString(g),
            ',',
            _toString(b),
            ')'
        ));
    }

    //----------------------------------------
    // TESTING ONLY - REMOVE BEFORE DEPLOYING
    //----------------------------------------

    function changeAllColorsToRed() public {
        for (uint i = 1; i < 65; i++) {
            changeColor(i, [255, 0, 0], i);
        }
    }

    function changeAllColorsToGreen() public {
        for (uint i = 1; i < 65; i++) {
            changeColor(i, [0, 255, 0], i);
        }
    }

    function changeAllColorsToBlue() public {
        for (uint i = 1; i < 65; i++) {
            changeColor(i, [0, 0, 255], i);
        }
    }

    //----------------------------------------

    function getCurrentStyles() public view returns (string memory styles) {
        for (uint i = 1; i < 65; i++) {
            styles = string(abi.encodePacked(
                styles,
                '#p',
                _toString(i),
                '{fill:',
                getRgbColor(colors[i]),
                '}'
            ));
        }
    }

    function convertColorsToStyles(uint32[64] memory colorArray) public pure returns (string memory styles) {
        for (uint i = 0; i < 64; i++) {
            styles = string(abi.encodePacked(
                styles,
                '#p',
                _toString(i+1),
                '{fill:',
                getRgbColor(colorArray[i]),
                '}'
            ));
        }
    }

    function getCurrentColors() public view returns (uint32[64] memory colorArray) {
        for (uint i = 1; i < 65; i++) {
            colorArray[i-1] = colors[i];
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
            '{"name": "UINTS Edition ',
            _toString(tokenId),
            '", "description": "UINTS Edition gives UINTS holders the power to make updates to on-chain artwork.", "image": "data:image/svg+xml;base64,',
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }

    function setRoyalty(address wallet, uint96 fee) public onlyOwner {
        _setDefaultRoyalty(wallet, fee); // 100 = 1%
    }
}