<template>
  <div v-if="open" class="back" @click.self="$emit('close')">
    <div class="modal">
      <div class="icon">🔒</div>
      <div class="t">{{ title }}</div>
      <div class="s">{{ text }}</div>
      <button class="btn" @click="$emit('close')">OK</button>
    </div>
  </div>
</template>

<script setup>
defineProps({ open: Boolean, title: String, text: String })
defineEmits(["close"])
</script>

<style scoped>
.back{
  position:fixed;inset:0;z-index:90;
  background: rgba(0,0,0,.45);
  backdrop-filter: blur(10px);
  display:grid;place-items:center;
  padding:18px;
}
.modal{
  width:min(420px, 100%);
  border-radius:26px;
  background: var(--card);
  border:1px solid var(--brd);
  box-shadow: var(--shadowL);
  padding:18px;
  display:grid;gap:10px;justify-items:center;
}
.icon{font-size:44px}
.t{font-weight:900;font-size:18px}
.s{opacity:.85;text-align:center}
.btn{
  width:100%;padding:14px 16px;border-radius:18px;
  border:1px solid var(--brd);
  background: linear-gradient(135deg, #00bbf9, #9b5de5);
  color:white;font-weight:900;
}
.btn:active{transform:scale(.99)}
</style>
