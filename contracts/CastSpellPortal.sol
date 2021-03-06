// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract CastSpellPortal {
    uint totalSpells;
    uint private seed;
    uint winnerCount;

    event NewSpellCast(address indexed from, uint timestamp, string message, bool isWinner);
    event PrizeWinner(address indexed from, uint prizeAmount);

    struct Spell {
        address spellCaster; // address of user casting the spell
        string message; // message from the spell caster
        uint timestamp; // time when the user cast a spell
        bool isWinner; // is this person a winner
    }

    Spell[] spellsCast;

    string[] private spells = [
        "Reparo",
        "Accio",
        "Wingardium Leviosa",
        "Episkey",
        "Aguamenti",
        "Protego",
        "Finite Incantatem"
    ];

    string private currentSpell = "";

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getSpell(address input, string memory _msg) public {
        return castSpell(input, "SPELLS", spells, _msg);
    }

    function setSpell(string memory spell) public {
        currentSpell = spell;
    }

    function getSpellName() public view returns (string memory) {
        return currentSpell;
    }

    function getAllSpellsCast() public view returns (Spell[] memory) {
        return spellsCast;
    }

    function getWinnerCount() public view returns (uint) {
        return winnerCount;
    }

    // Track the address that last casted a spell
    mapping(address => uint) public lastSpellCastAt;

    constructor() payable {
        console.log("Yer a wizard! ...smart contract");
    }

    function castSpell(address input, string memory keyPrefix, string[] memory sourceArray, string memory _msg) public {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, input)));
        string memory output = sourceArray[rand % sourceArray.length];
        bool isWinner = false;

        // Cooldown to reduce spammers
        require(lastSpellCastAt[msg.sender] + 60 seconds < block.timestamp, "Wait 1m");

        lastSpellCastAt[msg.sender] = block.timestamp;

        totalSpells += 1;

        // Generating PSEUDORANDOM number in the range 100
        uint randomNum = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %s", randomNum);

        // Set generated random number as seed for the next spell
        seed = randomNum;

        // 50% chance a user wins the prize
        if (randomNum < 50) {
            console.log("%s has won!", msg.sender);
            // Prize money to spell casters!
            uint prizeAmount = 0.00001 ether;
            require(prizeAmount <= address(this).balance, "Trying to withdraw more money than contract has!");
            (bool success,) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
            winnerCount += 1;
            isWinner = true;
            emit PrizeWinner(msg.sender, prizeAmount);
        }
        
        if (bytes(_msg).length != 0) {
            setSpell(_msg);
        } else {
            setSpell(output);
        }

        string memory finalSpellName = getSpellName();
        
        console.log("%s cast a spell %s!", msg.sender, finalSpellName);

        // Storing spell data
        spellsCast.push(Spell(msg.sender, finalSpellName, block.timestamp, isWinner));

        // emits event out
        emit NewSpellCast(msg.sender, block.timestamp, finalSpellName, isWinner);
    }

    function getTotalSpells() view public returns (uint) {
        console.log("We have %d total spells casted!", totalSpells);
        return totalSpells;
    }
}