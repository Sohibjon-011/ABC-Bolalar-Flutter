<template>
  <header class="top">
    <div class="left">
      <h1 class="logo">🎨 ABC BOLALAR</h1>
    </div>

    <div class="right">
      <!-- Coins o'rniga Level Progress -->
      <div class="level-display">
        <div class="level-info">
          <span class="level-badge">⭐ {{ levelText }}</span>
          <span class="xp-text">{{ xp }} / {{ xpRequired }} XP</span>
        </div>
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: progress + '%' }"></div>
        </div>
      </div>

      <button class="theme-btn" @click="$emit('toggleTheme')"
        :aria-label="theme === 'dark' ? 'Light mode' : 'Dark mode'">
        {{ theme === 'dark' ? '☀️' : '🌙' }}
      </button>
    </div>
  </header>
</template>

<script setup>
import { inject } from 'vue'

defineProps(['theme'])
defineEmits(['toggleTheme'])

const { level, xp, xpRequired, progress, levelText } = inject('level')
</script>

<style scoped>
.top {
  position: sticky;
  top: 0;
  z-index: 100;
  padding: 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--card);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--brd);
  box-shadow: var(--shadowS);
}

.left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0;
  background: linear-gradient(135deg, var(--acc), var(--acc2));
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.level-display {
  display: flex;
  flex-direction: column;
  gap: 6px;
  min-width: 180px;
}

.level-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.level-badge {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--acc2);
}

.xp-text {
  font-size: 0.85rem;
  color: var(--mut);
  font-weight: 600;
}

.progress-bar {
  height: 8px;
  background: var(--brd);
  border-radius: 999px;
  overflow: hidden;
  position: relative;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--acc), var(--acc2));
  border-radius: 999px;
  transition: width 0.5s ease;
  box-shadow: 0 0 10px var(--glow);
}

.theme-btn {
  padding: 10px;
  background: var(--card);
  border: 1px solid var(--brd);
  border-radius: 12px;
  cursor: pointer;
  font-size: 1.3rem;
  transition: all 0.3s;
}

.theme-btn:hover {
  transform: scale(1.1) rotate(20deg);
  box-shadow: var(--shadowS);
}

@media (max-width: 640px) {
  .logo {
    font-size: 1.2rem;
  }

  .level-display {
    min-width: 140px;
  }

  .level-badge {
    font-size: 0.95rem;
  }

  .xp-text {
    font-size: 0.75rem;
  }
}
</style>