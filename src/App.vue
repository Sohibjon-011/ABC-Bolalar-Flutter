<template>
  <div class="app" :class="theme">
    <div class="desktop-warning">
      <div class="warning-content">
        <div class="warning-icon">📱</div>
        <div class="warning-title">Mobil Qurilmada Oching</div>
        <div class="warning-text">
          Bu ilova faqat mobil qurilmalar uchun mo'ljallangan.
          Iltimos, telefon yoki planshetingizdan foydalaning.
        </div>
      </div>
    </div>
    <div class="bg" aria-hidden="true">
      <div class="g1"></div>
      <div class="g2"></div>
      <div class="dots">
        <span v-for="n in 22" :key="n" class="d" :style="dotStyle(n)"></span>
      </div>
      <div class="stickers">
        <span v-for="(s, i) in stickers" :key="i" class="st" :style="stStyle(i)">{{ s }}</span>
      </div>
    </div>

    <TopBar :theme="theme" @toggleTheme="toggleTheme" />
    <main class="main">
      <router-view v-slot="{ Component }">
        <component :is="Component" @toast="pushToast" />
      </router-view>
    </main>

    <TabsNav />
    <Toast :items="toasts" />
    <FxOverlay ref="fxRef" />
  </div>
  <button v-if="showInstall" class="install-btn" @click="install">
    📲 Ilovani o‘rnatish
  </button>
</template>

<script setup>
import { computed, ref, provide, onMounted } from "vue"
import TopBar from "./components/TopBar.vue"
import TabsNav from "./components/TabsNav.vue"
import Toast from "./components/Toast.vue"
import FxOverlay from "./components/FxOverlay.vue"
import { useStorage } from "./composables/useStorage"
import { useLevel } from "./composables/useLevel"

const themeStore = useStorage("abc_theme", "dark")
const theme = computed(() => themeStore.value === "light" ? "light" : "dark")
const toggleTheme = () => themeStore.value = theme.value === "dark" ? "light" : "dark"

// Level tizimi - coins va cartCount ni olib tashlash
const { level, xp, xpRequired, progress, levelText } = useLevel()

const toasts = ref([])
const pushToast = (emoji, text) => {
  const id = Math.random().toString(16).slice(2) + Date.now()
  toasts.value.push({ id, emoji, text })
  setTimeout(() => toasts.value = toasts.value.filter(x => x.id !== id), 1400)
}

const fxRef = ref(null)
provide("fx", fxRef)

// Level ma'lumotlarini provide qilish
provide("level", { level, xp, xpRequired, progress, levelText })

const stickers = ["🧸", "🚗", "🍎", "🐶", "🦋", "🎈", "🧩", "⭐", "🍭", "🌈", "🎵", "🫧"]

const dotStyle = (n) => {
  const s = 8 + (n % 7) * 2
  const x = (n * 17) % 100
  const y = (n * 29) % 100
  const o = 0.08 + (n % 6) * 0.03
  return { width: s + "px", height: s + "px", left: x + "%", top: y + "%", opacity: o }
}
const stStyle = (i) => {
  const x = (i * 13 + 7) % 100
  const y = (i * 19 + 9) % 100
  const r = (i * 23) % 360
  const s = 18 + (i % 6) * 6
  return { left: x + "%", top: y + "%", transform: `translate(-50%,-50%) rotate(${r}deg)`, fontSize: s + "px" }
}

const showInstall = ref(false)

onMounted(() => {
  window.addEventListener('pwa-install-available', () => {
    showInstall.value = true
  })
})

function install() {
  window.installPWA()
  showInstall.value = false
}
</script>

<style>
* {
  box-sizing: border-box
}

html,
body,
#app {
  height: 100%
}

body {
  margin: 0;
  font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Arial
}

button {
  font-family: inherit
}

.install-btn {
  position: fixed;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  background: #4f46e5;
  color: white;
  padding: 14px 20px;
  border-radius: 14px;
  font-size: 16px;
  border: none;
  z-index: 9999;
}

:root {
  --shadowS: 0 14px 30px rgba(0, 0, 0, .18);
  --shadowM: 0 20px 50px rgba(0, 0, 0, .22);
  --shadowL: 0 30px 90px rgba(0, 0, 0, .30);
}

.app {
  min-height: 100%;
  position: relative;
  overflow: hidden;
  color: var(--txt);
  padding-bottom: 96px;
}

.app.dark {
  --bg: #070713;
  --card: rgba(18, 18, 34, .78);
  --brd: rgba(255, 255, 255, .10);
  --txt: #f7f7fb;
  --mut: rgba(255, 255, 255, .72);
  --acc: #00bbf9;
  --acc2: #9b5de5;
  --acc3: #ffb703;
  --glow: rgba(0, 187, 249, .35);
}

.app.light {
  --bg: #f7fbff;
  --card: rgba(255, 255, 255, .72);
  --brd: rgba(0, 0, 0, .08);
  --txt: #0f172a;
  --mut: rgba(15, 23, 42, .70);
  --acc: #00bbf9;
  --acc2: #9b5de5;
  --acc3: #ff4d6d;
  --glow: rgba(155, 93, 229, .22);
}

.bg {
  position: absolute;
  inset: 0;
  z-index: -1;
  background: radial-gradient(1000px 600px at 20% 10%, rgba(255, 77, 109, .22), transparent 60%),
    radial-gradient(900px 600px at 80% 20%, rgba(0, 187, 249, .22), transparent 60%),
    radial-gradient(1000px 700px at 50% 90%, rgba(155, 93, 229, .20), transparent 60%),
    var(--bg);
}

.g1,
.g2 {
  position: absolute;
  inset: -20%;
  filter: blur(30px);
  opacity: .8;
}

.g1 {
  background: conic-gradient(from 180deg, rgba(255, 183, 3, .18), rgba(0, 187, 249, .18), rgba(255, 77, 109, .18), rgba(155, 93, 229, .18), rgba(255, 183, 3, .18));
  animation: spin 14s linear infinite;
}

.g2 {
  background: radial-gradient(circle at 30% 30%, rgba(255, 77, 109, .18), transparent 55%),
    radial-gradient(circle at 70% 35%, rgba(0, 187, 249, .18), transparent 55%),
    radial-gradient(circle at 50% 70%, rgba(255, 183, 3, .18), transparent 55%);
  animation: float 8s ease-in-out infinite;
}

.dots .d {
  position: absolute;
  border-radius: 999px;
  background: color-mix(in oklab, var(--acc) 35%, transparent);
}

.stickers .st {
  position: absolute;
  filter: drop-shadow(0 18px 26px rgba(0, 0, 0, .18));
  opacity: .85;
}

.main {
  padding: 12px;
  max-width: 1100px;
  margin: 0 auto;
}

@keyframes spin {
  to {
    transform: rotate(360deg)
  }
}

@keyframes float {

  0%,
  100% {
    transform: translateY(0px) scale(1)
  }

  50% {
    transform: translateY(10px) scale(1.02)
  }
}

/* Desktop Warning Styles */
.desktop-warning {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  z-index: 99999;
  justify-content: center;
  align-items: center;
  text-align: center;
  padding: 2rem;
}

.warning-content {
  background: white;
  padding: 3rem;
  border-radius: 30px;
  box-shadow: 0 30px 90px rgba(0, 0, 0, 0.3);
  max-width: 500px;
  animation: bounceIn 0.6s ease-out;
}

.warning-icon {
  font-size: 5rem;
  margin-bottom: 1.5rem;
  animation: swing 2s ease-in-out infinite;
}

.warning-title {
  font-size: 2rem;
  font-weight: 700;
  color: #333;
  margin-bottom: 1rem;
  font-family: ui-sans-serif, system-ui, sans-serif;
}

.warning-text {
  font-size: 1.3rem;
  color: #666;
  line-height: 1.8;
  font-family: ui-sans-serif, system-ui, sans-serif;
}

/* Katta ekranlarda (kompyuter/noutbuk) faqat warning ko'rsatish */
@media (min-width: 769px) {
  .desktop-warning {
    display: flex !important;
  }

  .app>*:not(.desktop-warning) {
    display: none !important;
  }
}

@keyframes bounceIn {
  0% {
    transform: scale(0.3);
    opacity: 0;
  }

  50% {
    transform: scale(1.05);
  }

  100% {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes swing {

  0%,
  100% {
    transform: rotate(0deg);
  }

  25% {
    transform: rotate(-10deg);
  }

  75% {
    transform: rotate(10deg);
  }
}
</style>
