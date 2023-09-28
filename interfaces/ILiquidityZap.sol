// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.12;

interface ILiquidityZap {
	/**
	 * @notice Initialize liquidity zap param
	 * @param token_ RDNT address
	 * @param weth_ WETH address
	 * @param tokenWethPair_ LP pair
	 * @param helper_ Pool helper contract
	 */
	function initLiquidityZap(address token_, address weth_, address tokenWethPair_, address helper_) external;

	fallback() external payable;

	receive() external payable;

	/**
	 * @notice Set Price Provider.
	 * @param _provider Price provider contract address.
	 */
	function setPriceProvider(address _provider) external;

	/**
	 * @notice Set Acceptable Ratio.
	 * @param _acceptableRatio Acceptable slippage ratio.
	 */
	function setAcceptableRatio(uint256 _acceptableRatio) external;

	/**
	 * @notice Zap ethereum
	 * @param _onBehalf of the user
	 * @return liquidity lp amount
	 */
	function zapETH(address payable _onBehalf) external payable returns (uint256);

	/**
	 * @notice Add liquidity with WETH
	 * @param _amount of WETH
	 * @param to address of lp token
	 * @return liquidity lp amount
	 */
	function addLiquidityWETHOnly(uint256 _amount, address payable to) external returns (uint256);

	/**
	 * @notice Add liquidity with ETH
	 * @param to address of lp token
	 * @return liquidity lp amount
	 */
	function addLiquidityETHOnly(address payable to) external payable returns (uint256);

	/**
	 * @notice Quote WETH amount from RDNT
	 * @param tokenAmount RDNT amount
	 * @return optimalWETHAmount Output WETH amount
	 */
	function quoteFromToken(uint256 tokenAmount) external view returns (uint256 optimalWETHAmount);

	/**
	 * @notice Quote RDNT amount from WETH
	 * @param wethAmount RDNT amount
	 * @return optimalTokenAmount Output RDNT amount
	 */
	function quote(uint256 wethAmount) external view returns (uint256 optimalTokenAmount);

	/**
	 * @notice Add liquidity with RDNT and WETH
	 * @dev use with quote
	 * @param tokenAmount RDNT amount
	 * @param _wethAmt WETH amount
	 * @param to LP address to be transferred
	 * @return liquidity LP amount
	 */
	function standardAdd(uint256 tokenAmount, uint256 _wethAmt, address payable to) external returns (uint256);

	/**
	 * @notice LP token amount entitled with ETH
	 * @param ethAmt ETH amount
	 * @return liquidity LP amount
	 */
	function getLPTokenPerEthUnit(uint256 ethAmt) external view returns (uint256 liquidity);
}
