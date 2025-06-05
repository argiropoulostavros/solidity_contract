// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title ContentCreatorTipping
 * @dev Smart contract for tipping content creators while supporting sponsored causes
 * @notice This contract facilitates tips to creators with automatic donations to sponsored causes
 */
contract ContentCreatorTipping {
    // State variables
    address private owner; // Contract deployer
    address[] private sponsoredCauses; // Array of sponsored cause addresses (private for security)
    uint256 public totalTipsRaised; // Total amount raised across all tips

    // Struct to track highest tipper information
    struct HighestTipper {
        address tipper;
        uint256 amount;
    }

    HighestTipper private highestTipper; // Private - only owner can access

    // Events
    event TipMade(address indexed tipper, uint256 amount);

    // Modifiers

    /**
     * @dev Restricts access to contract owner only
     */
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner can call this function"
        );
        _;
    }

    /**
     * @dev Ensures contract is not destroyed/unusable
     */
    modifier contractActive() {
        require(owner != address(0), "Contract has been deactivated");
        _;
    }

    /**
     * @dev Constructor - sets up sponsored causes at deployment
     * @param _sponsoredCauses Array of addresses for sponsored causes
     */
    constructor(address[] memory _sponsoredCauses) {
        require(
            _sponsoredCauses.length > 0,
            "At least one sponsored cause required"
        );

        // Validate that all sponsored cause addresses are valid
        for (uint i = 0; i < _sponsoredCauses.length; i++) {
            require(
                _sponsoredCauses[i] != address(0),
                "Invalid sponsored cause address"
            );
        }

        owner = msg.sender;
        sponsoredCauses = _sponsoredCauses;
    }

    /**
     * @dev First variation: Tip with 10% going to sponsored cause
     * @param creatorAddress Address of the content creator to tip
     * @param sponsorIndex Index of the sponsored cause (0-based)
     */
    function tip(
        address payable creatorAddress,
        uint256 sponsorIndex
    ) external payable contractActive {
        require(msg.value > 0, "Tip amount must be greater than zero");
        require(creatorAddress != address(0), "Invalid creator address");
        require(
            sponsorIndex < sponsoredCauses.length,
            "Invalid sponsor cause index"
        );

        uint256 tipAmount = msg.value;

        // Calculate amounts: 10% to sponsor, 90% to creator
        uint256 sponsorAmount = (tipAmount * 10) / 100;
        uint256 creatorAmount = tipAmount - sponsorAmount;

        // Transfer funds
        payable(sponsoredCauses[sponsorIndex]).transfer(sponsorAmount);
        creatorAddress.transfer(creatorAmount);

        // Update tracking variables
        totalTipsRaised += tipAmount;
        _updateHighestTipper(msg.sender, tipAmount);

        // Emit event
        emit TipMade(msg.sender, tipAmount);
    }

    /**
     * @dev Second variation: Tip with custom amount and percentage validation
     * @param creatorAddress Address of the content creator to tip
     * @param sponsorIndex Index of the sponsored cause (0-based)
     * @param tipAmountWei The amount to tip in wei
     */
    function tip(
        address payable creatorAddress,
        uint256 sponsorIndex,
        uint256 tipAmountWei
    ) external payable contractActive {
        require(msg.value >= tipAmountWei, "Insufficient funds sent");
        require(tipAmountWei > 0, "Tip amount must be greater than zero");
        require(creatorAddress != address(0), "Invalid creator address");
        require(
            sponsorIndex < sponsoredCauses.length,
            "Invalid sponsor cause index"
        );

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
        payable(sponsoredCauses[sponsorIndex]).transfer(sponsorAmount);
        creatorAddress.transfer(creatorAmount);

        // Return excess funds if any
        if (msg.value > tipAmountWei) {
            payable(msg.sender).transfer(msg.value - tipAmountWei);
        }

        // Update tracking variables
        totalTipsRaised += tipAmountWei;
        _updateHighestTipper(msg.sender, tipAmountWei);

        // Emit event
        emit TipMade(msg.sender, tipAmountWei);
    }

    /**
     * @dev Internal function to update highest tipper tracking
     * @param tipper Address of the current tipper
     * @param amount Amount tipped
     */
    function _updateHighestTipper(address tipper, uint256 amount) internal {
        if (amount > highestTipper.amount) {
            highestTipper.tipper = tipper;
            highestTipper.amount = amount;
        }
    }

    /**
     * @dev Get highest tipper information - only accessible by contract owner
     * @return tipper Address of highest tipper
     * @return amount Amount of highest tip
     */
    function getHighestTipper()
        external
        view
        onlyOwner
        returns (address tipper, uint256 amount)
    {
        return (highestTipper.tipper, highestTipper.amount);
    }

    /**
     * @dev Get the number of sponsored causes available
     * @return Number of sponsored causes (useful for UI to validate indexes)
     */
    function getSponsoredCausesCount() external view returns (uint256) {
        return sponsoredCauses.length;
    }

    /**
     * @dev Deactivate contract - renders it unusable (only owner)
     * @notice This is irreversible and will prevent all future tipping
     */
    function deactivateContract() external onlyOwner {
        owner = address(0); // Setting owner to zero address makes contract unusable
    }

    /**
     * @dev Check if contract is still active
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
