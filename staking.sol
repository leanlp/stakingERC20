pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingToken is ERC20 {
    using SafeMath for uint256;

    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake) public stakes;

    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed user, uint256 amount);

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Staking amount must be greater than 0");

        _transfer(msg.sender, address(this), _amount);
        stakes[msg.sender].amount = stakes[msg.sender].amount.add(_amount);
        stakes[msg.sender].timestamp = block.timestamp;

        emit Staked(msg.sender, _amount, block.timestamp);
    }

    function unstake(uint256 _amount) external {
        require(stakes[msg.sender].amount >= _amount, "Insufficient staking balance");

        stakes[msg.sender].amount = stakes[msg.sender].amount.sub(_amount);
        _transfer(address(this), msg.sender, _amount);

        emit Unstaked(msg.sender, _amount);
    }

    function getStake(address _user) external view returns (uint256) {
        return stakes[_user].amount;
    }

    function getStakeTimestamp(address _user) external view returns (uint256) {
        return stakes[_user].timestamp;
    }
}
