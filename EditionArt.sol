/*

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░                                                        ░░
░░    . . 1 . .    . . 1 . .    . . 1 . .    . . 1 . .    ░░
░░   .         .  .         .  .         .  .         .   ░░
░░   2         3  2         3  2         3  2         3   ░░
░░   .         .  .         .  .         .  .         .   ░░
░░    . . 4 . .    . . 4 . .    . . 4 . .    . . 4 . .    ░░
░░   .         .  .         .  .         .  .         .   ░░
░░   5         6  5         6  5         6  5         6   ░░
░░   .         .  .         .  .         .  .         .   ░░
░░    . . 7 . .    . . 7 . .    . . 7 . .    . . 7 . .    ░░
░░        a            b            c            d        ░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Utilities.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

library art {
    // Four digits: a, b, c, d
    struct Number {
        uint a;
        uint b;
        uint c;
        uint d;
    }

    function getNumbers(uint input, uint length) internal pure returns (Number memory result) {
        if (length == 1) {
            result.d = input;
        } else if (length == 2) {
            result.c = (input / 10);
            result.d = (input % 10);
        } else if (length == 3) {
            result.b = (input / 100);
            result.c = ((input % 100) / 10);
            result.d = (input % 10);
        } else if (length == 4) {
            result.a = (input / 1000);
            result.b = ((input % 1000) / 100);
            result.c = ((input % 100) / 10);
            result.d = (input % 10);
        }
        return result;
    }

    function getNumberStyle(uint position, uint input) internal pure returns (string memory) {
        string memory p = utils.uint2str(position);
        if (input == 0) {
            return string(abi.encodePacked(
                "#p",p,"1,","#p",p,"2,","#p",p,"3,","#p",p,"5,","#p",p,"6,","#p",p,"7 {fill-opacity:1}"
            ));
        } else if (input == 1) {
            return string(abi.encodePacked(
                "#p",p,"3,","#p",p,"6 {fill-opacity:1}"
            ));
        } else if (input == 2) {
            return string(abi.encodePacked(
                "#p",p,"1,","#p",p,"3,","#p",p,"4,","#p",p,"5,","#p",p,"7 {fill-opacity:1}"
            ));
        } else if (input == 3) {
            return string(abi.encodePacked(
                "#p",p,"1,","#p",p,"3,","#p",p,"4,","#p",p,"6,","#p",p,"7 {fill-opacity:1}"
            ));
        } else if (input == 4) {
            return string(abi.encodePacked(
                "#p",p,"2,","#p",p,"3,","#p",p,"4,","#p",p,"6 {fill-opacity:1}"
            ));
        } else if (input == 5) {
            return string(abi.encodePacked(
                "#p",p,"1,","#p",p,"2,","#p",p,"4,","#p",p,"6,","#p",p,"7 {fill-opacity:1}"
            ));
        } else if (input == 6) {
            return string(abi.encodePacked(
                "#p",p,"1,","#p",p,"2,","#p",p,"4,","#p",p,"5,","#p",p,"6,","#p",p,"7 {fill-opacity:1}"
            ));
        } else if (input == 7) {
            return string(abi.encodePacked(
                "#p",p,"1,","#p",p,"3,","#p",p,"6 {fill-opacity:1}"
            ));
        } else if (input == 8) {
            return string(abi.encodePacked(
                "#p",p,"1,","#p",p,"2,","#p",p,"3,","#p",p,"4,","#p",p,"5,","#p",p,"6,","#p",p,"7 {fill-opacity:1}"
            ));
        } else if (input == 9) {
            return string(abi.encodePacked(
                "#p",p,"1,","#p",p,"2,","#p",p,"3,","#p",p,"4,","#p",p,"6,","#p",p,"7 {fill-opacity:1}"
            ));
        } else {
            return "error";
        }
    }

    function renderSvg(uint value, string memory colors) internal pure returns (string memory svg) {
        svg = '<svg width="900" height="900" viewBox="0 0 300 300" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="300" height="300" fill="#0C0C0C"/><g><path d="M66 103H233V197H66V103ZM67.5905 104.593V195.407H231.41V104.593H67.5905Z"/><path id="p01" d="M109.441 125L111.823 127.419L109.441 129.839L93.5588 129.839L91.1764 127.419L93.5588 125L109.441 125Z" fill-opacity="0.05"/><path id="p02" d="M88 130.645L90.3824 128.226L92.7647 130.645V146.774L90.3824 149.194L88 146.774V130.645Z" fill-opacity="0.05"/><path id="p03" d="M110.235 130.645L112.618 128.226L115 130.645V146.774L112.618 149.194L110.235 146.774V130.645Z" fill-opacity="0.05"/><path id="p04" d="M109.441 147.581L111.823 150L109.441 152.419L93.5588 152.419L91.1764 150L93.5588 147.581L109.441 147.581Z" fill-opacity="0.05"/><path id="p05" d="M88 153.226L90.3824 150.806L92.7647 153.226V169.355L90.3824 171.774L88 169.355V153.226Z" fill-opacity="0.05"/><path id="p06" d="M110.235 153.226L112.618 150.806L115 153.226V169.355L112.618 171.774L110.235 169.355V153.226Z" fill-opacity="0.05"/><path id="p07" d="M109.441 170.161L111.823 172.581L109.441 175L93.5588 175L91.1764 172.581L93.5588 170.161L109.441 170.161Z" fill-opacity="0.05"/><path id="p11" d="M141.441 125L143.823 127.419L141.441 129.839L125.559 129.839L123.176 127.419L125.559 125L141.441 125Z" fill-opacity="0.05"/><path id="p12" d="M120 130.645L122.382 128.226L124.765 130.645V146.774L122.382 149.194L120 146.774V130.645Z" fill-opacity="0.05"/><path id="p13" d="M142.235 130.645L144.618 128.226L147 130.645V146.774L144.618 149.194L142.235 146.774V130.645Z" fill-opacity="0.05"/><path id="p14" d="M141.441 147.581L143.823 150L141.441 152.419L125.559 152.419L123.176 150L125.559 147.581L141.441 147.581Z" fill-opacity="0.05"/><path id="p15" d="M120 153.226L122.382 150.806L124.765 153.226V169.355L122.382 171.774L120 169.355V153.226Z" fill-opacity="0.05"/><path id="p16" d="M142.235 153.226L144.618 150.806L147 153.226V169.355L144.618 171.774L142.235 169.355V153.226Z" fill-opacity="0.05"/><path id="p17" d="M141.441 170.161L143.823 172.581L141.441 175L125.559 175L123.176 172.581L125.559 170.161L141.441 170.161Z" fill-opacity="0.05"/><path id="p21" d="M173.441 125L175.823 127.419L173.441 129.839L157.559 129.839L155.176 127.419L157.559 125L173.441 125Z" fill-opacity="0.05"/><path id="p22" d="M152 130.645L154.382 128.226L156.765 130.645V146.774L154.382 149.194L152 146.774V130.645Z" fill-opacity="0.05"/><path id="p23" d="M174.235 130.645L176.618 128.226L179 130.645V146.774L176.618 149.194L174.235 146.774V130.645Z" fill-opacity="0.05"/><path id="p24" d="M173.441 147.581L175.823 150L173.441 152.419L157.559 152.419L155.176 150L157.559 147.581L173.441 147.581Z" fill-opacity="0.05"/><path id="p25" d="M152 153.226L154.382 150.806L156.765 153.226V169.355L154.382 171.774L152 169.355V153.226Z" fill-opacity="0.05"/><path id="p26" d="M174.235 153.226L176.618 150.806L179 153.226V169.355L176.618 171.774L174.235 169.355V153.226Z" fill-opacity="0.05"/><path id="p27" d="M173.441 170.161L175.823 172.581L173.441 175L157.559 175L155.176 172.581L157.559 170.161L173.441 170.161Z" fill-opacity="0.05"/><path id="p31" d="M205.441 125L207.823 127.419L205.441 129.839L189.559 129.839L187.176 127.419L189.559 125L205.441 125Z" fill-opacity="0.05"/><path id="p32" d="M184 130.645L186.382 128.226L188.765 130.645V146.774L186.382 149.194L184 146.774V130.645Z" fill-opacity="0.05"/><path id="p33" d="M206.235 130.645L208.618 128.226L211 130.645V146.774L208.618 149.194L206.235 146.774V130.645Z" fill-opacity="0.05"/><path id="p34" d="M205.441 147.581L207.823 150L205.441 152.419L189.559 152.419L187.176 150L189.559 147.581L205.441 147.581Z" fill-opacity="0.05"/><path id="p35" d="M184 153.226L186.382 150.806L188.765 153.226V169.355L186.382 171.774L184 169.355V153.226Z" fill-opacity="0.05"/><path id="p36" d="M206.235 153.226L208.618 150.806L211 153.226V169.355L208.618 171.774L206.235 169.355V153.226Z" fill-opacity="0.05"/><path id="p37" d="M205.441 170.161L207.823 172.581L205.441 175L189.559 175L187.176 172.581L189.559 170.161L205.441 170.161Z" fill-opacity="0.05"/><animate attributeName="fill" dur="27s" repeatCount="indefinite" values="';

        string memory styles = '"/></g><style>#bg{fill:#0C0C0C}';

        if (value == 0) {} else {
            uint length = bytes(utils.uint2str(value)).length;
            Number memory number = getNumbers(value, length);
            if (length == 1) {
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(3, number.d))
                );
            } else if (length == 2) {
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(2, number.c))
                );
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(3, number.d))
                );
            } else if (length == 3) {
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(1, number.b))
                );
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(2, number.c))
                );
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(3, number.d))
                );
            } else if (length == 4) {
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(0, number.a))
                );
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(1, number.b))
                );
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(2, number.c))
                );
                styles = string(
                    abi.encodePacked(styles, getNumberStyle(3, number.d))
                );
            }
        }
        return string(abi.encodePacked(svg, colors, styles, "</style></svg>"));
    }
}
