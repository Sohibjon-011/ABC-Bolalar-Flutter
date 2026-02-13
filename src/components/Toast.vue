<template>
  <div class="toastwrap" aria-live="polite">
    <div v-for="t in items" :key="t.id" class="toast">
      <span class="e">{{ t.emoji }}</span>
      <b>{{ t.text }}</b>
    </div>
  </div>
</template>

<script setup>
defineProps({ items: Array })
</script>

<style scoped>
.toastwrap{
  position:fixed;left:12px;right:12px;top:72px;z-index:80;
  display:grid;gap:10px;pointer-events:none;
}
.toast{
  display:flex;gap:10px;align-items:center;justify-content:center;
  padding:12px 14px;border-radius:18px;
  background: color-mix(in oklab, var(--card) 82%, transparent);
  border:1px solid var(--brd);
  box-shadow: var(--shadowM);
}
.e{font-size:22px}
b{font-size:14px}
</style>
