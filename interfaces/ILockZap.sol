// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./IPoolHelper.sol";
import "./ILendingPool.sol";
import "./IWETH.sol";
import "./IAaveOracle.sol";

interface ILockZap {
	/// @notice Emitted when zap is done
	event Zapped(
		bool _borrow,
		uint256 _ethAmt,
		uint256 _rdntAmt,
		address indexed _from,
		address indexed _onBehalf,
		uint256 _lockTypeIndex
	);

	event PriceProviderUpdated(address indexed _provider);

	event MfdUpdated(address indexed _mfdAddr);

	event PoolHelperUpdated(address indexed _poolHelper);

	event UniRouterUpdated(address indexed _uniRouter);

	/**
	 * @notice Initializer
	 * @param _rndtPoolHelper Pool helper address used for RDNT-WETH swaps
	 * @param _uniRouter UniV2 router address used for all non RDNT-WETH swaps
	 * @param _lendingPool Lending pool
	 * @param _weth weth address
	 * @param _rdntAddr RDNT token address
	 * @param _ethLPRatio ratio of ETH in the LP token, can be 2000 for an 80/20 bal lp
	 * @param _aaveOracle Aave oracle address
	 */
	function initialize(
		IPoolHelper _rndtPoolHelper,
		address _uniRouter,
		ILendingPool _lendingPool,
		IWETH _weth,
		address _rdntAddr,
		uint256 _ethLPRatio,
		IAaveOracle _aaveOracle
	) external;

	receive() external payable;

	/**
	 * @notice Set Price Provider.
	 * @param _provider Price provider contract address.
	 */
	function setPriceProvider(address _provider) external;

	/**
	 * @notice Set AAVE Oracle used to fetch asset prices in USD.
	 * @param _aaveOracle oracle contract address.
	 */
	function setAaveOracle(address _aaveOracle) external;

	/**
	 * @notice Set Multi fee distribution contract.
	 * @param _mfdAddr New contract address.
	 */
	function setMfd(address _mfdAddr) external;

	/**
	 * @notice Set Pool Helper contract used fror WETH-RDNT swaps
	 * @param _poolHelper New PoolHelper contract address.
	 */
	function setPoolHelper(address _poolHelper) external;

	/**
	 * @notice Set Univ2 style router contract address used for all non RDNT<>WETH swaps
	 * @param _uniRouter New PoolHelper contract address.
	 */
	function setUniRouter(address _uniRouter) external;

	/**
	 * @notice Returns pool helper address used for RDNT-WETH swaps
	 */
	function getPoolHelper() external view returns (address);

	/**
	 * @notice Returns uni router address used for all non RDNT-WETH swaps
	 */
	function getUniRouter() external view returns (address);

	/**
	 * @notice Get Variable debt token address
	 * @param _asset underlying.
	 */
	function getVDebtToken(address _asset) external view returns (address);

	/**
	 * @notice Calculate amount of specified tokens received for selling RDNT
	 * @dev this function is mainly used to calculate how much of the specified token is needed to match the provided RDNT amount when providing liquidity to an AMM
	 * @param _token address of the token that would be received
	 * @param _amount of RDNT to be sold
	 * @return amount of _token received
	 */
	function quoteFromToken(address _token, uint256 _amount) external view returns (uint256);

	/**
	 * @notice Zap tokens to stake LP
	 * @param _borrow option to borrow ETH
	 * @param _asset to be used for zapping
	 * @param _assetAmt amount of weth.
	 * @param _rdntAmt amount of RDNT.
	 * @param _lockTypeIndex lock length index.
	 * @param _slippage maximum amount of slippage allowed for any occurring trades
	 * @return LP amount
	 */
	function zap(
		bool _borrow,
		address _asset,
		uint256 _assetAmt,
		uint256 _rdntAmt,
		uint256 _lockTypeIndex,
		uint256 _slippage
	) external payable returns (uint256);

	/**
	 * @notice Zap tokens to stake LP
	 * @dev It will use default lock index
	 * @param _borrow option to borrow ETH
	 * @param _asset to be used for zapping
	 * @param _assetAmt amount of weth.
	 * @param _rdntAmt amount of RDNT.
	 * @param _onBehalf user address to be zapped.
	 * @param _slippage maximum amount of slippage allowed for any occurring trades
	 * @return LP amount
	 */
	function zapOnBehalf(
		bool _borrow,
		address _asset,
		uint256 _assetAmt,
		uint256 _rdntAmt,
		address _onBehalf,
		uint256 _slippage
	) external payable returns (uint256);

	/**
	 * @notice Zap tokens from vesting
	 * @param _borrow option to borrow ETH
	 * @param _asset to be used for zapping
	 * @param _assetAmt amount of _asset tokens used to create dLP position
	 * @param _lockTypeIndex lock length index. cannot be shortest option (index 0)
	 * @param _slippage maximum amount of slippage allowed for any occurring trades
	 * @return LP amount
	 */
	function zapFromVesting(
		bool _borrow,
		address _asset,
		uint256 _assetAmt,
		uint256 _lockTypeIndex,
		uint256 _slippage
	) external payable returns (uint256);

	/**
	 * @notice Pause zapping operation.
	 */
	function pause() external;

	/**
	 * @notice Unpause zapping operation.
	 */
	function unpause() external;

	/**
	 * @notice Allows owner to recover ETH locked in this contract.
	 * @param to ETH receiver
	 * @param value ETH amount
	 */
	function withdrawLockedETH(address to, uint256 value) external;
}
