// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/ZuniswapV2Factory.sol";
import "../src/ZuniswapV2Pair.sol";
import "../src/ZuniswapV2Router.sol";
import "./mocks/ERC20Mintable.sol";

contract ZuniswapV2MiscTest is Test {
    
    ZuniswapV2Factory factory;
    ZuniswapV2Router router;

    ERC20Mintable tokenA;
    ERC20Mintable tokenB;
    ERC20Mintable tokenC;

    uint256 tokenAMintable = 20 ether;
    uint256 tokenBMintable = 20 ether;
    uint256 tokenCMintable = 20 ether;

    uint256 amountADesired = 5 ether;
    uint256 amountBDesired = 6 ether;//this is increases the liquidity
    uint256 amountCDesired = 3 ether;
    
    uint256 amountLiquidA = 1 ether;
    uint256 amountLiquidB = 1 ether;
    uint256 amountLiquidC = 1 ether;

    //LP 
    uint256 amountAMin = 1 ether;
    uint256 amountBMin = 1 ether;
    uint256 amountCMin = 1 ether;
    uint256 MIN_LIQUIDITY = 1000;
    uint256 swapAmountInMax = 0.1 ether;
    uint256 swapAmountOut = 0.3 ether;
    uint256 swapBdesired = 0.12 ether;

    event AmountOpt(string message, uint8 amountA, uint8 amoountB);

    function setUp() public {
        factory = new ZuniswapV2Factory();
        router = new ZuniswapV2Router(address(factory));

        tokenA = new ERC20Mintable("Token A", "TKNA");
        tokenB = new ERC20Mintable("Token B", "TKNB");
        tokenC = new ERC20Mintable("Token C", "TKNC");


        tokenA.mint(tokenAMintable, address(this));
        tokenB.mint(tokenBMintable, address(this));
        tokenC.mint(tokenCMintable, address(this));
    }

    function testoptimalAmount(uint8 amountADesiredRandom, uint8 amountBDesiredRandom)public {

        //we need to create a new pair/exchange
        address pairAddress = factory.createPair(
            address(tokenA),
            address(tokenB)
        );

        //address pairAddress = factory.pairs(address(tokenA), address(tokenB));
        ZuniswapV2Pair pair = ZuniswapV2Pair(pairAddress);
       
        
        // (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        // console.log("Rserves0 %s and Reserves1 %s", reserve0/ 1 ether, reserve1/ 1 ether);
        tokenA.transfer(address(pair), amountADesiredRandom);//our colateral
        tokenB.transfer(address(pair), amountBDesiredRandom);
        
        tokenA.approve(address(router), amountADesiredRandom);
        tokenB.approve(address(router), amountBDesiredRandom);
        
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        //emit AmountOpt("Amount Optimal", amountADesiredRandom, amountBDesiredRandom);
        console.log("amountADesiredRandom and amountBDesiredRandom", amountADesiredRandom,amountBDesiredRandom);
        console.log("Rserves0 Before minting %s and Reserves1 Before minting %s", reserve0/1e14, reserve1/1e14);



    }
    
    
    function testMintWhenTheresLiquidity() public {
        
        //we need to create a new pair/exchange
        address pairAddress = factory.createPair(
            address(tokenA),
            address(tokenB)
        );

        //address pairAddress = factory.pairs(address(tokenA), address(tokenB));
        ZuniswapV2Pair pair = ZuniswapV2Pair(pairAddress);
       
        
        // (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        // console.log("Rserves0 %s and Reserves1 %s", reserve0/ 1 ether, reserve1/ 1 ether);
        tokenA.transfer(address(pair), amountADesired);//our colateral
        tokenB.transfer(address(pair), amountBDesired);
        
        tokenA.approve(address(router), amountADesired);
        tokenB.approve(address(router), amountBDesired);
        
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        console.log("Rserves0 Before minting %s and Reserves1 Before minting %s", reserve0/1e14, reserve1/1e14);
        //assertEq(pair.token0(), address(tokenB));
        //tokenA.mint(1 ether, address(this)); // + 1 LP

        // tokenA.transfer(address(pair), 2 ether);
        // tokenB.transfer(address(pair), 2 ether);

        pair.mint(address(this));
        // we need to call get_rserves after minting
        //assertEq(pair.balanceOf(address(this)), 3 ether - 1000);
        console.log("Amounted Minted for Token A (Collateral) %s ether",tokenAMintable/ 1e14);
        console.log("Token A Balance in the Pair-Pool %s ether", tokenA.balanceOf(address(pair))/1e14);
        console.log("Token B Balance in the Pair-Pool %s ether", tokenB.balanceOf(address(pair))/1e14);
        console.log("Token A Balance in the Current contract %s ether", tokenA.balanceOf(address(this))/1e14);
        // tokenA.mint(1 ether, address(this)); // + 2 LP
        // console.log("Minting an additional 1 ether to token A ");
        // console.log("Amounted Minted for Token A (Collateral) %s ether",tokenAMintable/ 1 ether);
        // console.log("Token A Balance in the Pair-Pool %s ether", tokenA.balanceOf(address(pair))/1e14);
        // console.log("Token B Balance in the Pair-Pool %s ether", tokenB.balanceOf(address(pair))/1e14);
        // console.log("Token A Balance in the Current contract %s ether", tokenA.balanceOf(address(this))/1e14);
        console.log("Pair Balance in the current contract %s ether", pair.balanceOf(address(this))/1e14);
        //assertEq(pair.totalSupply(), 3 ether);
        (uint256 reserve0AfterMinting, uint256 reserve1AfterMinting, ) = pair.getReserves();
        console.log("Rserves0 After minting %s and Reserves1 After minting %s", reserve0AfterMinting/ 1e14, reserve1AfterMinting/1e14);
        //if (reserve0AfterMinting == 0 || reserve1AfterMinting == 0) revert InsufficientLiquidity();
        //quote returns amountBOptimal = amountAdesired * reserve1AfterMinting/reserve0AfterMinting
        uint256 amountBOptimal = ZuniswapV2Library.quote(
                amountADesired,
                reserve0AfterMinting/1e14,
                reserve1AfterMinting/1e14
            );
        console.log("amountBOptimal", amountBOptimal/1e14);    
        // if (amountBOptimal <= amountBDesired) {
                // if (amountBOptimal <= amountBMin) revert InsufficientBAmount();
                // (amountA, amountB) = (amountADesired, amountBOptimal);
                //need amountBOptimal > amountBDesired
        console.log("amountADesired/Transfered to the Pool",amountADesired/1e14);
        console.log("amountBDesired/Transfered to the Pool",amountBDesired/1e14);
        console.log("amountAMin",amountAMin/1e14);
        console.log("amountBMin",amountBMin/1e14);
        
        (uint256 amountA, uint256 amountB, uint256 liquidity) = router
            .addLiquidity(
                address(tokenA),
                address(tokenB),
                amountADesired,
                amountBDesired,
                amountAMin,
                amountBMin,
                address(this)
            );

            console.log("amoountA",amountA/1e14);
            console.log("amoountA",amountB/1e14);
            console.log("liquidity",liquidity/1e14);

        }


    function AddLiquidityNoPair() public { //testAddLiquidityNoPair
            tokenA.approve(address(router), 1 ether);
            tokenB.approve(address(router), 1 ether);
            
            (uint256 amountA, uint256 amountB, uint256 liquidity) = router
                .addLiquidity(
                    address(tokenA),
                    address(tokenB),
                    amountADesired,
                    amountBDesired,
                    amountAMin,
                    amountBMin,
                    address(this)
                );
        
            console.log("amountADesired", amountADesired/1e14);
            console.log("amountBDesired",amountBDesired/1e14);
            console.log("amountAMin",amountAMin/1e14);
            console.log("amountBDesired",amountBDesired/1e14);
            console.log("amountAMin",amountAMin/1e14);
            console.log("amountBMin",amountBMin/1e14);
            console.log("Add Lquidity outputs");
            console.log("AmountA",amountA/1e14);
            console.log("AmountB",amountB/1e14);
            console.log("Liquidity",liquidity/1e14);
            assertEq(amountA, amountADesired);
            assertEq(amountB, amountBDesired);
            assertEq(liquidity, 1 ether - MIN_LIQUIDITY);

            address pairAddress = factory.pairs(address(tokenA), address(tokenB));

            assertEq(tokenA.balanceOf(pairAddress), 1 ether);
            assertEq(tokenB.balanceOf(pairAddress), 1 ether);

            ZuniswapV2Pair pair = ZuniswapV2Pair(pairAddress);

            assertEq(pair.token0(), address(tokenB));
            assertEq(pair.token1(), address(tokenA));
            assertEq(pair.totalSupply(), 1 ether);
            assertEq(pair.balanceOf(address(this)), 1 ether - 1000);

            assertEq(tokenA.balanceOf(address(this)), tokenAMintable - 1 ether);
            assertEq(tokenB.balanceOf(address(this)), tokenBMintable - 1 ether);
            console.log("tokenA.balanceOf(address(this))",tokenA.balanceOf(address(this)));
        
            (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
            // assertEq(reserve0, 1000);
            // assertEq(reserve1, 1000);
            // assertEq(pair.balanceOf(address(this)), 0);
            // assertEq(pair.totalSupply(), 1000);
            // assertEq(tokenA.balanceOf(address(this)), 20 ether - 1000);
            // assertEq(tokenB.balanceOf(address(this)), 20 ether - 1000);
        
            console.log("reserve0: %s and reserve1 : %s ",reserve0/1e14, reserve1/1e14);
        
        
        }

    function testSwapTokensForExactTokens() public {
        tokenA.approve(address(router), amountADesired);//5
        tokenB.approve(address(router), amountBDesired);//6
        tokenC.approve(address(router), amountCDesired);//3
        
        console.log("Balance of TokenA", tokenA.balanceOf(address(this)));
        console.log("Balance of TokenB", tokenB.balanceOf(address(this)));
        console.log("Balance of TokenC", tokenC.balanceOf(address(this)));
        
        //make sure r_a/_b <= r_a'/r_b'
        router.addLiquidity(
            address(tokenA),
            address(tokenB),
            3 ether , //3 ether: amountLiquidA
            1 ether  ,//1 ether:amountLiquidB,
            1 ether,
            1 ether,
            address(this)
        );

        router.addLiquidity(
            address(tokenB),
            address(tokenC),
            1.5 ether,//1.5 ether: amountLiquidB,
            2.5 ether,//2.5 ether: amountLiquidC,
            1 ether,
            1 ether,
            address(this)
        );
        console.log("Adding liquidity");
        console.log("Balance of TokenA", tokenA.balanceOf(address(this)));
        console.log("Balance of TokenB", tokenB.balanceOf(address(this)));
        console.log("Balance of TokenC", tokenC.balanceOf(address(this)));
        
        address[] memory path = new address[](3);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        path[2] = address(tokenC);

        tokenA.approve(address(router), 0.3 ether);
        router.swapTokensForExactTokens(
            0.1 ether,//amountOut
            0.3 ether,//amountInMax
            path,//address(token?)
            address(this)
        );
        console.log("After the Swap");
        console.log("Balance of TokenA", tokenA.balanceOf(address(this)));
        console.log("Balance of TokenB", tokenB.balanceOf(address(this)));
        console.log("Balance of TokenC", tokenC.balanceOf(address(this)));
        
        // Swap 0.3 TKNA for ~0.186 TKNB
        assertEq(
            tokenA.balanceOf(address(this)),
            tokenAMintable - 1 ether  - 0.1 ether
        );
        assertEq(tokenB.balanceOf(address(this)), tokenBMintable - 3 ether - 0.1 ether);
        assertEq(
            tokenC.balanceOf(address(this)),
            tokenCMintable - 0.3 ether
        );
        
    }


    // function swapTokensForExactTokens(
    //     uint256 amountOut,
    //     uint256 amountInMax,
    //     address[] calldata path,
    //     address to
    // ) public returns (uint256[] memory amounts) {
    //     amounts = ZuniswapV2Library.getAmountsIn(
    //         address(factory),
    //         amountOut,
    //         path
    //     );
    //     if (amounts[amounts.length - 1] > amountInMax)
    //         revert ExcessiveInputAmount();
    //     _safeTransferFrom(
    //         path[0],
    //         msg.sender,
    //         ZuniswapV2Library.pairFor(address(factory), path[0], path[1]),
    //         amounts[0]
    //     );
    //     _swap(amounts, path, to);
    // }


    // function _swap(
    //     uint256[] memory amounts,
    //     address[] memory path,
    //     address to_
    // ) internal {
    //     for (uint256 i; i < path.length - 1; i++) {
    //         (address input, address output) = (path[i], path[i + 1]);
    //         (address token0, ) = ZuniswapV2Library.sortTokens(input, output);
    //         uint256 amountOut = amounts[i + 1];
    //         (uint256 amount0Out, uint256 amount1Out) = input == token0
    //             ? (uint256(0), amountOut)
    //             : (amountOut, uint256(0));
    //         address to = i < path.length - 2
    //             ? ZuniswapV2Library.pairFor(
    //                 address(factory),
    //                 output,
    //                 path[i + 2]
    //             )
    //             : to_;
    //         IZuniswapV2Pair(
    //             ZuniswapV2Library.pairFor(address(factory), input, output)
    //         ).swap(amount0Out, amount1Out, to, "");
    //     }
    // }

    // function _safeTransferFrom(
    //     address token,
    //     address from,
    //     address to,
    //     uint256 value
    // ) private {
    //     (bool success, bytes memory data) = token.call(
    //         abi.encodeWithSignature(
    //             "transferFrom(address,address,uint256)",
    //             from,
    //             to,
    //             value
    //         )
    //     );
    //     if (!success || (data.length != 0 && !abi.decode(data, (bool))))
    //         revert SafeTransferFailed();
    // }


}
