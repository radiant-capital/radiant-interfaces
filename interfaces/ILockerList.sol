// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface ILockerList {
	event LockerAdded(address indexed locker);
	event LockerRemoved(address indexed locker);

	/**
	 * @notice Return the number of users.
	 * @return count The number of users
	 */
	function lockersCount() external view returns (uint256 count);

	/**
	 * @notice Return the list of users.
	 * @dev This is a very gas intensive function to execute and thus should only by utilized by off-chain entities.
	 * @param page The page number to retrieve
	 * @param limit The number of entries per page
	 * @return users A paginated list of users
	 */
	function getUsers(uint256 page, uint256 limit) external view returns (address[] memory users);

	/**
	 * @notice Add a locker.
	 * @dev This can be called only by the owner. Owner should be MFD contract.
	 * @param user address to be added
	 */
	function addToList(address user) external;

	/**
	 * @notice Remove a locker.
	 * @dev This can be called only by the owner. Owner should be MFD contract.
	 * @param user address to remove
	 */
	function removeFromList(address user) external;
}
