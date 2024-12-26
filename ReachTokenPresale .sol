// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReachTokenPresale {
    string public name = "Reach Token";
    string public symbol = "9D-RC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 18000000000 * (10 ** uint256(decimals));

    address public owner;
    uint256 public startDate;
    uint256 public phase1EndDate;
    uint256 public phase2EndDate;
    uint256 public phase3EndDate;

    uint256 public phase1Price = 24 ether / 1; // Price per token in Phase 1
    uint256 public phase2Price = 27 ether / 1; // Price per token in Phase 2

    mapping(address => uint256) public balances;
    mapping(address => uint256) public lockedTokens;

    event TokenPurchase(address indexed buyer, uint256 amount, uint256 phase);

    constructor() {
        owner = msg.sender;
        startDate = block.timestamp; // Set start date to today
        phase1EndDate = startDate + 7 days; // Phase 1 lasts 7 days
        phase2EndDate = phase1EndDate + 14 days; // Phase 2 lasts 14 days
        phase3EndDate = phase2EndDate + 14 days; // Phase 3 lasts 14 days
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function buyTokens() public payable {
        require(block.timestamp >= startDate, "Presale has not started");
        uint256 price = getCurrentPhasePrice();
        require(price > 0, "Presale is over");

        uint256 tokens = msg.value / price;
        require(totalSupply >= tokens, "Not enough tokens available");

        balances[msg.sender] += tokens;
        totalSupply -= tokens;

        emit TokenPurchase(msg.sender, tokens, getCurrentPhase());
    }

    function getCurrentPhasePrice() public view returns (uint256) {
        if (block.timestamp <= phase1EndDate) {
            return phase1Price;
        } else if (block.timestamp <= phase2EndDate) {
            return phase2Price;
        } else {
            return 0; // Presale ended
        }
    }

    function getCurrentPhase() public view returns (uint256) {
        if (block.timestamp <= phase1EndDate) {
            return 1;
        } else if (block.timestamp <= phase2EndDate) {
            return 2;
        } else {
            return 3; // Presale complete
        }
    }

    function updatePhaseDates(
        uint256 _phase1End,
        uint256 _phase2End,
        uint256 _phase3End
    ) public onlyOwner {
        phase1EndDate = _phase1End;
        phase2EndDate = _phase2End;
        phase3EndDate = _phase3End;
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
