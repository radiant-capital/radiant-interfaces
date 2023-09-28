// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./balancer/IWeightedPoolFactory.sol";

interface IBalancerPoolHelper {
	/**
	 * @notice Initializer
	 * @param _inTokenAddr input token of the pool
	 * @param _outTokenAddr output token of the pool
	 * @param _wethAddr WETH address
	 * @param _vault Balancer Vault
	 * @param _poolFactory Balancer pool factory address
	 */
	function initialize(
		address _inTokenAddr,
		address _outTokenAddr,
		address _wethAddr,
		address _vault,
		IWeightedPoolFactory _poolFactory
	) external;
}
