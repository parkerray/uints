/*

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░                                                        ░░
░░    . . . . .    . . . . .    . . . . .    . . . . .    ░░
░░   .         .  .         .  .         .  .         .   ░░
░░   .         .  .         .  .         .  .         .   ░░
░░   .         .  .         .  .         .  .         .   ░░
░░    . . . . .    . . . . .    . . . . .    . . . . .    ░░
░░   .         .  .         .  .         .  .         .   ░░
░░   .         .  .         .  .         .  .         .   ░░
░░   .         .  .         .  .         .  .         .   ░░
░░    . . . . .    . . . . .    . . . . .    . . . . .    ░░
░░                                                        ░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library utils {

    function abbreviateAddress(address _address) internal pure returns (string memory) {
        string memory addressStr = toAsciiString(_address);
        uint len = bytes(addressStr).length;
        uint startLen = 3;
        uint endLen = len - 4;
        return string(abi.encodePacked(
            "0x",
            substring(addressStr, 0, startLen),
            "...",
            substring(addressStr, endLen, len)
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

    function substring(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

}
