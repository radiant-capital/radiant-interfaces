// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./IMintableToken.sol";
import "./IMultiFeeDistribution.sol";
import "./IAaveProtocolDataProvider.sol";

interface IMiddleFeeDistribution {
	/// @notice Emitted when reward token is forwarded
	event ForwardReward(address indexed token, uint256 amount);

	/// @notice Emitted when operation expenses is set
	event OperationExpensesUpdated(address indexed _operationExpenses, uint256 _operationExpenseRatio);

	event NewTransferAdded(address indexed asset, uint256 lpUsdValue);

	event AdminUpdated(address indexed _configurator);

	event RewardsUpdated(address indexed _rewardsToken);

	event ProtocolDataProviderUpdated(address indexed _providerAddress);

	/**
	 * @notice Initializer
	 * @param rdntToken_ RDNT address
	 * @param aaveOracle_ Aave oracle address
	 * @param multiFeeDistribution_ Multi fee distribution contract
	 */
	function initialize(
		IMintableToken rdntToken_,
		address aaveOracle_,
		IMultiFeeDistribution multiFeeDistribution_,
		IAaveProtocolDataProvider aaveProtocolDataProvider_
	) external;

	/**
	 * @notice Set operation expenses account
	 * @param _operationExpenses Address to receive operation expenses
	 * @param _operationExpenseRatio Proportion of operation expense
	 */
	function setOperationExpenses(address _operationExpenses, uint256 _operationExpenseRatio) external;

	/**
	 * @notice Sets pool configurator as admin.
	 * @param _configurator Configurator address
	 */
	function setAdmin(address _configurator) external;

	/**
	 * @notice Set the Protocol Data Provider address
	 * @param _providerAddress The address of the protocol data provider contract
	 */
	function setProtocolDataProvider(IAaveProtocolDataProvider _providerAddress) external;

	/**
	 * @notice Add a new reward token to be distributed to stakers
	 * @param _rewardsToken address of the reward token
	 */
	function addReward(address _rewardsToken) external;

	/**
	 * @notice Remove an existing reward token
	 */
	function removeReward(address _rewardsToken) external;

	/**
	 * @notice Run by MFD to pull pending platform revenue
	 * @param _rewardTokens an array of reward token addresses
	 */
	function forwardReward(address[] memory _rewardTokens) external;

	/**
	 * @notice Returns RDNT token address.
	 * @return RDNT token address
	 */
	function getRdntTokenAddress() external view returns (address);

	/**
	 * @notice Returns MFD address.
	 * @return MFD address
	 */
	function getMultiFeeDistributionAddress() external view returns (address);

	/**
	 * @notice Added to support recovering any ERC20 tokens inside the contract
	 * @param tokenAddress address of erc20 token to recover
	 * @param tokenAmount amount to recover
	 */
	function recoverERC20(address tokenAddress, uint256 tokenAmount) external;
}
