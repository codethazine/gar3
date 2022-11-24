<template>
<div class="header">
    <h1 @click="this.$router.push('/')" class="header-logo">GAR3</h1>
    <button style="margin: 0px;" class="btn btn-outline-dark">{{walletStore.address}}</button>
</div>
<div class="canvas-container">
    <canvas @click="movePlayer" id="myCanvas" width="800" height="450"></canvas>
</div>
</template>
<script>
// @ is an alias to /src
import { useWalletStore } from '@/store/wallet';
import { ethers } from 'ethers';

// Contract ABI
import Gar3 from '@/artifacts/contracts/Gar3.sol/Gar3.json';

export default {
  name: 'GameView',
  components: {
  },
  async mounted() {
    if (this.walletStore.address != '') {
      console.log('There is a wallet connected!');
    }
		this.provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    this.signer = await this.provider.getSigner();
    await this.initCanvas();
		setInterval(this.draw, 1000);
  },
	data() {
		return {
			canvas: null,
			ctx: null,
			walletStore: null,
			x: 0,
			y: 0,
			dx: 2,
			dy: -2,
			provider: null,
      signer: null,
			numberOfPlayers: 0,
			gameIsFull: false,
			contractAddress: null,
			contract: null,
			gameId: null,
			playerColors: ["#FF0000", "#00FF00", "#0000FF"],
			players: [],
		}
	},
  methods: {
		async draw() {
			if (!this.gameIsFull) {
				this.ctx.beginPath();
				// Write "Waiting for other players to join the game..." at the center of  the canvas
				this.ctx.font = "30px Arial";
				this.ctx.fillText("Waiting for other players to join the game...", this.canvas.width/2 - 300, this.canvas.height/2);
			} else {
				// Get position of the three players and draw three circles on them
				var tmpPlayers = await this.contract.getPlayers(this.gameId.toString());
				console.log(tmpPlayers);

				// If only one player has life != 0, the game is over
				var numberOfPlayersAlive = 0;
				for (var i = 0; i < tmpPlayers.length; i++) {
					console.log(tmpPlayers[i].life.toNumber());
					if (tmpPlayers[i].life.toNumber() != 0) {
						numberOfPlayersAlive++;
					}
				}
				if (numberOfPlayersAlive == 1) {
					console.log("Game over!");
					this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
					// Game is over
					this.ctx.beginPath();
					// Write "Game over" at the center of  the canvas
					this.ctx.font = "30px Arial";
					// In black
					this.ctx.fillStyle = "#000000";
					this.ctx.fillText("Game over", this.canvas.width/2 - 90, this.canvas.height/2);
					this.ctx.closePath();
					return 
				} 
				
				// If position different from last one clear canvas and draw new circles
				if (tmpPlayers != this.players) {
				  this.players = tmpPlayers;

					this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

					// For every player create a circle w players[i].position.width.toNumber()*10/2 as position
					for (var i = 0; i < this.players.length; i++) {
						console.log(i, this.players[i].position.width.toNumber()*10/2, this.players[i].position.height.toNumber()*10/2, this.players[i].life.toNumber());
						this.ctx.beginPath();
						this.ctx.arc(this.players[i].position.width.toNumber()*10/2, this.players[i].position.height.toNumber()*10/2,
												 this.players[i].life.toNumber(), 0, Math.PI*2);
						this.ctx.fillStyle = this.playerColors[i];
						this.ctx.fill();
						this.ctx.closePath();
					}
				}
			}	
		},
		movePlayer(event) {
			console.log(event);
			var x = event.offsetX;
			var y = event.offsetY;
			console.log("x coords: " + x + ", y coords: " + y);
			this.contract.movePlayer(this.gameId.toString(), Math.round(x/10*2), Math.round(y/10*2));

		},
    async initCanvas() {
      this.canvas = document.getElementById("myCanvas");
      this.ctx = this.canvas.getContext("2d");

			this.contractAddress = process.env.VUE_APP_MSG_CONTRACT || '';
			console.log(this.contractAddress);
      if (this.contractAddress === '') {
        console.error('No contract address found!');
        return;
      }
			this.contract = new ethers.Contract(
				this.contractAddress,
				Gar3.abi,
				this.signer
			);

			this.gameId = await this.contract.gamesCount();
			console.log(this.gameId.toString());

			var game = await this.contract.games(this.gameId.toString());
			console.log(game);

			var players = await this.contract.getPlayers(this.gameId.toString());
			console.log(players);

			// Count number of players with address != 0x0000000
			for (var i = 0; i < players.length; i++) {
				if (players[i][0] != '0x0000000000000000000000000000000000000000') {
					this.numberOfPlayers++;
				}
			}
			console.log(this.numberOfPlayers);

			// Get MAX_PLAYERS from contract
			var maxPlayers = await this.contract.MAX_PLAYERS();
			console.log(maxPlayers.toString());

			// Check if game is full
			if (this.numberOfPlayers == maxPlayers.toString()) {
				console.log('Game is full!');
				this.gameIsFull = true;
			}

			
		}
  },
  setup() {
    const walletStore = useWalletStore();
    return {walletStore};
  },
  computed: {
    accAvailable() {
      return useWalletStore().walletData;
    },
  },
  watch: {
    accAvailable(newVal, old) {
      console.log(`updating from ${old} to ${newVal}`);
      this.retrieveMessages();
    },
  }
}
</script>
<style scoped>
canvas {
    background: #eee;
    display: block;
    margin: 0 auto;
    border: 1px solid #000;
}

.canvas-container {
    height: 82vh;
    display: flex;
    align-content: center;
    justify-content: center;
    align-items: center;
}

.square {
	width:1100px;
	height:500px;
	background:black;
    margin-top: 50px;
}
.centered {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}
.header {
    font-family: 'Press Start 2P', cursive;
}
.header-logo {
    left: 5px;
    margin-top: 10px;
    font-size: 2.1rem; 
    margin: 0px;
    cursor: pointer;
		color:black;
}
.btn {
    right: 5px;
    margin-top: 10px;
    font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif;
}
.header {
    padding: 1rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
    align-content: center;
}
</style>
