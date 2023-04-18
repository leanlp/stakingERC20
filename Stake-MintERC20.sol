pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract StakingContract is Ownable {
    IERC20 public stakingToken;
    RewardToken public rewardToken;
    uint256 public constant REWARD_RATE = 1e18; // 100% anual
    uint256 public constant SECONDS_IN_YEAR = 31536000;
    
    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }
    
    mapping(address => Stake) public stakes;
    
    constructor(IERC20 _stakingToken, string memory _rewardTokenName, string memory _rewardTokenSymbol) {
        stakingToken = _stakingToken;
        rewardToken = new RewardToken(_rewardTokenName, _rewardTokenSymbol);
        rewardToken.transferOwnership(address(this));
    }
    
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        Stake storage userStake = stakes[msg.sender];
        userStake.amount += _amount;
        userStake.timestamp = block.timestamp;
    }
    
    function withdraw() external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No stake found");
        
        uint256 stakingDuration = block.timestamp - userStake.timestamp;
        uint256 reward = (userStake.amount * REWARD_RATE * stakingDuration) / (SECONDS_IN_YEAR * 1e18);
        
        rewardToken.mint(msg.sender, reward);
        stakingToken.transfer(msg.sender, userStake.amount);
        
        delete stakes[msg.sender];
    }
}
