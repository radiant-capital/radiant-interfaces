// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./IChefIncentivesController.sol";
import "./ILendingPool.sol";
import "./IMiddleFeeDistribution.sol";

interface IEligibilityDataProvider {
	/// @notice Emitted when CIC is set
	event ChefIncentivesControllerUpdated(IChefIncentivesController indexed _chef);

	/// @notice Emitted when LP token is set
	event LPTokenUpdated(address indexed _lpToken);

	/// @notice Emitted when required TVL ratio is updated
	event RequiredDepositRatioUpdated(uint256 indexed requiredDepositRatio);

	/// @notice Emitted when price tolerance ratio is updated
	event PriceToleranceRatioUpdated(uint256 indexed priceToleranceRatio);

	/// @notice Emitted when DQ time is set
	event DqTimeUpdated(address indexed _user, uint256 _time);

	/**
	 * @notice Constructor
	 * @param _lendingPool Address of lending pool.
	 * @param _middleFeeDistribution MiddleFeeDistribution address.
	 * @param _priceProvider PriceProvider address.
	 */
	function initialize(
		ILendingPool _lendingPool,
		IMiddleFeeDistribution _middleFeeDistribution,
		IPriceProvider _priceProvider
	) public;

	/**
	 * @notice Set LP token
	 */
	function setLPToken(address _lpToken) external;

	/**
	 * @notice Sets required tvl ratio. Can only be called by the owner.
	 * @param _requiredDepositRatio Ratio in bips.
	 */
	function setRequiredDepositRatio(uint256 _requiredDepositRatio) external;

	/**
	 * @notice Sets price tolerance ratio. Can only be called by the owner.
	 * @param _priceToleranceRatio Ratio in bips.
	 */
	function setPriceToleranceRatio(uint256 _priceToleranceRatio) external;

	/**
	 * @notice Sets DQ time of the user
	 * @dev Only callable by CIC
	 * @param _user's address
	 * @param _time for DQ
	 */
	function setDqTime(address _user, uint256 _time) external;

	/**
	 * @notice Returns locked RDNT and LP token value in eth
	 * @param user's address
	 */
	function lockedUsdValue(address user) external view returns (uint256);

	/**
	 * @notice Returns USD value required to be locked
	 * @param user's address
	 * @return required USD value.
	 */
	function requiredUsdValue(address user) external view returns (uint256 required);

	/**
	 * @notice Returns if the user is eligible to receive rewards
	 * @param _user's address
	 */
	function isEligibleForRewards(address _user) external view returns (bool);

	/**
	 * @notice Returns DQ time of the user
	 * @param _user's address
	 */
	function getDqTime(address _user) external view returns (uint256);

	/**
	 * @notice Returns last eligible time of the user
	 * @dev If user is still eligible, it will return future time
	 *  CAUTION: this function only works perfect when the array
	 *  is ordered by lock time. This is assured when _stake happens.
	 * @param user's address
	 * @return lastEligibleTimestamp of the user. Returns 0 if user is not eligible.
	 */
	function lastEligibleTime(address user) external view returns (uint256 lastEligibleTimestamp);

	/**
	 * @notice Refresh token amount for eligibility
	 * @param user The address of the user
	 * @return currentEligibility The current eligibility status of the user
	 */
	function refresh(address user) external returns (bool currentEligibility);

	/**
	 * @notice Update token price
	 */
	function updatePrice() public;
}
