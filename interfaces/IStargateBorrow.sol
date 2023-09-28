// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./IStargateRouter.sol";
import "./IRouterETH.sol";
import "./ILendingPool.sol";
import "./IWETH.sol";

/// @title Interface for StargateBorrow
/// @author Radiant
interface IStargateBorrow {
	/// @notice Emitted when DAO address is updated
	event DAOTreasuryUpdated(address indexed _daoTreasury);

	/// @notice Emitted when fee info is updated
	event XChainBorrowFeePercentUpdated(uint256 indexed percent);

	/// @notice Emited when pool ids of assets are updated
	event PoolIDsUpdated(address[] assets, uint256[] poolIDs);

	/**
	 * @notice Constructor
	 * @param _router Stargate Router address
	 * @param _routerETH Stargate Router for ETH
	 * @param _lendingPool Lending pool
	 * @param _weth WETH address
	 * @param _treasury Treasury address
	 * @param _xChainBorrowFeePercent Cross chain borrow fee ratio
	 */
	function initialize(
		IStargateRouter _router,
		IRouterETH _routerETH,
		ILendingPool _lendingPool,
		IWETH _weth,
		address _treasury,
		uint256 _xChainBorrowFeePercent,
		uint256 _maxSlippage
	) external;

	receive() external payable;

	/**
	 * @notice Set DAO Treasury.
	 * @param _daoTreasury DAO Treasury address.
	 */
	function setDAOTreasury(address _daoTreasury) external;

	/**
	 * @notice Set Cross Chain Borrow Fee Percent.
	 * @param percent Fee ratio.
	 */
	function setXChainBorrowFeePercent(uint256 percent) external;

	/**
	 * @notice Set pool ids of assets.
	 * @param assets array.
	 * @param poolIDs array.
	 */
	function setPoolIDs(address[] calldata assets, uint256[] calldata poolIDs) external;

	/**
	 * @notice Set max slippage allowed for StarGate bridge Swaps.
	 * @param _maxSlippage Max slippage allowed.
	 */
	function setMaxSlippage(uint256 _maxSlippage) external;

	/**
	 * @notice Get Cross Chain Borrow Fee amount.
	 * @param amount Fee cost.
	 * @return Fee amount for cross chain borrow
	 */
	function getXChainBorrowFeeAmount(uint256 amount) external view returns (uint256);

	/**
	 * @notice Quote LZ swap fee
	 * @dev Call Router.sol method to get the value for swap()
	 * @param _dstChainId dest LZ chain id
	 * @param _functionType function type
	 * @param _toAddress address
	 * @param _transferAndCallPayload payload to call after transfer
	 * @param _lzTxParams transaction params
	 * @return Message Fee
	 * @return amount of wei in source gas token
	 */
	function quoteLayerZeroSwapFee(
		uint16 _dstChainId,
		uint8 _functionType,
		bytes calldata _toAddress,
		bytes calldata _transferAndCallPayload,
		IStargateRouter.lzTxObj calldata _lzTxParams
	) external view returns (uint256, uint256);

	/**
	 * @dev Borrow asset for another chain
	 * @param asset for loop
	 * @param amount for the initial deposit
	 * @param interestRateMode stable or variable borrow mode
	 * @param dstChainId Destination chain id
	 **/
	function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 dstChainId) external payable;

	/**
	 * @notice Allows owner to recover ETH locked in this contract.
	 * @param to ETH receiver
	 * @param value ETH amount
	 */
	function withdrawLockedETH(address to, uint256 value) external;
}
