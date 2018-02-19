pragma solidity ^0.4.17;

contract Adoption {
  // 保存领养者的地址
  address[16] public adopters;

  //领养宠物
  function adopt(uint petId) public returns(uint) {
    // 确保id在数组长度内
    require(petId >=0 && petId <= 15);

    //保存调用地址
    adopters[petId] = msg.sender;
    return petId;
  }

  // 返回领养者
  function getAdopters() public view returns (address[16]) {
    return adopters;
  }
}
