pragma solidity ^0.4.17;

// 引入断言
import "truffle/Assert.sol";
// 用来获取被测试的智能合约地址
import "truffle/DeployedAddresses.sol";
//被测试的合约
import "../contracts/Adoption.sol";

contract TestAdoption {
  Adoption adoption = Adoption(DeployedAddresses.Adoption());

  //领养测试用例
  function testUserCanAdoptPet() public {
    uint returnedId = adoption.adopt(8);

    uint expected = 8;
    Assert.equal(returnedId, expected, "领养id为8的宠物成功!");
  }

  // 宠物所有者测试用例
  function testGetAdopterAddressByPetId() public {
    // 期望领养者的地址就是本合约地址, 因为交易是由测试合约发起交易
    address expected = this;
    address adopter = adoption.adopters(8);
    Assert.equal(adopter, expected, "id为8的宠物属于管理者");
  }

  // 测试所有领养者
  function testGetAdopterAddressByPetIdInArray() public {
    // 领养者的地址就是本合约地址
    address expected = this;
    address[16] memory adopters = adoption.getAdopters();
    Assert.equal(adopters[8], expected, "");
  }
}
