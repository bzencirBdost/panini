pragma solidity ^0.4.21;
contract GassTest {
    
    struct Base {
        uint256 hp;
        uint256 ap;
        uint256 deff;
    
    }
    struct Game {
        Base b1;
        Base b2;
        Base b3;
        Base[] arr;
        
    }
        
    //test of pure method.
    function test(uint256 _turn) public view returns(uint256) {
        uint time = now;
        Base memory b1 = Base(100,100,100);
        Base memory b2 = Base(200,100,100);
        Base memory b3 = Base(300,100,100);
        Base memory b4 = Base(300,100,100);
        Base memory b5 = Base(300,100,100);
        Base memory b6 = Base(300,100,100);
        Base[] memory arr;
        arr[0] = b1;
        arr[1] = b2;
        Game memory game = Game(b1,b2,b3, arr);
        Game memory game2 = Game(b4,b5,b6, arr);

        uint256 k;   
        for(uint256 i = 0; i < _turn; i++) {
            k += i + 2;
            game.b1.hp += k;
            game.b2.hp += i;
            game.b3.hp += i;
            
        }
        return game.b1.hp + game.b2.hp + time + game2.b1.hp;
    }

   
}