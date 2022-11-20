<template>
<div class="header">
    <h1 @click="this.$router.push('/')" class="header-logo">GAR3</h1>
    <button style="margin: 0px;" class="btn btn-outline-dark">{{walletStore.address}}</button>
</div>
<div class="canvas-container">
    <canvas id="myCanvas" width="800" height="450"></canvas>
</div>
</template>
<script>
// @ is an alias to /src
import { useWalletStore } from '@/store/wallet';
import { ethers } from 'ethers';

// Contract ABI
import Gar3 from '../../artifacts/contracts/Gar3.sol/Gar3.json';

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
		}
	},
  methods: {
		draw() {
			this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
			this.ctx.beginPath();
			this.ctx.arc(this.x, this.y, 10, 0, Math.PI * 2);
			this.ctx.fillStyle = "#0095DD";
			this.ctx.fill();
			this.ctx.closePath();
			this.x += this.dx;
			this.y += this.dy;
		}, 
    async initCanvas() {
      this.canvas = document.getElementById("myCanvas");
      this.ctx = this.canvas.getContext("2d");

			const contractAddress = process.env.VUE_APP_MSG_CONTRACT || '';
			console.log(contractAddress);
      if (contractAddress === '') {
        console.error('No contract address found!');
        return;
      }
			const contract = new ethers.Contract(
				contractAddress,
				Gar3.abi,
				this.signer
			);

			var gameId = await contract.gamesCount();
			console.log(gameId.toString());

			var game = await contract.games(gameId.toString());
			console.log(game);

			var players = await contract.getPlayers(gameId.toString());
			console.log(players);
			
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
