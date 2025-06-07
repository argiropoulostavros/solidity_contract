// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * Contract to tip content creators
 * while also supporting sponsored causes
 */
contract ContentCreatorTipping {
    // State variables
    address public owner; // Contract deployer
    address[] private sponsoredCauses; // Array of sponsored cause addresses (private for security)
    uint256 public totalTipsRaised; // Total amount raised across all tips
    TopTipper private topTipper; // Private - only owner can access
    struct TopTipper {
        address tipperAdress;
        uint256 amount;
    }

    // Events
    event TipMade(address indexed tipper, uint256 amount);

    // Modifiers

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier contractActive() {
        require(owner != address(0), "Contract has been deactivated");
        _;
    }

    /**
     * Constructor - sets up sponsored causes at deployment
     */
    constructor(address[] memory initSponsoredCauses) {
        require(
            initSponsoredCauses.length > 0,
            "At least one sponsored cause required"
        );

        // Validate that all sponsored cause addresses are valid
        for (uint i = 0; i < initSponsoredCauses.length; i++) {
            require(
                initSponsoredCauses[i] != address(0),
                "Invalid sponsored cause address"
            );
        }

        owner = msg.sender;
        sponsoredCauses = initSponsoredCauses;
    }

    /**
     * Tip with 10% going to sponsored cause
     */
    function tip(address creatorAddress, uint256 sponsorCauseIndex) external payable contractActive {
        require(msg.value > 0, "Tip amount must be greater than zero");
        require(sponsorCauseIndex < sponsoredCauses.length, "Invalid sponsor cause index");

        uint256 tipAmount = msg.value;
        // Calculate amounts: 10% to sponsor, 90% to creator
        uint256 sponsorAmount = (tipAmount * 10) / 100;
        uint256 creatorAmount = tipAmount - sponsorAmount;

        // Transfer funds
        address cause = sponsoredCauses[sponsorCauseIndex]; 
        payable(cause).transfer(sponsorAmount);
        payable(creatorAddress).transfer(creatorAmount);

        // Update tracking variables
        totalTipsRaised += tipAmount;
        setTopTipper(msg.sender, tipAmount);

        // Emit event
        emit TipMade(msg.sender, tipAmount);
    }

    /**
     * Tip with custom amount and percentage validation
     */
    function tip(address creatorAddress, uint256 sponsorCauseIndex, uint256 tipAmountWei) external payable contractActive {
        require(msg.value >= tipAmountWei, "Insufficient funds sent");
        require(tipAmountWei > 0, "Tip amount must be greater than zero");
        require(sponsorCauseIndex < sponsoredCauses.length, "Invalid sponsor cause index");

        // Calculate sponsor amount (10% of tip)
        uint256 sponsorAmount = (tipAmountWei * 10) / 100;

        // Validate donation limits: at least 1% and at most 50% of total transfer
        require(
            sponsorAmount >= (msg.value * 1) / 100,
            "Donation too small - must be at least 1% of total"
        );
        require(
            sponsorAmount <= (msg.value * 50) / 100,
            "Donation too large - cannot exceed 50% of total"
        );

        uint256 creatorAmount = tipAmountWei - sponsorAmount;

        // Transfer funds
        payable(sponsoredCauses[sponsorCauseIndex]).transfer(sponsorAmount);
        payable(creatorAddress).transfer(creatorAmount);

        // Return excess funds if any
        if (msg.value > tipAmountWei) {
            payable(msg.sender).transfer(msg.value - tipAmountWei);
        }

        // Update tracking variables
        totalTipsRaised += tipAmountWei;
        setTopTipper(msg.sender, tipAmountWei);

        // Emit event
        emit TipMade(msg.sender, tipAmountWei);
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
     * Get top tipper information
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
     * Deactivate contract - renders it unusable (only owner)
     * This is irreversible and will prevent all future tipping
     */
    function deactivateContract() external onlyOwner {
        owner = address(0); // Setting owner to zero address makes contract unusable
    }

    /**
     * Check if contract is still active
     * @return true if contract is active, false if deactivated
     */
    function isContractActive() external view returns (bool) {
        return owner != address(0);
    }

    /**
     * @dev Get contract owner address
     * @return Address of the contract owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}
