<template>
  <section class="page">
    <div class="hero">
      <div class="hL">
        <div class="hTitle">🔢 Raqamlar</div>
        <div class="hSub">1–20</div>
      </div>
      <button class="playAll" @click="playAll" :disabled="playingAll">
        <span>▶️</span><b>Hammasini ijro etish</b>
      </button>
    </div>

    <div class="grid">
      <GameCard v-for="it in nums" :key="it.id" :emoji="it.emoji" :big="it.big" :active="activeId === it.id"
        @pick="pick(it)" />
    </div>

    <div class="game">
      <div class="gTop">
        <div class="gTitle">🎮 Raqam o'yini</div>
        <div class="lvl">Bosqich: <b>{{ level }}</b>/10</div>
      </div>

      <div class="prompt">
        <button class="bigBtn" @click="speakPrompt">
          <span class="ico">🔊</span>
          <b>TOP!</b>
        </button>
      </div>

      <div class="choices">
        <button v-for="c in choices" :key="c.id" class="choice" @click="choose(c)">
          <div class="dots">
            <span v-for="i in c.dots" :key="i" class="dot"></span>
          </div>
          <div class="label">{{ c.big }}</div>
        </button>
      </div>
    </div>
  </section>
</template>

<script setup>
import { inject, onMounted, ref } from "vue"
import GameCard from "../components/GameCard.vue"
import { useAudio } from "../composables/useAudio"
import { useLevel } from "../composables/useLevel"

const emit = defineEmits(["toast"])
const fx = inject("fx")
const { play, playSequence } = useAudio()
const { addXP } = useLevel()

const baseAudio = "/MP4/"
const startAudio = 30
const srcOf = (n) => baseAudio + n + ".ogg"

const icons = {
  1: "⚽",
  2: "👀",
  3: "🔺",
  4: "🪑",
  5: "🖐️",
  6: "🐞",
  7: "🌈",
  8: "🐙",
  9: "🎯",
  10: "🖐️🖐️"
}

const nums = ref(
  Array.from({ length: 10 }, (_, i) => {
    const n = i + 1
    return {
      id: "n" + n,
      big: String(n),
      emoji: icons[n],
      dots: n,
      audio: startAudio + (n - 1)
    }
  })
)

const activeId = ref(null)
const playingAll = ref(false)

const pick = async (it) => {
  activeId.value = it.id
  await play(srcOf(it.audio))
}

const playAll = async () => {
  playingAll.value = true
  const list = nums.value.map(x => srcOf(x.audio))
  await playSequence(list, (i) => activeId.value = nums.value[i].id)
  playingAll.value = false
  activeId.value = null
}

const level = ref(1)
const promptId = ref(null)
const choices = ref([])

const shuffle = (a) => {
  const x = a.slice()
  for (let i = x.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
      ;[x[i], x[j]] = [x[j], x[i]]
  }
  return x
}

const makeRound = () => {
  const k = Math.min(2 + Math.floor(level.value / 2), 5)
  const pool = shuffle(nums.value)
  const set = pool.slice(0, k)
  const ans = set[Math.floor(Math.random() * set.length)]
  
  console.log('📝 Yangi savol (raqam):', ans.big)
  console.log('Variantlar:', set.map(x => x.big).join(', '))
  
  promptId.value = ans.id
  choices.value = shuffle(set.map(x => ({ ...x, dots: Math.min(x.dots, 12) })))
}

const speakPrompt = async () => {
  const it = nums.value.find(x => x.id === promptId.value)
  if (!it) return
  await play(srcOf(it.audio))
}

const choose = async (c) => {
  console.log('🎯 Tanlangan:', c.big, '| To\'g\'ri javob:', nums.value.find(x => x.id === promptId.value)?.big)
  
  if (c.id === promptId.value) {
    // To'g'ri javob
    console.log('✅ TO\'G\'RI JAVOB!')
    const xpReward = level.value * 10

    emit("toast", "🎉", `+${xpReward} XP olindi!`)
    addXP(xpReward)

    // Effekt (agar mavjud bo'lsa)
    try {
      if (fx?.value && typeof fx.value.victory === 'function') {
        fx.value.victory()
      }
    } catch (err) {
      console.log('FX effekt xatosi (muammo emas):', err.message)
    }

    // Keyingi bosqichga o'tish
    if (level.value < 10) {
      level.value++
      console.log('📈 Yangi bosqich:', level.value)
    } else {
      console.log('🏆 10 bosqich tugallandi!')
      emit("toast", "🏆", "10 bosqich tugallandi!")
      level.value = 1
    }

    // MUHIM: Yangi savol yaratish
    console.log('🔄 makeRound() chaqirilmoqda...')
    makeRound()
    
  } else {
    // Noto'g'ri javob
    console.log('❌ NOTO\'G\'RI JAVOB')
    emit("toast", "😺", "Yana bir bor urinib ko'ring!")
    await speakPrompt()
  }
}

onMounted(() => {
  console.log('🔢 Raqamlar o\'yini boshlandi!')
  makeRound()
})
</script>

<style scoped>
.page {
  display: grid;
  gap: 14px
}

.hero {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 14px;
  border-radius: 24px;
  background: color-mix(in oklab, var(--card) 80%, transparent);
  border: 1px solid var(--brd);
  box-shadow: var(--shadowM);
}

.hTitle {
  font-weight: 900;
  font-size: 22px
}

.hSub {
  opacity: .8;
  font-size: 13px
}

.playAll {
  display: flex;
  gap: 10px;
  align-items: center;
  padding: 12px 14px;
  border-radius: 18px;
  border: 1px solid var(--brd);
  background: linear-gradient(135deg, #00bbf9, #9b5de5, #ff4d6d);
  color: white;
  font-weight: 900;
  box-shadow: 0 18px 45px rgba(0, 0, 0, .22);
  cursor: pointer;
  transition: all 0.2s ease;
}

.playAll:hover:not(:disabled) {
  transform: scale(1.02);
}

.playAll:disabled {
  opacity: .6;
  cursor: not-allowed;
}

.grid {
  display: grid;
  gap: 12px;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

@media (min-width:520px) {
  .grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

@media (min-width:900px) {
  .grid {
    grid-template-columns: repeat(6, minmax(0, 1fr));
  }
}

.game {
  padding: 14px;
  border-radius: 26px;
  background: color-mix(in oklab, var(--card) 82%, transparent);
  border: 1px solid var(--brd);
  box-shadow: var(--shadowM);
  display: grid;
  gap: 12px;
}

.gTop {
  display: flex;
  justify-content: space-between;
  align-items: center
}

.gTitle {
  font-weight: 900
}

.lvl {
  opacity: .85
}

.prompt {
  display: grid;
  place-items: center;
  padding: 6px
}

.bigBtn {
  width: min(320px, 100%);
  padding: 16px 16px;
  border-radius: 22px;
  border: 1px solid var(--brd);
  background: linear-gradient(135deg, #ffb703, #00bbf9);
  color: white;
  font-weight: 900;
  display: flex;
  gap: 12px;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.bigBtn:hover {
  transform: scale(1.05);
}

.bigBtn:active {
  transform: scale(0.98);
}

.ico {
  font-size: 22px
}

.choices {
  display: grid;
  gap: 12px;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

@media (min-width:520px) {
  .choices {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

.choice {
  border-radius: 22px;
  padding: 12px;
  background: color-mix(in oklab, var(--card) 86%, transparent);
  border: 1px solid var(--brd);
  box-shadow: var(--shadowS);
  display: grid;
  gap: 10px;
  justify-items: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.choice:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadowM);
}

.choice:active {
  transform: translateY(0);
}

.dots {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  justify-content: center;
  min-height: 50px;
  align-items: center;
}

.dot {
  width: 14px;
  height: 14px;
  border-radius: 999px;
  background: linear-gradient(135deg, #ff4d6d, #00bbf9);
  box-shadow: 0 10px 18px rgba(0, 0, 0, .14);
}

.label {
  font-weight: 900;
  font-size: 26px;
}
</style>