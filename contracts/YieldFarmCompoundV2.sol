// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import './ComptrollerInterface.sol';
import './CTokenInterface.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/**
  * @author Lasborne
  * @notice Use FlashLoaned fund to farm yield in COMPOUND by supplying and borrowing.
  * @dev The contract is YieldFarm to farm COMP tokens using flash loan from Aave.
  */
contract YieldFarmCompoundV2 {
    using SafeMath for uint256;

    uint256 borrowAmount;
    uint256 amount;
    address owner;
    IERC20 public borrowedToken;
    IERC20 public comp;
    IERC20 public weth;
    CTokenInterface cBorrowedToken;
    CTokenInterface cComp;
    CTokenInterface cWeth;
    ComptrollerInterface comptroller;

    constructor(address _borrowedToken, address _cBorrowedToken,
        address _comp, address _cComp, address _weth, address _cWeth,
        address _comptroller
    ) {
      owner = msg.sender;
      borrowedToken = IERC20(_borrowedToken);
      comp = IERC20(_comp);
      weth = IERC20(_weth);
      cBorrowedToken = CTokenInterface(_cBorrowedToken);
      cComp = CTokenInterface(_cComp);
      cWeth = CTokenInterface(_cWeth);
      comptroller = ComptrollerInterface(_comptroller);
    }

    /**
     * @notice lend Flash loaned to Compound finance to mint cTokens.
     * @param _amount the amount of tokens supplied.
     * @dev Approves the cToken address to spend flashloaned fund.
     * @dev Mint same amount of cToken.
     */
    function lend(uint256 _amount) external {
      amount = _amount;
      borrowedToken.approve(address(cBorrowedToken), _amount);
      cBorrowedToken.mint(_amount);
    }

    /**
     * @notice withdraw invested Flash loan funds and rewards given.
     * @dev Checks balance of this contract and withdraws all funds.
     * @dev Redeems rewards and funds from cTokens to regular tokens.
     */
    function withdraw() external {
      withdrawRewards();
      uint256 balance = cBorrowedToken.balanceOf(address(this));
      cBorrowedToken.redeem(balance);
    }

    /**
     * @notice withdraw rewards given.
     * @dev Checks balance of this contract and withdraws COMP & WETH.
     * @dev Redeems rewards from cTokens to regular tokens.
     */
    function withdrawRewards() internal {
      uint256 balanceCComp = cComp.balanceOf(address(this));
      cComp.redeem(balanceCComp);

      uint256 balanceCWeth = cWeth.balanceOf(address(this));
      cWeth.redeem(balanceCWeth);
    }

    /**
     * @notice borrow funds.
     * @dev Approves the cToken address for borrowing.
     * @dev Create an array containing cToken address.
     * @dev Enter the borrow market.
     */
    function borrow() external{
      borrowAmount = (amount.div(2));

      borrowedToken.approve(address(cBorrowedToken), borrowAmount);

      // Signals to compound that a token lent will be used as a collateral.
      address[] memory markets = new address[] (1);
      markets[0] = address(cBorrowedToken);
      comptroller.enterMarkets(markets);

      // Borrow 50% of the same collateral provided.
      
      cBorrowedToken.borrow(borrowAmount);
    }

    /**
     * @notice pay back borrowed funds.
     * @dev Approve the cToken address for repay with a higher amount.
     * @dev Repay borrowed amount and reset.
     * @dev Enter the borrow market.
     */
    function payback() external {
      uint256 borrowBalance = cBorrowedToken.borrowBalanceCurrent(address(this));
      borrowedToken.approve(address(cBorrowedToken), (borrowAmount.mul(2)));
      cBorrowedToken.repayBorrow(borrowBalance);
      // Reset borrow amount back to 0 after pay out is executed.
      borrowAmount = 0;
    }
}