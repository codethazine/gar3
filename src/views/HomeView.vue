<template>
  <div class="home">
    <canvas id="stage" width="500px" height="100px"></canvas>
    <div class="inner-home">
    <div class="centered">
      <h1 style="font-size: 5rem; color:black;">GAR3</h1>
      <button v-if="walletStore.address == ''" class="btn btn-outline-dark" @click="connectwalletHandler()"><img style="height: 22px; margin-right: 10px;" src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/MetaMask_Fox.svg/800px-MetaMask_Fox.svg.png">Login with Metamask</button>
      <button v-else class="btn btn-outline-dark" @click="startGame()">Start game</button>
    </div>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap" rel="stylesheet">
    </div>
  </div>
</template>

<script>
// @ is an alias to /src
import { useWalletStore } from '@/store/wallet';
import { ethers } from 'ethers';

// Contract ABI
import Gar3 from '../../artifacts/contracts/Gar3.sol/Gar3.json';

export default {
  name: 'HomeView',
  components: {
  },
  mounted() {
    this.initStages();
    this.initCircles();
    this.animate();
    if (this.walletStore.address != '') {
      console.log('There is a wallet connected!');
    }
  },
  setup() {
    const walletStore = useWalletStore();
    return {walletStore};
  },
  data() {
    return {
      stage: null,
      textStage: null,
      form: null,
      input: "GAR3",
      circles: null,
      textPixels: null,
      textFormed: null,
      offsetX: null,
      offsetY: null,
      text: null,
      provider: null,
      signer: null,
      colors: ['#B2949D', '#FFF578', '#FF5F8D', '#37A9CC', '#188EB2']
    } 
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
  },
  methods: {
    async connectwalletHandler() {
      this.provider = new ethers.providers.Web3Provider(window.ethereum, "any");
      // Prompt user for account connections
      await this.provider.send("eth_requestAccounts", []);
      this.signer = this.provider.getSigner();
      console.log("Account:", await this.signer.getAddress());
      useWalletStore().connectWallet();
    },
    async startGame() {
      // address of the contract loaded from an environment variable
      console.log(process.env)
      const contractAddress = process.env.VUE_APP_MSG_CONTRACT || '';
      console.log(contractAddress);
      if (contractAddress === '') {
        console.error('No contract address found!');
        return;
      }

      if (window.ethereum !== 'undefined') {
        //@ts-expect-error Window.ethers not TS
        // Contract reference
        const contract = new ethers.Contract(
          contractAddress,
          Gar3.abi,
          this.signer
        );
        try {
          // call contract public method
          // Get current game id
          var gameId = await contract.gamesCount();
          gameId = gameId.toString();
          console.log(gameId);

          const data = await contract.startGame({value: ethers.utils.parseUnits("1", "ether"), 
                                                 gasLimit: 5000000});
          console.log(data);
          const receipt = await data.wait()
          console.log(receipt);

          this.$router.push('/game/' + gameId);
        } catch (error) {
          console.error(error);
        }
      }
    },
    // Init Canvas
    initStages() {
        this.offsetX = (window.innerWidth-600)/2;
        this.offsetY = (window.innerHeight-300)/2;

        this.stage = new createjs.Stage("stage");
        this.stage.canvas.width = window.innerWidth;
        this.stage.canvas.height = window.innerHeight;
    },
    initCircles() {
        this.circles = [];
        for(var i=0; i<200; i++) {
            var circle = new createjs.Shape();
            var r = 7;
            var x = window.innerWidth*Math.random();
            var y = window.innerHeight*Math.random();
            var color = this.colors[Math.floor(i%this.colors.length)];
            var alpha = 0.2 + Math.random()*0.5;
            circle.alpha = alpha;
            circle.radius = r;
            circle.graphics.beginFill(color).drawCircle(0, 0, r);
            circle.x = x;
            circle.y = y;
            this.circles.push(circle);
            this.stage.addChild(circle);
            circle.movement = 'float';
            this.tweenCircle(circle);
        }
    },
    // animating circles
    animate() {
        this.stage.update();
        requestAnimationFrame(this.animate);
    },
    tweenCircle(c, dir) {
        if(c.tween) c.tween.kill();
        if(dir == 'in') {
            c.tween = TweenLite.to(c, 0.4, {x: c.originX, y: c.originY, ease:Quad.easeInOut, alpha: 1, radius: 5, scaleX: 0.4, scaleY: 0.4, onComplete: function() {
                c.movement = 'jiggle';
                this.tweenCircle(c);
            }});
        } else if(dir == 'out') {
            c.tween = TweenLite.to(c, 0.8, {x: window.innerWidth*Math.random(), y: window.innerHeight*Math.random(), ease:Quad.easeInOut, alpha: 0.2 + Math.random()*0.5, scaleX: 1, scaleY: 1, onComplete: function() {
                c.movement = 'float';
                this.tweenCircle(c);
            }});
        } else {
            if(c.movement == 'float') {
                c.tween = TweenLite.to(c, 5 + Math.random()*3.5, {x: c.x + -100+Math.random()*200, y: c.y + -100+Math.random()*200, ease:Quad.easeInOut, alpha: 0.2 + Math.random()*0.5,
                    onComplete: () => {
                        this.tweenCircle(c);
                    }});
            } else {
                c.tween = TweenLite.to(c, 0.05, {x: c.originX + Math.random()*3, y: c.originY + Math.random()*3, ease:Quad.easeInOut,
                    onComplete: () => {
                        this.tweenCircle(c);
                    }});
            }
        }
    },
  }
}
</script>

<style scoped>
body {
  background: #eee;
}

input[type="text"] {
  border: 1px solid #ddd;
  padding: 6px;
  font-size: 18px;
  width: 200px;
  text-transform: uppercase;
  top: 30px;
  left: 130px;
}

input[type="submit"] {
  display: block;
  width: 100px;
  border: 0;
  line-height: 35px;
  height: 35px;
  color: #fff;
  background: mediumpurple;
  font-size: 18px;
  top: 30px;
  left: 350px;
  cursor: pointer;
}

canvas {
  height: 100%;
  width: 100%;
}

form {
  width: 800px;
  height: 100px;
}
.button-try {
  width: 30px;
  height: 30px;
}

.centered {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-family: 'Press Start 2P', cursive;
  
}

button {
  font-family: Arial, Helvetica, sans-serif;
  background-color: #fff;
}



.imgMeta {
  height: 20px;
  width: 20px;
}


</style>
