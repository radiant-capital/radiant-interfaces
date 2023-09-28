// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IBountyManager {
	event MinStakeAmountUpdated(uint256 indexed _minStakeAmount);
	event BaseBountyUsdTargetUpdated(uint256 indexed _newVal);
	event HunterShareUpdated(uint256 indexed _newVal);
	event MaxBaseBountyUpdated(uint256 indexed _newVal);
	event BountiesSet();
	event BountyReserveEmpty(uint256 indexed _bal);
	event WhitelistUpdated(address indexed _user, bool indexed _isActive);
	event WhitelistActiveChanged(bool indexed isActive);

	/**
	 * @notice Initialize
	 * @param _rdnt RDNT address
	 * @param _weth WETH address
	 * @param _mfd MFD, to send bounties as vesting RDNT to Hunter (user calling bounty)
	 * @param _chef CIC, to query bounties for ineligible emissions
	 * @param _priceProvider PriceProvider service, to get RDNT price for bounty quotes
	 * @param _eligibilityDataProvider Eligibility data provider
	 * @param _compounder Compounder address
	 * @param _hunterShare % of reclaimed rewards to send to Hunter
	 * @param _baseBountyUsdTarget Base Bounty is paid in RDNT, will scale to match this USD target value
	 * @param _maxBaseBounty cap the scaling above
	 */
	function initialize(
		address _rdnt,
		address _weth,
		address _mfd,
		address _chef,
		address _priceProvider,
		address _eligibilityDataProvider,
		address _compounder,
		uint256 _hunterShare,
		uint256 _baseBountyUsdTarget,
		uint256 _maxBaseBounty
	) external;

	/**
	 * @notice Given a user, return their bounty amount. uses staticcall to run same bounty aglo, but without execution
	 * @param _user address
	 * @return bounty amount of RDNT Hunter will recieve.
	 * can be a fixed amt (Base Bounty) or dynamic amt based on rewards removed from target user during execution (ineligible revenue, autocompound fee)
	 * @return actionType which of the 3 bounty types (above) to run.
	 * _getAvailableBounty returns this based on priority (expired locks first, then inelig emissions, then autocompound)
	 */
	function quote(address _user) external view returns (uint256 bounty, uint256 actionType);

	/**
	 * @notice Execute a bounty.
	 * @param _user address
	 * can be a fixed amt (Base Bounty) or dynamic amt based on rewards removed from target user during execution (ineligible revenue, autocompound fee)
	 * @param _actionType which of the 3 bounty types (above) to run.
	 * @return bounty in RDNT to be paid to Hunter (via vesting)
	 * @return actionType which bounty ran
	 */
	function claim(address _user, uint256 _actionType) external returns (uint256, uint256);

	/**
	 * @notice Execute the most appropriate bounty on a user, check returned amount for slippage, calc amount going to Hunter, send to vesting.
	 * @param _user address
	 * @param _execute whether to execute this txn, or just quote what its execution would return
	 * can be a fixed amt (Base Bounty) or dynamic amt based on rewards removed from target user during execution (ineligible revenue, autocompound fee)
	 * @param _actionType which of the 3 bounty types (above) to run.
	 * @return bounty in RDNT to be paid to Hunter (via vesting)
	 * @return actionType which bounty ran
	 */
	function executeBounty(
		address _user,
		bool _execute,
		uint256 _actionType
	) external returns (uint256 bounty, uint256 actionType);

	/**
	 * @notice Return RDNT amount for Base Bounty.
	 * Base Bounty used to incentivize operations that don't generate their own reward to pay to Hunter.
	 * @return bounty in RDNT
	 */
	function getBaseBounty() external view returns (uint256);

	/**
	 * @notice Minimum locked lp balance
	 */
	function minDLPBalance() external view returns (uint256 min);

	/**
	 * @notice Sets minimum stake amount.
	 * @dev Only owner can call this function.
	 * @param _minStakeAmount Minimum stake amount
	 */
	function setMinStakeAmount(uint256 _minStakeAmount) external;

	/**
	 * @notice Sets target price of base bounty.
	 * @dev Only owner can call this function.
	 * @param _newVal New USD value
	 */
	function setBaseBountyUsdTarget(uint256 _newVal) external;

	/**
	 * @notice Sets hunter's share ratio.
	 * @dev Only owner can call this function.
	 * @param _newVal New hunter share ratio
	 */
	function setHunterShare(uint256 _newVal) external;

	/**
	 * @notice Updates maximum base bounty.
	 * @dev Only owner can call this function.
	 * @param _newVal Maximum base bounty
	 */
	function setMaxBaseBounty(uint256 _newVal) external;

	/**
	 * @notice Set bounty operations.
	 * @dev Only owner can call this function.
	 */
	function setBounties() external;

	/**
	 * @notice Recover ERC20 tokens from the contract.
	 * @param tokenAddress Token address to recover
	 * @param tokenAmount Amount to recover
	 */
	function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

	/**
	 * @notice Add new address to whitelist.
	 * @param user address
	 * @param status for whitelist
	 */
	function addAddressToWL(address user, bool status) external;

	/**
	 * @notice Update whitelist active status.
	 * @param status New whitelist status
	 */
	function changeWL(bool status) external;

	/**
	 * @notice Pause the bounty operations.
	 */
	function pause() external;

	/**
	 * @notice Unpause the bounty operations.
	 */
	function unpause() external;
}
