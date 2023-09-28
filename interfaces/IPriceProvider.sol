// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./IChainlinkAdapter.sol";
import "./IPoolHelper.sol";

interface IPriceProvider {
	event OracleUpdated(address indexed _newOracle);

	event PoolHelperUpdated(address indexed _poolHelper);

	event AggregatorUpdated(address indexed _baseTokenPriceInUsdProxyAggregator);

	event UsePoolUpdated(bool indexed _usePool);

	/**
	 * @notice Initializer
	 * @param _baseAssetChainlinkAdapter Chainlink aggregator for USD price of base token
	 * @param _poolHelper Pool helper contract - Uniswap/Balancer
	 */
	function initialize(IChainlinkAdapter _baseAssetChainlinkAdapter, IPoolHelper _poolHelper) external;

	/**
	 * @notice Update oracles.
	 */
	function update() external;

	/**
	 * @notice Returns the latest price in eth.
	 */
	function getTokenPrice() external view returns (uint256 priceInEth);

	/**
	 * @notice Returns the latest price in USD.
	 */
	function getTokenPriceUsd() external view returns (uint256 price);

	/**
	 * @notice Returns lp token price in ETH.
	 */
	function getLpTokenPrice() external view returns (uint256);

	/**
	 * @notice Returns lp token price in USD.
	 */
	function getLpTokenPriceUsd() external view returns (uint256 price);

	/**
	 * @notice Returns lp token address.
	 */
	function getLpTokenAddress() external view returns (address);

	/**
	 * @notice Sets new oracle.
	 */
	function setOracle(address _newOracle) external;

	/**
	 * @notice Sets pool helper contract.
	 */
	function setPoolHelper(address _poolHelper) external;

	/**
	 * @notice Sets base token price aggregator.
	 */
	function setAggregator(address _baseAssetChainlinkAdapter) external;

	/**
	 * @notice Sets option to use pool.
	 */
	function setUsePool(bool _usePool) external;

	/**
	 * @notice Returns decimals of price.
	 */
	function decimals() external pure returns (uint256);
}
