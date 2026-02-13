<template>
  <header class="topbar">
    <button class="iconbtn" @click="$emit('toggleTheme')" aria-label="Theme">
      <span class="i">{{ theme === "dark" ? "🌙" : "☀️" }}</span>
    </button>

    <div class="brand" aria-label="ABC BOLALAR">
      <div class="title">ABC BOLALAR</div>
      <div class="spark" aria-hidden="true">
        <span>🎈</span><span>✨</span><span>🧸</span><span>🌈</span>
      </div>
    </div>

    <div class="right">
      <div class="coins" aria-label="Coins">
        <span class="coin">🪙</span>
        <span class="num" id="coinCounter">{{ coins }}</span>
      </div>
    </div>
  </header>
</template>

<script setup>
defineProps({ theme: String, coins: Number, cartCount: Number })
defineEmits(["toggleTheme"])
</script>

<style scoped>
.topbar{
  position:sticky;top:0;z-index:50;
  display:grid;grid-template-columns:56px 1fr 130px;
  align-items:center;gap:10px;
  padding:10px 12px;
  backdrop-filter: blur(14px);
  background: color-mix(in oklab, var(--card) 70%, transparent);
  border-bottom:1px solid var(--brd);
}
.iconbtn{
  width:48px;height:48px;border-radius:16px;
  background:var(--card);border:1px solid var(--brd);
  display:grid;place-items:center;
  box-shadow: var(--shadowS);
}
.iconbtn:active{transform:scale(.98)}
.brand{display:grid;justify-items:center;gap:2px}
.title{
  font-weight:900;letter-spacing:.6px;
  font-size:20px;line-height:1;
  background: linear-gradient(90deg, #ff4d6d, #ffb703, #00bbf9, #9b5de5);
  -webkit-background-clip:text;background-clip:text;color:transparent;
  text-shadow:0 10px 30px color-mix(in oklab, var(--glow) 50%, transparent);
}
.spark{display:flex;gap:6px;font-size:14px;opacity:.95}
.right{display:flex;justify-content:flex-end;gap:10px;align-items:center}
.coins{
  display:flex;gap:8px;align-items:center;
  padding:10px 12px;border-radius:16px;
  background:var(--card);border:1px solid var(--brd);
  box-shadow: var(--shadowS);
  min-width:86px;justify-content:center;
}
.coin{filter:drop-shadow(0 10px 16px rgba(0,0,0,.18))}
.num{font-weight:900}
.cart{
  width:48px;height:48px;border-radius:16px;
  background:var(--card);border:1px solid var(--brd);
  display:grid;place-items:center;position:relative;
  box-shadow: var(--shadowS);
  text-decoration:none;color:inherit;
}
.badge{
  position:absolute;top:-6px;right:-6px;
  min-width:22px;height:22px;border-radius:999px;
  display:grid;place-items:center;
  font-weight:900;font-size:12px;
  background: #ff4d6d;color:white;
  border:2px solid color-mix(in oklab, var(--card) 80%, transparent);
}
.i{font-size:20px}
</style>
