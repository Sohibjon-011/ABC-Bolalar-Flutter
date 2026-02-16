import { ref, computed, watch } from 'vue'

const STORAGE_KEY = 'abc_user_level'
const XP_KEY = 'abc_user_xp'

// Level va XP ma'lumotlarini localStorage dan o'qish
const level = ref(parseInt(localStorage.getItem(STORAGE_KEY)) || 1)
const xp = ref(parseInt(localStorage.getItem(XP_KEY)) || 0)

// Har bir level uchun kerakli XP
const getXPForLevel = (lvl) => {
  return Math.floor(100 * Math.pow(1.5, lvl - 1))
}

// Joriy level uchun kerakli XP
const xpRequired = computed(() => getXPForLevel(level.value))

// Progress foizi (0-100)
const progress = computed(() => {
  return Math.min(100, Math.floor((xp.value / xpRequired.value) * 100))
})

// Level ko'rinishi (masalan: "Level 5")
const levelText = computed(() => `Level ${level.value}`)

// XP qo'shish funksiyasi
const addXP = (amount) => {
  xp.value += amount
  
  // Level oshishi kerakmi?
  while (xp.value >= xpRequired.value) {
    xp.value -= xpRequired.value
    level.value++
  }
  
  // localStorage ga saqlash
  localStorage.setItem(STORAGE_KEY, level.value)
  localStorage.setItem(XP_KEY, xp.value)
}

// LocalStorage ga saqlash (watch bilan)
watch(level, (newLevel) => {
  localStorage.setItem(STORAGE_KEY, newLevel)
})

watch(xp, (newXP) => {
  localStorage.setItem(XP_KEY, newXP)
})

export function useLevel() {
  return {
    level,
    xp,
    xpRequired,
    progress,
    levelText,
    addXP
  }
} 