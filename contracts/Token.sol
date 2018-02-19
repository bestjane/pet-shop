pragma solidity ^0.4.16;

interface tokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

contract TokenERC20 {
  // 代币名称
  string public name;
  // 代币符号
  string public symbol;
  // 表示可以有的小数点位数, 18是建议的默认值
  uint8 public decimals = 18;
  uint256 public totalSupply;

  // 用mapping保存每个地址对应的余额
  mapping (address => uint256) public balanceOf;
  // 存储对账号的控制
  mapping (address => mapping (address => uint256) ) public allowance;

  // 事件, 用来通知客户端交易发生
  event Transfer(address indexed from, address indexed to, uint256 value);

  // 事件, 用来通知客户端代币被消费
  event Burn(address indexed from, uint256 value);

  // 初始化
  function TokenERC20(uint256 initialSupply, string tokenname, string tokenSymbol) public {
    // 货币总量 = 币数 * 10 ** 最小单位
    totalSupply = initialSupply * 10 ** uint256(decimals);
    // 创建者所拥有的代币
    balanceOf[msg.sender] = totalSupply;
    // 代币名称
    name = tokenname;
    // 代币符号
    symbol = tokenSymbol;
  }

  /**
   * 代币交易转移的内部实现
   *  @params _from 发送发地址
   *  @params _to 接收方地址
   */
  function _transfer(address _from, address _to, uint _value) internal {
    // 确保目标地址不为0x0, 因为0x0地址表示销毁
    require(_to != 0x0);
    // 检查发送者余额
    require(balanceOf[_from] > _value);
    // 确保转移数量合法
    require(_value > 0);

    // 保存交易前双方总金额, 用于后面验证交易
    uint previousBalances = balanceOf[_from] + balanceOf[_to];
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    Transfer(_from, _to, _value);

    assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
  }

  /**
   * 代币交易转移
   * 从自己(创建交易者)账户发送_value个代币到_to账户
   * @params _to 接收者地址
   * @params _value 发送数额
   */
  function transfer(address _to, uint256 _value) public {
    _transfer(msg.sender, _to, _value);
  }

  /**
   * 账号之间的代币转移
   *
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    // 确保交易代币数小于等于目标账户(_from)可使用代币
    require(_value <= allowance[_from][msg.sender]);
    allowance[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
  }

  /**
   * 设置某个地址（合约）可以创建交易者名义花费的代币数。
   *
   * 允许发送者`_spender` 花费不多于 `_value` 个代币
   *
   * @param _spender The address authorized to spend
   * @param _value the max amount they can spend
   */
  function approve(address _spender, uint256 _value) public
      returns (bool success) {
      allowance[msg.sender][_spender] = _value;
      return true;
  }

  /**
   * 设置允许一个地址（合约）以我（创建交易者）的名义可最多花费的代币数。
   * @param _spender 被授权的地址（合约）
   * @param _value 最大可花费代币数
   * @param _extraData 发送给合约的附加数据
   */
  function approveAndCall(address _spender, uint256 _value, bytes _extraData)
    public
    returns (bool success) {
    tokenRecipient spender = tokenRecipient(_spender);
    if (approve(_spender, _value)) {
      // 通知合约
      spender.receiveApproval(msg.sender, _value, this, _extraData);
      return true;
    }
  }

  /**
   * 销毁(创建交易者)账户中指定个代币
   */
  function burn(uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value);

    balanceOf[msg.sender] -= _value;
    totalSupply -= _value;
    Burn(msg.sender, _value);
    return true;
  }

  /**
   * 销毁指定用户的代币
   */
  function burnFrom(address _from, uint256 _value) public returns (bool success) {
    require(balanceOf[_from] > _value);
    require(_value <= allowance[_from][msg.sender]);
    balanceOf[_from] -= _value;
    allowance[_from][msg.sender] -= _value;
    totalSupply -= _value;
    Burn(_from, _value);
    return true;
  }

}
