// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract Gar3 {

    uint256 constant MAX_PLAYERS = 3;
    uint256 constant MAX_TIME_MINUTES = 10 minutes;
    uint256 constant LIFE_INCREASE_TIME = 1 minutes;

    uint256 constant ENTRY_TKT = 1;

    // Gaming engine constants
    uint256 constant GRID_HEIGHT = 90;
    uint256 constant GRID_WIDTH = 160;
    uint256 constant POSITION_MULTIPLIER = 3;

    struct Position {
        uint256 height;
        uint256 width;
    }

    // Starting position for each player
    Position[MAX_PLAYERS] public startingPositions;
    constructor() {
        startingPositions[0] = Position(0, 0);
        startingPositions[1] = Position(0, GRID_WIDTH - 1);
        startingPositions[2] = Position(GRID_HEIGHT - 1, 0);
    }
    struct Players {
        address payable player;
        uint256 id;
        uint256 life; // Remaining Tokens
        Position position;
        uint lastMoveTimestamp;
    }

    struct PlayingGrid {
        uint256 height;
        uint256 width;
    }

    enum GameStatus { CLOSED, PENDING, ACTIVE }
    struct Game {
        GameStatus status;
        Players[MAX_PLAYERS] players;
        PlayingGrid grid;
    }

    mapping(uint256 => Game) public games;
    uint256 public gamesCount;
    function getPlayers(uint256 gameId) public view returns(Players[MAX_PLAYERS] memory) {
        return games[gameId].players;
    }
    function nextPlayerId(uint256 gameId) public view returns(uint256) {
        // Get how many players, with address not 0x0 in the game
        uint256 playersCount = 0;
        for (uint256 i = 0; i < MAX_PLAYERS; i++) {
            if (games[gameId].players[i].player != address(0)) {
                playersCount++;
            }
        }
        return playersCount;
    }
    
    function startGame() public payable returns(uint256) {
        require(msg.value >= ENTRY_TKT, 'value sent not enough');

        // Create new game, if last one has more than MAX_PLAYERS
        uint256 currPlayerId = nextPlayerId(gamesCount);
        if (currPlayerId == MAX_PLAYERS) {
            gamesCount++;
            games[gamesCount].status = GameStatus.PENDING;
            games[gamesCount].grid = PlayingGrid(GRID_HEIGHT, GRID_WIDTH);
            currPlayerId = 0;
        }

        games[gamesCount].players[currPlayerId] = Players(payable(msg.sender), currPlayerId, 0, startingPositions[currPlayerId], block.timestamp);

        // If game is full, start it
        if (games[gamesCount].players.length == MAX_PLAYERS) {
            games[gamesCount].status = GameStatus.ACTIVE;
        }

        return gamesCount;
    }
        

    function movePlayer(uint256 gameId, uint256 direction_height, uint256 direction_width) public {
        Game storage game = games[gameId];
        require(game.status == GameStatus.ACTIVE, 'Game is not active'); 
    
        // Get playerId from msg.sender
        uint256 playerId = 0;
        for (uint256 i = 0; i < MAX_PLAYERS; i++) {
            if (game.players[i].player == msg.sender) {
                playerId = i;
                break;
            }
        }
        
        // Create player reference
        Players storage playerToMove = game.players[playerId];

        // Move player towards the direction with the multiplier with grid normalized value
        playerToMove.position.height += (direction_height * POSITION_MULTIPLIER) % GRID_HEIGHT;
        playerToMove.position.width += (direction_width * POSITION_MULTIPLIER) % GRID_WIDTH;

        playerToMove.lastMoveTimestamp = block.timestamp;
        

        // Check if player has hit another player on grid
        // Every player has size equal to his life
        for (uint256 i = 0; i < MAX_PLAYERS; i++) {
            if (i == playerId) {
                continue;
            }
            Players storage otherPlayer = game.players[i];
            if (playerToMove.position.height >= otherPlayer.position.height - otherPlayer.life &&
                playerToMove.position.height <= otherPlayer.position.height + otherPlayer.life &&
                playerToMove.position.width >= otherPlayer.position.width - otherPlayer.life &&
                playerToMove.position.width <= otherPlayer.position.width + otherPlayer.life) {
                // Player has hit another player
                // Reduce life of the other player
                otherPlayer.life--;
                if (otherPlayer.life == 0) {
                    // Player has lost
                    // Remove player from the game
                    game.players[i].life = 0;
                    game.players[i].position = Position(0, 0);
                }
            }
        }

        // If all players are dead, end the game and give the prize to the last player alive
        uint256 alivePlayers = 0;
        uint256 lastPlayerAlive = 0;
        for (uint256 i = 0; i < MAX_PLAYERS; i++) {
            if (game.players[i].life > 0) {
                alivePlayers++;
                lastPlayerAlive = i;
            }
        }

        // If one minute has passed, increase the life of every player
        if (block.timestamp - game.players[playerId].lastMoveTimestamp >= LIFE_INCREASE_TIME) {
            for (uint256 i = 0; i < MAX_PLAYERS; i++) {
                game.players[i].life++;
            }
        }

        // If MAX_TIME_MINUTES has passed, end the game and give all the prize to the player with more life
        if (block.timestamp - game.players[playerId].lastMoveTimestamp >= MAX_TIME_MINUTES) {
            game.status = GameStatus.CLOSED;
            uint256 maxLife = 0;
            uint256 maxLifePlayer = 0;
            for (uint256 i = 0; i < MAX_PLAYERS; i++) {
                if (game.players[i].life > maxLife) {
                    maxLife = game.players[i].life;
                    maxLifePlayer = i;
                }
            }
            game.players[maxLifePlayer].player.transfer(ENTRY_TKT * MAX_PLAYERS);
        }
    }
}