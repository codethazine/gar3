<template>
<div class="centered">
<div id="square" class="square"></div>
</div>
<div class="header">
<h1 style="font-size: 2.0rem;">GAR3</h1>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap" rel="stylesheet">
<button class="btn btn-outline-dark"></button>
</div>

</template>
<script>
</script>
<style scoped>
.square {
	width:100px;
	height:100px;
	background:black;
}
.centered {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}
.header {
    position: absolute;
    font-family: 'Press Start 2P', cursive;
}
.btn btn-outline-dark {
    position: top left;
    
}
</style>
