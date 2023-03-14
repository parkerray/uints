/*

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░                                                        ░░
░░    . . . . .    . . . . .    O O O O O    E E E E E    ░░
░░   .         .  .         .  O         O  E         .   ░░
░░   .         .  .         .  O         O  E         .   ░░
░░   .         .  .         .  O         O  E         .   ░░
░░    . . . . .    . . . . .    . . . . .    E E E E E    ░░
░░   .         .  .         .  O         O  E         .   ░░
░░   .         .  .         .  O         O  E         .   ░░
░░   .         .  .         .  O         O  E         .   ░░
░░    . . . . .    . . . . .    O O O O O    E E E E E    ░░
░░                                                        ░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// UINTS mainnet contract address: 0x7C10C8816575e8Fdfb11463dD3811Cc794A1D407
// UINTS goerli contract address: 0xEeFb1121Cf8506C8358Ca308764F588FC09Ad7C2

interface IUints {
    function getValue(uint id) external view returns (uint);
    function ownerOf(uint id) external view returns (address);
}

interface IProofOfBroadcast {
    function mint(uint counter, uint timestamp, uint duration, uint uintsId, address recipient, uint number, uint red, uint green, uint blue, uint gratuity) external;
}

import "./EditionArt.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "erc721a/contracts/ERC721A.sol";

contract UintsEdition is ERC721A, Ownable {

    constructor() ERC721A("UINTS EDITION", "UE") {
        startAnimationColors();
    }

    struct Rgb {
        uint red;
        uint green;
        uint blue;
    }

    Rgb[9] public animationColors;
    uint animationIndex;
    uint public broadcastNumber = 0;
    uint public lockedUntil;
    uint public broadcastCounter;
    uint public mintCloseTime = 0;

    mapping(uint => bool) usedTokens;

    address _uintsAddress = 0x9d83e140330758a8fFD07F8Bd73e86ebcA8a5692;
    IUints _uintsContract = IUints(_uintsAddress);

    address _pobAddress = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;
    IProofOfBroadcast _pobContract = IProofOfBroadcast(_pobAddress);

    function startMint() public onlyOwner {
        mintCloseTime = block.timestamp + 24 hours;
    }

    function mint(uint quantity) public {
        require(block.timestamp <= mintCloseTime, 'Mint is closed');
        _mint(msg.sender, quantity);
    }

    function getValue(uint id) internal view returns (uint) {
        return _uintsContract.getValue(id);
    }

    function ownerOfUints(uint id) internal view returns (address) {
        return _uintsContract.ownerOf(id);
    }

    function startAnimationColors() internal {
        // Rgb memory red = Rgb({
        //     red: 255,
        //     green: 0,
        //     blue: 0
        // });
        // Rgb memory green = Rgb({
        //     red: 0,
        //     green: 255,
        //     blue: 0
        // });
        // Rgb memory blue = Rgb({
        //     red: 0,
        //     green: 0,
        //     blue: 255
        // });
        Rgb memory white = Rgb({
            red: 255,
            green: 255,
            blue: 255
        });
        for (uint i = 0; i < 9; i++) {
            addToAnimation(white);
        }
    }

    function addToAnimation(Rgb memory colors) internal {
        animationColors[animationIndex] = colors;
        if (animationIndex < 8) {
            animationIndex++;
        } else {
            animationIndex = 0;
        }
    }

    function checkColors(Rgb memory colors) internal pure returns (bool validColors) {
        validColors = false;
        if (colors.red == 255) {
            validColors = true;
        } else if (colors.green == 255) {
            validColors = true;
        } else if (colors.blue == 255) {
            validColors = true;
        }
        if (colors.red > 255) {
            validColors = false;
        } else if (colors.green > 255) {
            validColors = false;
        } else if (colors.blue > 255) {
            validColors = false;
        }
    }

    function broadcast(uint number, uint tokenId, Rgb memory colors) public payable {
        uint tokenValue = getValue(tokenId);

        require(block.timestamp > mintCloseTime, 'Cannot broadcast until mint is closed');
        require(msg.sender == ownerOfUints(tokenId), 'Must own the UINTS used to broadcast');
        require(usedTokens[tokenId] != true, 'This UINTS has already been used to broadcast');
        require(number <= tokenValue, 'Number must be less than or equal to the UINTS value');
        require(tokenValue > 9, 'UINTS must have a number greater than 9');
        require(number >= 1 && number <= 9999, 'Broadcast number must be between 1 and 9999');
        require(lockedUntil <= block.timestamp, 'Broadcasting is currently locked');
        require(checkColors(colors), 'Colors are not valid');

        broadcastNumber = number;
        addToAnimation(colors);
        uint timer = tokenValue * 12;
        lockedUntil = block.timestamp + timer;
        broadcastCounter++;
        usedTokens[tokenId] = true;
        _pobContract.mint(broadcastCounter, block.timestamp, timer / 60, tokenId, msg.sender, number, colors.red, colors.green, colors.blue, msg.value);
    }

    function secondsUntilUnlocked() external view returns (uint) {
        if (block.timestamp <= lockedUntil) {
            return (lockedUntil - block.timestamp);
        } else {
            return 0;
        }
    }

    function minutesUntilUnlocked() external view returns (uint) {
        if (block.timestamp <= lockedUntil) {
            return (lockedUntil - block.timestamp) / 60;
        } else {
            return 0;
        }
    }

    function getSvg() internal view returns (string memory) {
        string memory colors = "";
        for (uint i = 0; i < animationColors.length; i++) {
            for (uint x = 0; x < 2; x++) {
                colors = string(abi.encodePacked(
                    colors,
                    "rgb(",
                    _toString(animationColors[i].red),
                    ",",
                    _toString(animationColors[i].green),
                    ",",
                    _toString(animationColors[i].blue),
                    ");"
                ));
            }
        }
        colors = string(abi.encodePacked(
            colors,
            "rgb(",
            _toString(animationColors[0].red),
            ",",
            _toString(animationColors[0].green),
            ",",
            _toString(animationColors[0].blue),
            ");"
        ));
        return art.renderSvg(broadcastNumber, colors);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory result) {
        string memory json = string(abi.encodePacked(
            '{"name": "UINTS Edition ',
            _toString(tokenId),
            '", "description": "Numbers are art, and we are artists. The metadata for UINTS Editions are set by UINTS holders.", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(getSvg())),
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