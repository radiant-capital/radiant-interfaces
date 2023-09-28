// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./IMintableToken.sol";
import "./LockedBalance.sol";
import "./IFeeDistribution.sol";
import "./IChefIncentivesController.sol";
import "./IMiddleFeeDistribution.sol";

interface IMultiFeeDistribution {
	event Locked(address indexed user, uint256 amount, uint256 lockedBalance, uint256 indexed lockLength, bool isLP);
	event Withdrawn(
		address indexed user,
		uint256 receivedAmount,
		uint256 lockedBalance,
		uint256 penalty,
		uint256 burn,
		bool isLP
	);
	event RewardPaid(address indexed user, address indexed rewardToken, uint256 reward);
	event Relocked(address indexed user, uint256 amount, uint256 lockIndex);
	event BountyManagerUpdated(address indexed _bounty);
	event RewardConverterUpdated(address indexed _rewardConverter);
	event LockTypeInfoUpdated(uint256[] lockPeriod, uint256[] rewardMultipliers);
	event AddressesUpdated(
		IChefIncentivesController _controller,
		IMiddleFeeDistribution _middleFeeDistribution,
		address indexed _treasury
	);
	event LPTokenUpdated(address indexed _stakingToken);
	event RewardAdded(address indexed _rewardToken);
	event LockerAdded(address indexed locker);
	event LockerRemoved(address indexed locker);

	/**
	 * @dev Initializer
	 *  First reward MUST be the RDNT token or things will break
	 *  related to the 50% penalty and distribution to locked balances.
	 * @param rdntToken_ RDNT token address
	 * @param lockZap_ LockZap contract address
	 * @param dao_ DAO address
	 * @param priceProvider_ PriceProvider contract address
	 * @param rewardsDuration_ Duration that rewards are streamed over
	 * @param rewardsLookback_ Duration that rewards loop back
	 * @param lockDuration_ lock duration
	 * @param burnRatio_ Proportion of burn amount
	 * @param vestDuration_ vest duration
	 */
	function initialize(
		address rdntToken_,
		address lockZap_,
		address dao_,
		address priceProvider_,
		uint256 rewardsDuration_,
		uint256 rewardsLookback_,
		uint256 lockDuration_,
		uint256 burnRatio_,
		uint256 vestDuration_
	) external;

	/**
	 * @notice Set minters
	 * @dev Can be called only once
	 * @param minters_ array of address
	 */
	function setMinters(address[] calldata minters_) external;

	/**
	 * @notice Sets bounty manager contract.
	 * @param bounty contract address
	 */
	function setBountyManager(address bounty) external;

	/**
	 * @notice Sets reward converter contract.
	 * @param rewardConverter_ contract address
	 */
	function addRewardConverter(address rewardConverter_) external;

	/**
	 * @notice Sets lock period and reward multipliers.
	 * @param lockPeriod_ lock period array
	 * @param rewardMultipliers_ multipliers per lock period
	 */
	function setLockTypeInfo(uint256[] calldata lockPeriod_, uint256[] calldata rewardMultipliers_) external;

	/**
	 * @notice Set CIC, MFD and Treasury.
	 * @param controller_ CIC address
	 * @param middleFeeDistribution_ address
	 * @param treasury_ address
	 */
	function setAddresses(
		IChefIncentivesController controller_,
		IMiddleFeeDistribution middleFeeDistribution_,
		address treasury_
	) external;

	/**
	 * @notice Set LP token.
	 * @param stakingToken_ LP token address
	 */
	function setLPToken(address stakingToken_) external;

	/**
	 * @notice Add a new reward token to be distributed to stakers.
	 * @param rewardToken address
	 */
	function addReward(address rewardToken) external;

	/**
	 * @notice Remove an existing reward token.
	 * @param _rewardToken address to be removed
	 */
	function removeReward(address _rewardToken) external;

	/**
	 * @notice Set default lock type index for user relock.
	 * @param index of default lock length
	 */
	function setDefaultRelockTypeIndex(uint256 index) external;

	/**
	 * @notice Sets option if auto compound is enabled.
	 * @param status true if auto compounding is enabled.
	 * @param slippage the maximum amount of slippage that the user will incur for each compounding trade
	 */
	function setAutocompound(bool status, uint256 slippage) external;

	/**
	 * @notice Set what slippage to use for tokens traded during the auto compound process on behalf of the user
	 * @param slippage the maximum amount of slippage that the user will incur for each compounding trade
	 */
	function setUserSlippage(uint256 slippage) external;

	/**
	 * @notice Toggle a users autocompound status
	 */
	function toggleAutocompound() external;

	/**
	 * @notice Set relock status
	 * @param status true if auto relock is enabled.
	 */
	function setRelock(bool status) external virtual;

	/**
	 * @notice Sets the lookback period
	 * @param lookback in seconds
	 */
	function setLookback(uint256 lookback) external;

	/**
	 * @notice Stake tokens to receive rewards.
	 * @dev Locked tokens cannot be withdrawn for defaultLockDuration and are eligible to receive rewards.
	 * @param amount to stake.
	 * @param onBehalfOf address for staking.
	 * @param typeIndex lock type index.
	 */
	function stake(uint256 amount, address onBehalfOf, uint256 typeIndex) external;

	/**
	 * @notice Add to earnings
	 * @dev Minted tokens receive rewards normally but incur a 50% penalty when
	 *  withdrawn before vestDuration has passed.
	 * @param user vesting owner.
	 * @param amount to vest.
	 * @param withPenalty does this bear penalty?
	 */
	function vestTokens(address user, uint256 amount, bool withPenalty) external;

	/**
	 * @notice Withdraw tokens from earnings and unlocked.
	 * @dev First withdraws unlocked tokens, then earned tokens. Withdrawing earned tokens
	 *  incurs a 50% penalty which is distributed based on locked balances.
	 * @param amount for withdraw
	 */
	function withdraw(uint256 amount) external;

	/**
	 * @notice Withdraw individual unlocked balance and earnings, optionally claim pending rewards.
	 * @param claimRewards true to claim rewards when exit
	 * @param unlockTime of earning
	 */
	function individualEarlyExit(bool claimRewards, uint256 unlockTime) external;

	/**
	 * @notice Withdraw full unlocked balance and earnings, optionally claim pending rewards.
	 * @param claimRewards true to claim rewards when exit
	 */
	function exit(bool claimRewards) external;

	/**
	 * @notice Claim all pending staking rewards.
	 */
	function getAllRewards() external;

	/**
	 * @notice Withdraw expired locks with options
	 * @param address_ for withdraw
	 * @param limit_ of lock length for withdraw
	 * @param isRelockAction_ option to relock
	 * @return withdraw amount
	 */
	function withdrawExpiredLocksForWithOptions(
		address address_,
		uint256 limit_,
		bool isRelockAction_
	) external returns (uint256);

	/**
	 * @notice Zap vesting RDNT tokens to LP
	 * @param user address
	 * @return zapped amount
	 */
	function zapVestingToLp(address user) external returns (uint256 zapped);

	/**
	 * @notice Claim rewards by converter.
	 * @dev Rewards are transfered to converter. In the Radiant Capital protocol
	 * 		the role of the Converter is taken over by Compounder.sol.
	 * @param onBehalf address to claim.
	 */
	function claimFromConverter(address onBehalf) external;

	/**
	 * @notice Withdraw and restake assets.
	 */
	function relock() external;

	/**
	 * @notice Requalify user
	 */
	function requalify() external;

	/**
	 * @notice Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders.
	 * @param tokenAddress to recover.
	 * @param tokenAmount to recover.
	 */
	function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

	/**
	 * @notice Return lock duration.
	 */
	function getLockDurations() external view returns (uint256[] memory);

	/**
	 * @notice Return reward multipliers.
	 */
	function getLockMultipliers() external view returns (uint256[] memory);

	/**
	 * @notice Returns all locks of a user.
	 * @param user address.
	 * @return lockInfo of the user.
	 */
	function lockInfo(address user) external view returns (LockedBalance[] memory);

	/**
	 * @notice Total balance of an account, including unlocked, locked and earned tokens.
	 * @param user address.
	 */
	function totalBalance(address user) external view returns (uint256);

	/**
	 * @notice Returns price provider address
	 */
	function getPriceProvider() external view returns (address);

	/**
	 * @notice Reward amount of the duration.
	 * @param rewardToken for the reward
	 * @return reward amount for duration
	 */
	function getRewardForDuration(address rewardToken) external view returns (uint256);

	/**
	 * @notice Total balance of an account, including unlocked, locked and earned tokens.
	 * @param user address of the user for which the balances are fetched
	 */
	function getBalances(address user) external view returns (Balances memory);

	/**
	 * @notice Claims bounty.
	 * @dev Remove expired locks
	 * @param user address
	 * @param execute true if this is actual execution
	 * @return issueBaseBounty true if needs to issue base bounty
	 */
	function claimBounty(address user, bool execute) external returns (bool issueBaseBounty);

	/**
	 * @notice Claim all pending staking rewards.
	 * @param rewardTokens_ array of reward tokens
	 */
	function getReward(address[] memory rewardTokens_) external;

	/**
	 * @notice Pause MFD functionalities
	 */
	function pause() external;

	/**
	 * @notice Resume MFD functionalities
	 */
	function unpause() external;

	/**
	 * @notice Requalify user for reward elgibility
	 * @param user address
	 */
	function requalifyFor(address user) external;

	/**
	 * @notice Information on a user's lockings
	 * @return total balance of locks
	 * @return unlockable balance
	 * @return locked balance
	 * @return lockedWithMultiplier
	 * @return lockData which is an array of locks
	 */
	function lockedBalances(
		address user
	)
		external
		view
		returns (
			uint256 total,
			uint256 unlockable,
			uint256 locked,
			uint256 lockedWithMultiplier,
			LockedBalance[] memory lockData
		);

	/**
	 * @notice Reward locked amount of the user.
	 * @param user address
	 * @return locked amount
	 */
	function lockedBalance(address user) external view returns (uint256 locked);

	/**
	 * @notice Earnings which are vesting, and earnings which have vested for full duration.
	 * @dev Earned balances may be withdrawn immediately, but will incur a penalty between 25-90%, based on a linear schedule of elapsed time.
	 * @return totalVesting sum of vesting tokens
	 * @return unlocked earnings
	 * @return earningsData which is an array of all infos
	 */
	function earnedBalances(
		address user
	) external view returns (uint256 totalVesting, uint256 unlocked, EarnedBalance[] memory earningsData);

	/**
	 * @notice Final balance received and penalty balance paid by user upon calling exit.
	 * @dev This is earnings, not locks.
	 * @param user address.
	 * @return amount total withdrawable amount.
	 * @return penaltyAmount penalty amount.
	 * @return burnAmount amount to burn.
	 */
	function withdrawableBalance(
		address user
	) external view returns (uint256 amount, uint256 penaltyAmount, uint256 burnAmount);

	/**
	 * @notice Returns reward applicable timestamp.
	 * @param rewardToken for the reward
	 * @return end time of reward period
	 */
	function lastTimeRewardApplicable(address rewardToken) external view returns (uint256);

	/**
	 * @notice Reward amount per token
	 * @dev Reward is distributed only for locks.
	 * @param rewardToken for reward
	 * @return rptStored current RPT with accumulated rewards
	 */
	function rewardPerToken(address rewardToken) external view returns (uint256 rptStored);

	/**
	 * @notice Address and claimable amount of all reward tokens for the given account.
	 * @param account for rewards
	 * @return rewardsData array of rewards
	 */
	function claimableRewards(address account) external view returns (IFeeDistribution.RewardData[] memory rewardsData);
}
