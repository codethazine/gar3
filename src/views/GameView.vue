<template>
<div class="header">
    <h1 @click="this.$router.push('/')" class="Gar3" style="font-size: 2.1rem; margin: 0px;">GAR3</h1>
    <button style="margin: 0px;" class="btn btn-outline-dark">{{walletStore.address}}</button>
</div>
<canvas>

</canvas>
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
.Gar3 {
    left: 5px;
    margin-top: 10px;
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
