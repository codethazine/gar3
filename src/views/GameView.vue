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
  mounted() {
    if (this.walletStore.address != '') {
      console.log('There is a wallet connected!');
    }
    this.initCanvas();
		setInterval(this.draw, 10);
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
		}
	},
  methods: {
		draw() {
			this.ctx.beginPath();
			this.ctx.arc(this.x, this.y, 10, 0, Math.PI * 2);
			this.ctx.fillStyle = "#0095DD";
			this.ctx.fill();
			this.ctx.closePath();
			this.x += this.dx;
			this.y += this.dy;
		}, 
    initCanvas() {
      this.canvas = document.getElementById("myCanvas");
      this.ctx = this.canvas.getContext("2d");
			this.x = this.canvas.width / 2;
			this.y = this.canvas.height - 30;



			// Square
      this.ctx.beginPath();
      this.ctx.rect(20, 40, 50, 50);
      this.ctx.fillStyle = "#FF0000";
      this.ctx.fill();
      this.ctx.closePath();

			// Circle
			this.ctx.beginPath();
			this.ctx.arc(240, 160, 20, 0, Math.PI * 2, false);
			this.ctx.fillStyle = "green";
			this.ctx.fill();
			this.ctx.closePath();

			// Line
			this.ctx.beginPath();
			this.ctx.rect(160, 10, 100, 40);
			this.ctx.strokeStyle = "rgba(0, 0, 255, 0.5)";
			this.ctx.stroke();
			this.ctx.closePath();
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
