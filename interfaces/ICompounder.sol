// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface ICompounder {
	/// @notice Emitted when routes are updated
	event RoutesUpdated(address _token, address[] _routes);

	/// @notice Emitted when bounty manager is updated
	event BountyManagerUpdated(address indexed _manager);

	/// @notice Emitted when compounding fee is updated
	event CompoundFeeUpdated(uint256 indexed _compoundFee);

	/// @notice Emitted when slippage limit is updated
	event SlippageLimitUpdated(uint256 indexed _slippageLimit);

	/**
	 * @notice Initializer
	 * @param _uniRouter Address of swap router
	 * @param _mfd Address of MFD
	 * @param _baseToken Address of pair asset of RDNT LP
	 * @param _addressProvider Address of LendingPoolAddressesProvider
	 * @param _lockZap Address of LockZap contract
	 * @param _compoundFee Compounding fee
	 * @param _slippageLimit Slippage limit
	 */
	function initialize(
		address _uniRouter,
		address _mfd,
		address _baseToken,
		address _addressProvider,
		address _lockZap,
		uint256 _compoundFee,
		uint256 _slippageLimit
	) external;

	/**
	 * @notice Pause contract
	 */
	function pause() external;

	/**
	 * @notice Unpause contract
	 */
	function unpause() external;

	/**
	 * @notice Set swap routes
	 * @param _token Token for swap
	 * @param _routes Swap route for token
	 */
	function setRoutes(address _token, address[] memory _routes) external;

	/**
	 * @notice Set bounty manager
	 * @param _manager Bounty manager address
	 */
	function setBountyManager(address _manager) external;

	/**
	 * @notice Sets the fee for compounding.
	 * @param _compoundFee fee ratio for compounding
	 */
	function setCompoundFee(uint256 _compoundFee) external;

	/**
	 * @notice Sets slippage limit.
	 * @param _slippageLimit new slippage limit
	 */
	function setSlippageLimit(uint256 _slippageLimit) external;

	/**
	 * @notice Compound user's rewards
	 * @dev Can be auto compound or manual compound
	 * @param _user user address
	 * @param _execute whether to execute txn, or just quote (expected amount out for bounty executor)
	 * @param _slippage that shouldn't be exceeded when performing swaps
	 * @return fee amount
	 */
	function claimCompound(address _user, bool _execute, uint256 _slippage) external returns (uint256 fee);

	/**
	 * @notice Compound `msg.sender`'s rewards.
	 * @param _slippage that shouldn't be exceeded when performing swaps
	 */
	function selfCompound(uint256 _slippage) external;

	/**
	 * @notice Returns the pending rewards of the `_user`
	 * @param _user owner of rewards
	 * @return tokens array of reward token addresses
	 * @return amts array of reward amounts
	 */
	function viewPendingRewards(address _user) external view returns (address[] memory tokens, uint256[] memory amts);

	/**
	 * @notice Returns minimum stake amount in ETH
	 * @return minStakeAmtEth Minimum stake amount in ETH
	 */
	function autocompoundThreshold() external view returns (uint256 minStakeAmtEth);

	/**
	 * @notice Returns if user is eligbile for auto compounding
	 * @param _user address
	 * @param _pending amount
	 * @return True or False
	 */
	function isEligibleForAutoCompound(address _user, uint256 _pending) external view returns (bool);

	/**
	 * @notice Returns if pending amount is elgible for auto compounding
	 * @param _pending amount
	 * @return eligible True or False
	 */
	function isEligibleForCompound(uint256 _pending) external view returns (bool eligible);

	/**
	 * @notice Returns if the user is eligible for auto compound
	 * @param _user address
	 * @return eligible `true` or `false`
	 */
	function userEligibleForCompound(address _user) external view returns (bool eligible);

	/**
	 * @notice Returns if the `msg.sender` is eligible for self compound
	 * @return eligible `true` or `false`
	 */
	function selfEligibleCompound() external view returns (bool eligible);
}
