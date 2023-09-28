// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./IPriceProvider.sol";

interface IRadiantOFT {
	/// @notice Emitted when fee ratio is updated
	event FeeRatioUpdated(uint256 indexed fee);

	/// @notice Emitted when PriceProvider is updated
	event PriceProviderUpdated(IPriceProvider indexed priceProvider);

	/// @notice Emitted when Treasury is updated
	event TreasuryUpdated(address indexed treasury);

	/**
	 * @notice Burn tokens.
	 * @param _amount to burn
	 */
	function burn(uint256 _amount) external;

	/**
	 * @notice Pause bridge operation.
	 */
	function pause() external;

	/**
	 * @notice Unpause bridge operation.
	 */
	function unpause() external;

	/**
	 * @notice Returns LZ fee + Bridge fee
	 * @dev overrides default OFT estimate fee function to add native fee
	 * @param _dstChainId dest LZ chain id
	 * @param _toAddress to addr on dst chain
	 * @param _amount amount to bridge
	 * @param _useZro use ZRO token, someday ;)
	 * @param _adapterParams LZ adapter params
	 */
	function estimateSendFee(
		uint16 _dstChainId,
		bytes32 _toAddress,
		uint256 _amount,
		bool _useZro,
		bytes calldata _adapterParams
	) external view returns (uint256 nativeFee, uint256 zroFee);

	/**
	 * @notice Bridge fee amount
	 * @param _rdntAmount amount for bridge
	 * @return bridgeFee calculated bridge fee
	 */
	function getBridgeFee(uint256 _rdntAmount) external view returns (uint256 bridgeFee);

	/**
	 * @notice Set fee info
	 * @param _feeRatio ratio
	 */
	function setFeeRatio(uint256 _feeRatio) external;

	/**
	 * @notice Set price provider
	 * @param _priceProvider address
	 */
	function setPriceProvider(IPriceProvider _priceProvider) external;

	/**
	 * @notice Set Treasury
	 * @param _treasury address
	 */
	function setTreasury(address _treasury) external;
}
