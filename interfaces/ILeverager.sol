// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./ILendingPool.sol";
import "./IEligibilityDataProvider.sol";

interface ILeverager {
	/// @notice Emitted when fee ratio is updated
	event FeePercentUpdated(uint256 indexed _feePercent);

	/// @notice Emitted when treasury is updated
	event TreasuryUpdated(address indexed _treasury);

	/**
	 * @notice Initializer
	 * @param _lendingPool Address of lending pool.
	 * @param _rewardEligibleDataProvider EligibilityProvider address.
	 * @param _aaveOracle address.
	 * @param _lockZap address.
	 * @param _cic address.
	 * @param _weth WETH address.
	 * @param _feePercent leveraging fee ratio.
	 * @param _treasury address.
	 */
	function initialize(
		ILendingPool _lendingPool,
		IEligibilityDataProvider _rewardEligibleDataProvider,
		IAaveOracle _aaveOracle,
		ILockZap _lockZap,
		IChefIncentivesController _cic,
		IWETH _weth,
		uint256 _feePercent,
		address _treasury
	) external;

	/**
	 * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
	 */
	receive() external payable;

	/**
	 * @dev Revert fallback calls
	 */
	fallback() external payable;

	/**
	 * @notice Sets fee ratio
	 * @param _feePercent fee ratio.
	 */
	function setFeePercent(uint256 _feePercent) external;

	/**
	 * @notice Sets fee ratio
	 * @param _treasury address
	 */
	function setTreasury(address _treasury) external;

	/**
	 * @dev Returns the configuration of the reserve
	 * @param asset The address of the underlying asset of the reserve
	 * @return The configuration of the reserve
	 **/
	function getConfiguration(address asset) external view returns (DataTypes.ReserveConfigurationMap memory);

	/**
	 * @dev Returns variable debt token address of asset
	 * @param asset The address of the underlying asset of the reserve
	 * @return varaiableDebtToken address of the asset
	 **/
	function getVDebtToken(address asset) external view returns (address);

	/**
	 * @dev Returns loan to value
	 * @param asset The address of the underlying asset of the reserve
	 * @return ltv of the asset
	 **/
	function ltv(address asset) external view returns (uint256);

	/**
	 * @dev Loop the deposit and borrow of an asset
	 * @param asset for loop
	 * @param amount for the initial deposit
	 * @param interestRateMode stable or variable borrow mode
	 * @param borrowRatio Ratio of tokens to borrow
	 * @param loopCount Repeat count for loop
	 * @param isBorrow true when the loop without deposit tokens
	 **/
	function loop(
		address asset,
		uint256 amount,
		uint256 interestRateMode,
		uint256 borrowRatio,
		uint256 loopCount,
		bool isBorrow
	) external;

	/**
	 * @dev Loop the deposit and borrow of ETH
	 * @param interestRateMode stable or variable borrow mode
	 * @param borrowRatio Ratio of tokens to borrow
	 * @param loopCount Repeat count for loop
	 **/
	function loopETH(uint256 interestRateMode, uint256 borrowRatio, uint256 loopCount) external payable;

	/**
	 * @dev Loop the borrow and deposit of ETH
	 * @param interestRateMode stable or variable borrow mode
	 * @param amount initial amount to borrow
	 * @param borrowRatio Ratio of tokens to borrow
	 * @param loopCount Repeat count for loop
	 **/
	function loopETHFromBorrow(
		uint256 interestRateMode,
		uint256 amount,
		uint256 borrowRatio,
		uint256 loopCount
	) external;

	/**
	 * @notice Return estimated zap WETH amount for eligbility after loop.
	 * @param user for zap
	 * @param asset src token
	 * @param amount of `asset`
	 * @param borrowRatio Single ratio of borrow
	 * @param loopCount Repeat count for loop
	 * @return WETH amount
	 **/
	function wethToZapEstimation(
		address user,
		address asset,
		uint256 amount,
		uint256 borrowRatio,
		uint256 loopCount
	) external view returns (uint256);

	/**
	 * @notice Return estimated zap WETH amount for eligbility.
	 * @param user for zap
	 * @return WETH amount
	 **/
	function wethToZap(address user) external view returns (uint256);

	/**
	 * @notice Zap WETH by borrowing.
	 * @param amount to zap
	 * @param borrower to zap
	 * @return liquidity amount by zapping
	 **/
	function zapWETHWithBorrow(uint256 amount, address borrower) external returns (uint256 liquidity);

	/**
	 * @notice Set the CIC contract address
	 * @param _cic CIC contract address
	 */
	function setChefIncentivesController(IChefIncentivesController _cic) external;
}
