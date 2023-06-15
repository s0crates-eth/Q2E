// move all of this stuff into the sandbox, AND THEN also set up a placeholderr on BONworld for the front end
// it would be smarter to approve and collect MATIC and auto convert the remained after tax to BON, and then give that BON as a reward -- this method would be best if the front end provided price quotes for how much the BON reward is worth in MATIC
// actually this also isn't great BC the winner would probably just dump the reward for MATIC after, so BEST would be let the user chose their payment form, so that it all somewhat averages out hopefully but the tax is kept in MATIC
// the guess would just call one of two uniswap functions that are inverses, so then what's held in the contract always is the same (rewards in BON, tax in MATIC)








// SPDX-License-Identifier: GNU
pragma solidity ^0.8.13;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.-. BANK OF NOWHERE LOTTO v0.1 -.-.-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Router.sol";

contract Q2E {
    bytes32 private salt = bytes32("changeThisBeforeDeploying"); // --- CHANGE THIS BEFORE DEPOLY ---
    bytes32 public hashedAnswer;
    string public question;
    address public erc20contract;
    address public erc20LP;
    uint256 public erc20Base;
    uint256 public erc20Fee;
    uint256 public counter;
    
    event QuizFunded(uint amount);
    event AnswerGuessed(string guess);
    event AnswerCorrect(uint winnings);

    constructor(
        string memory _question, 
        bytes32 _hashedAnswer, 
        address _erc20contract, 
        address _erc20LP;
        uint _erc20Base, 
        uint _erc20Fee
        ){
        question = _question; // "xx?"
        hashedAnswer = _hashedAnswer; // "xx"
        erc20contract = _erc20contract; // "0x47E53f0Ddf71210F2C45dc832732aA188F78AA4f" BON
        erc20LP = _erc20LP; // "0x26432f7cf51e644c0adcaf3574216ee1c0a9af6d" BON/WMATIC
        erc20Base = _erc20Base; // "750000000000000000000" 750 tokens ~$4
        erc20Fee = _erc20Fee; // "1000" 10% of erc20 price (1,000/10,000)
        counter = 1;
    }

    function currentPrice() public view returns(uint256){
        uint price = (counter * erc20Base);
        return price;
    }
    
// I should actually move the uniswap exchange out of the guess and just call it from inside guess() --- also I think I saw this in the lotto contract that Guu sent


    function guess(string calldata answer) public{
        uint256 price = currentPrice();

        // all USERS must APPROVE lotto contract to use erc20 before v-this-v can work
        require(IERC20(erc20contract).transferFrom(msg.sender, address(this), price), "transfer failed!");

        // tax token swap payment process
        uint256 amountIn = price * erc20Fee / 10000;
        address[] memory path = new address[](2);
        path[0] = erc20LP.token0();
        path[1] = erc20LP.token1();
        oracleData[] = erc20LP.getReserves();
        amountOutMinBeforeSlip = (oracleData[0] / oracleData[1] * amountIn);
        amountOutMin = amountOutMinBeforeSlip - (amountOutMinBeforeSlip * 30/1000);
        // contract(this) must have APPROVEd uniswap to use 'token0' before v-this-v can work
        require(UniswapV2Router02.swapExactTokensForETH(amountIn, amountOutMin, path, address(this), block.timestamp), "transfer failed!");


        /* --- quiz stuff which I can figure out later ---
        // emit the guess so that it can be recorded on the frontend (and help future guesses)
        emit AnswerGuessed(answer);
        emit QuizFunded(IERC20(erc20contract).balanceOf(msg.sender));
        
        // compare answer and see if its a winner
        if(keccak256(abi.encodePacked(salt, answer)) == hashedAnswer){
            payable(msg.sender).transfer(address(this).balance);
            emit AnswerCorrect(winnings);
        }
        */
    }

    function closeLotto() external onlyOwner{
        // transfer() WMATIC to msg.sender
    }

    function approveUni() external onlyOwner{
        // maybe this APPROVAL is needed to let the LOTTO CONTRACT approve Uni to transfer tokens?
    }

    fallback() external payable{
    }
    receive() external payable{
    }

}
