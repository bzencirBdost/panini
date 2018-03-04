pragma solidity ^0.4.20;

import "browser/Token.sol";

contract PanSimTok is TokenContractFragment {
    
    enum rockPaperScissors {
        ROCK,
        PAPER,
        SCISSORS
    }

    enum gameState {
        PENDING,
        STARTED,
        ABONDED,
        FINISHED
    }
    
    event BuyGameMoney(address indexed sender, uint amounth);
    event SellGameMoney(address indexed sender, uint amounth);
    event CollectedTokenFrom(address indexed from, uint token);
    
    struct Player {
        address supporter;
        uint dept; // to supporter
        string name;
        uint gameMoney;
        bool registered;
        uint score;
        bool inGame;
    } 
    
    struct Game {
        address host;
        address joiner;
        gameState state;
        address winner;
        uint raisedMoney; 
        
        rockPaperScissors rpsHost;
        rockPaperScissors rpsJoiner;
        
    }
    
    string bestPlayer;
    uint bestScore;
    
    mapping(address => Player) players;
    mapping(address => mapping(address => Player)) playersOfSupporters;

    mapping(address => uint ) raisedGameMoney;
    mapping(address => Game) createdGames;
    mapping(address => address) joinedHost;
    
    
      
    modifier canStartOrJoinNewGame() {

        require( ( createdGames[msg.sender].state == gameState.ABONDED || createdGames[msg.sender].state == gameState.FINISHED)
              && ( createdGames[joinedHost[msg.sender]].state == gameState.ABONDED || createdGames[joinedHost[msg.sender]].state == gameState.FINISHED ) );
        _;
    }
    
    modifier pendingGame() {

        require( createdGames[msg.sender].state == gameState.PENDING );
        _;
    }
    
    modifier inGame() {

        require(  createdGames[msg.sender].state == gameState.STARTED 
                || createdGames[joinedHost[msg.sender]].state == gameState.STARTED );
        _;
    }
    
    function startGame( uint amounth ) public isPlayer canStartOrJoinNewGame{

        address sender = msg.sender;
        require(players[sender].gameMoney > amounth );

        raisedGameMoney[sender] = amounth;
        players[sender].gameMoney = players[sender].gameMoney.sub(amounth);

        createdGames[sender].host = sender;
        createdGames[sender].state = gameState.PENDING;
        createdGames[sender].raisedMoney = amounth;

        
    }

    function joinGame(address to ) public isPlayer canStartOrJoinNewGame{

        address sender = msg.sender;
        
        // to -> creater of a pending game?
        require(createdGames[to].host == to && createdGames[to].state == gameState.PENDING);
        joinedHost[sender] = to;

        // oyuna katilmak icin parasi var mi?
        uint amounth = createdGames[sender].raisedMoney;
        require(players[sender].gameMoney > amounth );

        // parayi ayir
        raisedGameMoney[sender] = amounth;
        players[sender].gameMoney = players[sender].gameMoney.sub(amounth);
        
        createdGames[to].joiner = sender;
        createdGames[to].state = gameState.STARTED;

    }


    function abontGame() public isPlayer {
        
        //sender:host.
        if ( createdGames[msg.sender].state == gameState.PENDING) {
                
            players[msg.sender].gameMoney = players[msg.sender].gameMoney.add(raisedGameMoney[msg.sender]);
            raisedGameMoney[msg.sender] = 0;
            createdGames[msg.sender].state == gameState.ABONDED;
        } else if ( createdGames[msg.sender].state == gameState.STARTED ) {
            address joiner = createdGames[msg.sender].joiner;
            
            players[msg.sender].gameMoney = players[msg.sender].gameMoney.add(raisedGameMoney[msg.sender]);
            raisedGameMoney[msg.sender] = 0;
            
            players[joiner].gameMoney = players[joiner].gameMoney.add(raisedGameMoney[joiner]);
            raisedGameMoney[joiner] = 0;

            createdGames[msg.sender].state == gameState.ABONDED;
        }
        
        //sender:joiner
        if( createdGames[joinedHost[msg.sender]].state == gameState.STARTED ) {
            address host = createdGames[msg.sender].host;

            players[msg.sender].gameMoney = players[msg.sender].gameMoney.add(raisedGameMoney[msg.sender]);
            raisedGameMoney[msg.sender] = 0;
            
            players[host].gameMoney = players[host].gameMoney.add(raisedGameMoney[host]);
            raisedGameMoney[host] = 0;
            
            createdGames[joinedHost[msg.sender]].state == gameState.ABONDED;
        }

    }

    function playRock() public isPlayer view inGame{
        
        Game memory game = getStartedGame();
        processGame(game, rockPaperScissors.ROCK );
    }

    function playPaper() public isPlayer view inGame{

        Game memory game = getStartedGame();
        processGame(game, rockPaperScissors.PAPER );
    }

    function playScissors() public isPlayer view inGame{

        Game memory game = getStartedGame();
        processGame(game, rockPaperScissors.SCISSORS );

    }

    function getStartedGame() isPlayer inGame view internal returns(Game) {
        if( createdGames[msg.sender].state == gameState.STARTED )  {
            
            return createdGames[msg.sender];
        } else {
            
            return createdGames[joinedHost[msg.sender]];
        }

    }

    function processGame( Game game, rockPaperScissors move ) isPlayer view internal{
        if(game.rpsHost == move ) {
            
        }
        
    }


    
    
    function PanSimTok() public {
        balances[tx.origin] = 10000000;
        bestPlayer = "GM";
        bestScore = 100;

        players[tx.origin].name = "GM";  
        players[tx.origin].registered = true;
        players[tx.origin].score = 1000; 
        players[tx.origin].dept = 0;
        players[tx.origin].inGame = false;
    }
    
    modifier isPlayer() {
        require(players[msg.sender].registered == true);
        _;
    }
    
  
    function myBalance() public constant returns (uint balance) {
        return balances[msg.sender];
    }
    //support someone for first register
    // oyuna birisini alan ona kefil oluyor. 
    // belli bir mebla ile oyuna baslamasini sagliyor.
    // Bu kisi aldigi meblaya gore oda mebla dagitabilir.
    // bu yuzden ne kadar destek olacagini belirleyebiliyor.
    function support(address to, uint token) public{
        require(!players[to].registered);
        approve(to, token);
    }
    
    function unSupport(address to) public isPlayer{
        approve(to, 0);
    }

    // u need to supporter to join game.
    function register(address supporter, string name) public {
        
        address sender = msg.sender;
        require(!players[sender].registered);
        
        uint tokens = allowed[supporter][msg.sender];
        require(tokens > 0);
        
        balances[supporter] = balances[supporter].sub(tokens);
        allowed[supporter][msg.sender] = 0;
        balances[msg.sender] = tokens;
        Transfer(supporter, msg.sender, tokens);
        
        players[sender].name = name;  
        players[sender].registered = true;
        players[sender].supporter = supporter;
        players[sender].score = 100; 
        players[sender].dept = tokens;
        players[sender].inGame = false;
        playersOfSupporters[supporter][sender] = players[sender];

    
    }


    function getMyGameMoney() public view isPlayer returns(uint){
        
        return players[msg.sender].gameMoney;
    }
    
    function buyGameMoney(uint amounth) public isPlayer{
        
        address sender = msg.sender;
        // 1wei = 10 game money
        uint token = amounth.div(10);
        require(token <= balances[sender] );
        balances[sender].sub(token);
        players[sender].gameMoney = players[sender].gameMoney + amounth;
        BuyGameMoney(sender, amounth);
    }
    
    function sellGameMoney100x(uint number) public isPlayer {
        
        address sender = msg.sender;

        require(amounth != 0);
        uint amounth = number.mul(100);
        require( players[sender].gameMoney >= amounth );
        players[sender].gameMoney = players[sender].gameMoney.sub(amounth);

        // 1token = 10 game money
        uint token = number.mul(10);
        uint dept = players[sender].dept;
        
        if (dept > 0 ) {
            
            if( dept > token) { //once borcunu ode
                balances[players[sender].supporter] = balances[players[sender].supporter].add(token);
                players[sender].dept = dept.sub(token);
                CollectedTokenFrom(sender, token);
                token = 0; //bitti
            } else {
                //close all dept
                balances[players[sender].supporter] = balances[players[sender].supporter].add(dept); 
                CollectedTokenFrom(sender, dept);
                players[sender].dept = 0;
                CollectedTokenFrom(sender, dept);
                token = token.sub(dept); // kalan
            }
        } 
        
        if(token > 0) {
            //%10 to supporter.
            uint unit = token.div(10);
            balances[players[sender].supporter] = balances[players[sender].supporter].add(unit); 
            balances[sender] = balances[sender].add(token.sub(unit));
            
        }
        
        SellGameMoney(sender, amounth);
    }
    
 
}