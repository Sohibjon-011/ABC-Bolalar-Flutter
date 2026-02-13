<template>
  <nav class="tabs" aria-label="Tabs">
    <router-link class="t" to="/abc" :class="{ on: is('/abc') }"><span>🔤</span><b></b></router-link>
    <router-link class="t" to="/numbers" :class="{ on: is('/numbers') }"><span>🔢</span><b></b></router-link>
    <router-link class="t" to="/colors" :class="{ on: is('/colors') }"><span>🎨</span><b></b></router-link>
    <router-link class="t" to="/animals" :class="{ on: is('/animals') }"><span>🐾</span><b></b></router-link>
  </nav>
</template>

<script setup>
import { useRoute } from "vue-router"
const r = useRoute()
const is = (p) => r.path === p
</script>

<style scoped>
.tabs {
  position: fixed;
  left: 12px;
  right: 12px;
  bottom: 12px;
  z-index: 60;
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  padding: 10px;
  border-radius: 22px;
  background: color-mix(in oklab, var(--card) 72%, transparent);
  border: 1px solid var(--brd);
  backdrop-filter: blur(16px);
  box-shadow: var(--shadowM);
  text-align: center;
}

.t {
  width: 100%;
  display: grid;
  justify-items: center;
  gap: 6px;
  padding: 10px 8px;
  border-radius: 18px;
  text-decoration: none;
  color: inherit;
  border: 1px solid transparent;
  transition: .18s ease;
  text-align: center;
  align-items: center;
}

.t span {
  font-size: 30px
}

.t b {
  font-size: 12px;
  letter-spacing: .2px
}

.t:hover {
  transform: translateY(-2px)
}

.t.on {
  background: linear-gradient(135deg, color-mix(in oklab, var(--acc) 30%, transparent), color-mix(in oklab, var(--acc2) 22%, transparent));
  border-color: color-mix(in oklab, var(--acc) 40%, var(--brd));
  box-shadow: 0 16px 30px color-mix(in oklab, var(--glow) 35%, transparent);
}
</style>
