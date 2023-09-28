// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./balancer/IWeightedPoolFactory.sol";

interface IPoolHelper {
	function lpTokenAddr() external view returns (address);

	/**
	 * @notice Zap WETH
	 * @param amount to zap
	 * @return liquidity token amount
	 */
	function zapWETH(uint256 amount) external returns (uint256 liquidity);

	/**
	 * @notice Zap WETH and RDNT
	 * @param _wethAmt WETH amount
	 * @param _rdntAmt RDNT amount
	 * @return liquidity token amount
	 */
	function zapTokens(uint256 _wethAmt, uint256 _rdntAmt) external returns (uint256 liquidity);

	/**
	 * @notice Calculate quote in WETH from token
	 * @param tokenAmount RDNT amount
	 * @return optimalWETHAmount WETH amount
	 */
	function quoteFromToken(uint256 tokenAmount) external view returns (uint256 optimalWETHAmount);

	/**
	 * @notice Set lockzap contract
	 */
	function setLockZap(address _lockZap) external;

	/**
	 * @notice Gets needed WETH for adding LP
	 * @param lpAmount LP amount
	 * @return wethAmount WETH amount
	 */
	function quoteWETH(uint256 lpAmount) external view returns (uint256 wethAmount);

	/**
	 * @notice Calculates LP price
	 * @dev Return value decimal is 8
	 * @param rdntPriceInEth RDNT price in ETH
	 * @return priceInEth LP price in ETH
	 */
	function getLpPrice(uint256 rdntPriceInEth) external view returns (uint256 priceInEth);

	/**
	 * @notice Returns reserve information.
	 * @return rdnt RDNT amount
	 * @return weth WETH amount
	 * @return lpTokenSupply LP token supply
	 */
	function getReserves() external view returns (uint256 rdnt, uint256 weth, uint256 lpTokenSupply);

	/**
	 * @notice Returns RDNT price in WETH
	 * @return RDNT price
	 */
	function getPrice() external view returns (uint256);

	/**
	 * @notice Calculate tokenAmount from WETH
	 * @param _inToken input token
	 * @param _wethAmount WETH amount
	 * @return tokenAmount token amount
	 */
	function quoteSwap(address _inToken, uint256 _wethAmount) external view returns (uint256 tokenAmount);

	/**
	 * @notice Swaps tokens like USDC, DAI, USDT, WBTC to WETH
	 * @param _inToken address of the asset to swap
	 * @param _amount the amount of asset to swap
	 * @param _minAmountOut the minimum WETH amount to accept without reverting
	 */
	function swapToWeth(address _inToken, uint256 _amount, uint256 _minAmountOut) external;

	/**
	 * @notice Get swap fee percentage
	 */
	function getSwapFeePercentage() external view returns (uint256 fee);

	/**
	 * @notice Set swap fee percentage
	 */
	function setSwapFeePercentage(uint256 _fee) external;
}

interface IBalancerPoolHelper is IPoolHelper {
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

	/**
	 * @notice Initialize a new pool.
	 * @param _tokenName Token name of lp token
	 * @param _tokenSymbol Token symbol of lp token
	 */
	function initializePool(string calldata _tokenName, string calldata _tokenSymbol) external;
}

interface IUniswapPoolHelper is IPoolHelper {
	/**
	 * @notice Initialize RDNT/WETH pool and liquidity zap
	 */
	function initializePool() external;
}
