// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract TipCreatorContract {
    address public owner;
    address[] private sponsoredCauses;
    SponsoredCauseAmount[] private sponsoredCausesAmounts;
    uint256 public totalTipsAmount;
    TopTipper private topTipper;
    bool public active = true;
    struct TopTipper {
        address tipperAdress;
        uint256 amount;
    }
    struct SponsoredCauseAmount {
        address sponsoredCauseAddress;
        uint256 amount;
    }

    // Event
    event Tip(address indexed tipper, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier contractActive() {
        require(active, "Contract is deactivated");
        _;
    }

    constructor(address[] memory initSponsoredCauses) {
        require(
            initSponsoredCauses.length > 0,
            "At least one sponsored cause required"
        );

        owner = msg.sender;
        sponsoredCauses = initSponsoredCauses;

        // Init all causes amounts with 0
        for (uint256 index = 0; index < initSponsoredCauses.length; index++) {
            sponsoredCausesAmounts.push(SponsoredCauseAmount(initSponsoredCauses[index],0));
        }
    }

    /**
     * Tip with sending 10% to sponsored cause
     */
    function tip(address creatorAddress, uint256 sponsorCauseIndex) external payable contractActive {
        require(msg.value > 0, "Tip amount must be greater than zero");
        require(sponsorCauseIndex < sponsoredCauses.length, "Invalid sponsor cause index");

        uint256 tipAmount = msg.value;
        uint256 sponsorAmount = (tipAmount * 10) / 100;
        uint256 creatorAmount = tipAmount - sponsorAmount;

        address sponsoredCause = sponsoredCauses[sponsorCauseIndex]; 
        payable(sponsoredCause).transfer(sponsorAmount);
        payable(creatorAddress).transfer(creatorAmount);

        // Update tracking variables
        totalTipsAmount += tipAmount;
        increaseSponsoredCauseAmount(sponsoredCause, sponsorAmount);
        setTopTipper(msg.sender, tipAmount);

        // Emit event
        emit Tip(msg.sender, tipAmount);
    }

    /**
     * Tip with custom amount
     */
    function tip(address creatorAddress, uint256 sponsorCauseIndex, uint256 tipAmountWei) external payable contractActive {
        require(msg.value >= tipAmountWei, "Insufficient funds sent");
        require(sponsorCauseIndex < sponsoredCauses.length, "Invalid sponsor cause index");

        uint256 sponsorAmount = (tipAmountWei * 10) / 100;

        require(
            sponsorAmount >= (msg.value * 1) / 100,
            "Donation has to be at least 1% of the total amount"
        );
        require(
            sponsorAmount <= (msg.value * 50) / 100,
            "Donation too large - cannot exceed half of the total amount"
        );

        uint256 creatorAmount = tipAmountWei - sponsorAmount;

        address sponsoredCause = sponsoredCauses[sponsorCauseIndex]; 
        payable(sponsoredCause).transfer(sponsorAmount);
        payable(creatorAddress).transfer(creatorAmount);

        // Update tracking variables
        totalTipsAmount += tipAmountWei;
        increaseSponsoredCauseAmount(sponsoredCause, sponsorAmount);
        setTopTipper(msg.sender, tipAmountWei);

        // Emit event
        emit Tip(msg.sender, tipAmountWei);
    }

    /**
     * Set top tipper
     */
    function setTopTipper(address tipper, uint256 amount) internal {
        if (amount > topTipper.amount) {
            topTipper.tipperAdress = tipper;
            topTipper.amount = amount;
        }
    }

    /**
     * Increase sponsored cause amount
     */
    function increaseSponsoredCauseAmount(address cause, uint256 amount) internal {
        
        for (uint256 index = 0; index < sponsoredCausesAmounts.length; index++) {
            if( cause==sponsoredCausesAmounts[index].sponsoredCauseAddress ){
                sponsoredCausesAmounts[index].amount += amount;
            }
        }
    }

    /**
     * Get top tipper
     */
    function getTopTipper() external view onlyOwner returns (address tipper, uint256 amount){
        return (topTipper.tipperAdress, topTipper.amount);
    }

    /**
     * Get number of sponsored causes
     */
    function getSponsoredCausesCount() external view returns (uint256) {
        return sponsoredCauses.length;
    }

    /**
     * Deactivate contract
     */
    function deactivateContract() external onlyOwner {
        active = false;
    }

    /**
     * Check if contract is active
     */
    function isContractActive() external view returns (bool) {
        return active;
    }

    /**
     * Address of the contract owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}
