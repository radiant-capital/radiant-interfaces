// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./IOnwardIncentivesController.sol";
import "./ILeverager.sol";

interface IChefIncentivesController {
	// Info of each user.
	// reward = user.`amount` * pool.`accRewardPerShare` - `rewardDebt`
	struct UserInfo {
		uint256 amount;
		uint256 rewardDebt;
		uint256 lastClaimTime;
	}

	// Info of each pool.
	struct PoolInfo {
		uint256 totalSupply;
		uint256 allocPoint; // How many allocation points assigned to this pool.
		uint256 lastRewardTime; // Last second that reward distribution occurs.
		uint256 accRewardPerShare; // Accumulated rewards per share, times ACC_REWARD_PRECISION. See below.
		IOnwardIncentivesController onwardIncentives;
	}

	// Info about token emissions for a given time period.
	struct EmissionPoint {
		uint128 startTimeOffset;
		uint128 rewardsPerSecond;
	}

	// Info about ending time of reward emissions
	struct EndingTime {
		uint256 estimatedTime;
		uint256 lastUpdatedTime;
		uint256 updateCadence;
	}

	// Emitted when rewardPerSecond is updated
	event RewardsPerSecondUpdated(uint256 indexed rewardsPerSecond, bool persist);

	event BalanceUpdated(address indexed token, address indexed user, uint256 balance, uint256 totalSupply);

	event EmissionScheduleAppended(uint256[] startTimeOffsets, uint256[] rewardsPerSeconds);

	event ChefReserveLow(uint256 indexed _balance);

	event Disqualified(address indexed user);

	event OnwardIncentivesUpdated(address indexed _token, IOnwardIncentivesController _incentives);

	event BountyManagerUpdated(address indexed _bountyManager);

	event EligibilityEnabledUpdated(bool indexed _newVal);

	event BatchAllocPointsUpdated(address[] _tokens, uint256[] _allocPoints);

	event LeveragerUpdated(ILeverager _leverager);

	event EndingTimeUpdateCadence(uint256 indexed _lapse);

	event RewardDeposit(uint256 indexed _amount);

	/**
	 * @notice Initializer
	 * @param _poolConfigurator Pool configurator address
	 * @param _eligibleDataProvider Eligibility Data provider address
	 * @param _rewardMinter Middle fee distribution contract
	 * @param _rewardsPerSecond RPS
	 */
	function initialize(
		address _poolConfigurator,
		IEligibilityDataProvider _eligibleDataProvider,
		IMiddleFeeDistribution _rewardMinter,
		uint256 _rewardsPerSecond
	) external;

	/**
	 * @dev Returns length of reward pools.
	 */
	function poolLength() public view returns (uint256);

	/**
	 * @notice Sets incentive controllers for custom token.
	 * @param _token for reward pool
	 * @param _incentives incentives contract address
	 */
	function setOnwardIncentives(address _token, IOnwardIncentivesController _incentives) external;

	/**
	 * @dev Updates bounty manager contract.
	 * @param _bountyManager Bounty Manager contract.
	 */
	function setBountyManager(address _bountyManager) external;

	/**
	 * @dev Enable/Disable eligibility
	 * @param _newVal New value.
	 */
	function setEligibilityEnabled(bool _newVal) external;

	/**
	 * @dev Starts RDNT emission.
	 */
	function start() external;

	/**
	 * @dev Add a new lp to the pool. Can only be called by the poolConfigurator.
	 * @param _token for reward pool
	 * @param _allocPoint allocation point of the pool
	 */
	function addPool(address _token, uint256 _allocPoint) external;

	/**
	 * @dev Update the given pool's allocation point. Can only be called by the owner.
	 * @param _tokens for reward pools
	 * @param _allocPoints allocation points of the pools
	 */
	function batchUpdateAllocPoint(address[] calldata _tokens, uint256[] calldata _allocPoints) external;

	/**
	 * @notice Sets the reward per second to be distributed. Can only be called by the owner.
	 * @dev Its decimals count is ACC_REWARD_PRECISION
	 * @param _rewardsPerSecond The amount of reward to be distributed per second.
	 * @param _persist true if RPS is fixed, otherwise RPS is by emission schedule.
	 */
	function setRewardsPerSecond(uint256 _rewardsPerSecond, bool _persist) external;

	/**
	 * @notice Updates RDNT emission schedule.
	 * @dev This appends the new offsets and RPS.
	 * @param _startTimeOffsets Offsets array.
	 * @param _rewardsPerSecond RPS array.
	 */
	function setEmissionSchedule(uint256[] calldata _startTimeOffsets, uint256[] calldata _rewardsPerSecond) external;

	/**
	 * @notice Recover tokens in this contract. Callable by owner.
	 * @param tokenAddress Token address for recover
	 * @param tokenAmount Amount to recover
	 */
	function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

	/**
	 * @notice Pending rewards of a user.
	 * @param _user address for claim
	 * @param _tokens array of reward-bearing tokens
	 * @return claimable rewards array
	 */
	function pendingRewards(address _user, address[] memory _tokens) external view returns (uint256[] memory);

	/**
	 * @notice Claim rewards. They are vested into MFD.
	 * @param _user address for claim
	 * @param _tokens array of reward-bearing tokens
	 */
	function claim(address _user, address[] memory _tokens) external;

	/**
	 * @notice Exempt a contract from eligibility check.
	 * @dev Can be called by owner or leverager contract
	 * @param _contract address to exempt
	 * @param _value flag for exempt
	 */
	function setEligibilityExempt(address _contract, bool _value) external;

	/**
	 * @notice Updates leverager, only callable by owner.
	 * @param _leverager contract
	 */
	function setLeverager(ILeverager _leverager) external;

	/**
	 * @notice `after` Hook for deposit and borrow update.
	 * @dev important! eligible status can be updated here
	 * @param _user address
	 * @param _balance balance of token
	 * @param _totalSupply total supply of the token
	 */
	function handleActionAfter(address _user, uint256 _balance, uint256 _totalSupply) external;

	/**
	 * @notice `before` Hook for deposit and borrow update.
	 * @param _user address
	 */
	function handleActionBefore(address _user) external;

	/**
	 * @notice Hook for lock update.
	 * @dev Called by the locking contracts before locking or unlocking happens
	 * @param _user address
	 */
	function beforeLockUpdate(address _user) external;

	/**
	 * @notice Hook for lock update.
	 * @dev Called by the locking contracts after locking or unlocking happens
	 * @param _user address
	 */
	function afterLockUpdate(address _user) external;

	/**
	 * @notice Claim bounty
	 * @param _user address of recipient
	 * @param _execute true if it's actual execution
	 * @return issueBaseBounty true for base bounty
	 */
	function claimBounty(address _user, bool _execute) external returns (bool issueBaseBounty);

	/**
	 * @notice Ending reward distribution time.
	 */
	function endRewardTime() external returns (uint256);

	/**
	 * @notice Updates cadence duration of ending time.
	 * @dev Only callable by owner.
	 * @param _lapse new cadence
	 */
	function setEndingTimeUpdateCadence(uint256 _lapse) external;

	/**
	 * @notice Add new rewards.
	 * @dev Only callable by owner.
	 * @param _amount new deposit amount
	 */
	function registerRewardDeposit(uint256 _amount) external;

	/**
	 * @notice Available reward amount for future distribution.
	 * @dev This value is equal to `depositedRewards` - `accountedRewards`.
	 * @return amount available
	 */
	function availableRewards() internal view returns (uint256 amount);

	/**
	 * @notice Claim rewards entitled to all registered tokens.
	 * @param _user address of the user
	 */
	function claimAll(address _user) external;

	/**
	 * @notice Sum of all pending RDNT rewards.
	 * @param _user address of the user
	 * @return pending reward amount
	 */
	function allPendingRewards(address _user) external view returns (uint256 pending);

	/**
	 * @notice Pause the claim operations.
	 */
	function pause() external;

	/**
	 * @notice Unpause the claim operations.
	 */
	function unpause() external;
}
