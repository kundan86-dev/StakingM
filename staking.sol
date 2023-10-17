// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


    contract Staking is Ownable{
    IERC20 public token;

    constructor(address _token){
    token= IERC20(_token);
    }


    struct stakerInfo{
    address user;
    uint amountStake;
    uint time;
    uint tenure;

    }

    stakerInfo[] public stakeInformation;


    mapping (address=>uint256[]) public id; //addess => array of ids
    mapping (uint256=>uint256) public timeid;//id=>time


    function stake(uint256 _stakeAmount, uint256 _time) public returns (stakerInfo memory) {
    require(_stakeAmount > 0, "Stake amount must be non-zero");
    require(token.balanceOf(msg.sender) >= _stakeAmount, "Insufficient balance");
    require(_time == 2 || _time == 4 || _time == 6 || _time == 8 || _time == 10, "Time can only be in even minutes and less than or equal to 10");

    uint256 startTime = block.timestamp;
    token.transferFrom(msg.sender, address(this), _stakeAmount);

    stakeInformation.push(stakerInfo(msg.sender, _stakeAmount, _time, startTime));
    uint256 _id = stakeInformation.length;
    id[msg.sender].push(_id);

    return stakeInformation[_id - 1]; // index here
}

        function min(uint256 a, uint256 b) public pure returns (uint256){
        return (a < b) ? a : b;
    }

    function calculateReward(uint256 _id) public view returns(uint256) {
        stakerInfo memory information=stakeInformation[_id-1];
        uint256 currentTenure=information.tenure;
        uint256 currentTime=information.time;
        uint256 reward;
         
         if(currentTenure==2){
            reward=(((min(currentTime,currentTenure*60)*information.amountStake)*1)/100);

         }
         else if(currentTenure==4){
            reward=(((min(currentTime,currentTenure*60)*information.amountStake)*2)/100);
         }

           else if(currentTenure==6){
            reward=(((min(currentTime,currentTenure*60)*information.amountStake)*3)/100);
         }
           else if(currentTenure==8){
            reward=(((min(currentTime,currentTenure*60)*information.amountStake)*4)/100);
         }
           else
            reward=(((min(currentTime,currentTenure*60)*information.amountStake)*5)/100);
         
            return reward;


    }

    function claimAmount(uint256 _id) public {
        stakerInfo memory _information = stakeInformation[_id-1];
        require(_information.user != address(0), " this id does not exist");
        require(msg.sender == _information.user, "You not claim this amount because you are not owner of this id");
        require(stakeInformation[_id-1].tenure == 0, "You only claim amount after claiming reward");
        require(block.timestamp -timeid[_id] >= 120, "You can claim amount only after 2 minutes from the time of Claim Rewards");
        timeid[_id] = 0;
        uint256 amount = _information.amountStake;
        require(token.balanceOf(address(this)) >= amount, "Sorry contract have no enough tokens");
        token.transfer(_information.user, amount);
        stakeInformation[_id-1].user = address(0);
        stakeInformation[_id-1].amountStake = 0;
        timeid[_id] = 0;
    }

      function claimRewards(uint256 _id) public {
        require(stakeInformation.length >= _id, "This id does not exist");
        stakerInfo memory _information = stakeInformation[_id-1];
        require(_information.user != address(0), "You use this ID before at present time this id does not exist");
        require(msg.sender == _information.user, "You not claim this reward because you are not owner of this id");
        uint256 _time = block.timestamp-(_information.time+_information.tenure);
        require(_time > 0, "You does not claim reward because maturity period is not completed");
        uint256 reward = calculateReward(_id);
        require(token.balanceOf(address(this)) >= reward, "Sorry contract have no enough tokens. We resolve this problem shortly");
        timeid[_id] = block.timestamp;
        token.transfer(_information.user , reward);
        stakeInformation[_id-1].tenure = 0;
        stakeInformation[_id-1].time = 0;
    }
        function getStakeContractBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }  

     function idByAddress(address _user) public view returns(uint256 [] memory){
        return id[_user];
    }

   function getDetails(uint256 _id) public view returns (stakerInfo memory) {
        return stakeInformation[_id-1];
    }


    function getStakingDetails(uint256 _id) public view returns (address user, uint256 amountStaked, uint256 tenure, uint256 time, uint256 claimableReward) {
    require(_id <= stakeInformation.length, "Invalid staking ID");

    stakerInfo memory info = stakeInformation[_id - 1];
    uint256 reward = calculateReward(_id);

    return (info.user, info.amountStake, info.tenure, info.time, reward);
}

 function calculateRewardTillTime(uint256 _id) public view returns (uint256, uint256) {
        require(stakeInformation.length>=_id,"Invalid input: Input id doesnt exist");
        stakerInfo memory _info = stakeInformation[_id-1];
        require(_info.user != address(0) , "This address corresonding to id is already used");
        uint256 currentTime = block.timestamp - _info.time;
        uint256 currentTenure = _info.tenure;
        return (calculateReward(_id),min(currentTime,currentTenure));
    }




// function calculateReward(uint256 _id) public view returns(uint256) {
//     stakerInfo memory information = stakeInformation[_id - 1];
//     uint256 currentTenure = information.tenure;
//     uint256 currentTime = information.time;
//     uint256 reward;

//     if (currentTenure >= 1 && currentTenure <= 5) {
//         // Calculate reward based on tenure: 10% for tenure 1, 12% for tenure 2, 13% for tenure 3, and so on till tenure 5
//         reward = ((min(currentTime, currentTenure * 60) * information.amountStake * (10 + (currentTenure - 1))) / 100);
//     } else {
//         // Handle other tenures here, if necessary
//         reward = 0;
//     }

//     return reward;
// }


}
















//mytoke=0x32431CD7d9dB85c1D904749Fc78c61684B628EEC
//staking -0xc789E36FF720d062a3d4EEdb07DC81eBC0a9C9e3