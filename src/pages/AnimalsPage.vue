<template>
  <section class="page">
    <div class="hero">
      <div class="hL">
        <div class="hTitle">🐾 Hayvonlar</div>
        <div class="hSub">Bos → ovoz 🎵</div>
      </div>
      <button class="playAll" @click="playAll" :disabled="playingAll">
        <span>▶️</span><b>Hammasini ijro etish</b>
      </button>
    </div>

    <div class="grid">
      <GameCard v-for="it in animals" :key="it.id" :img="it.img" :emoji="it.emoji" :big="it.big"
        :active="activeId === it.id" @pick="pick(it)" />
    </div>

    <div class="game">
      <div class="gTop">
        <div class="gTitle">🎮 Hayvon o'yini</div>
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
          <img :src="c.img" alt="" />
          <div class="label">{{ c.emoji }}</div>
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
const startAudio = 50
const srcOf = (n) => baseAudio + n + ".ogg"

const animals = ref([
  { id: "cat", big: "😺", emoji: "😺", img: "https://api.removal.ai/download/g2/preview/c40ca4c7-8c79-4750-8a6a-e09cc8480991.png", audio: startAudio + 0 },
  { id: "dog", big: "🐶", emoji: "🐶", img: "https://api.removal.ai/download/g1/preview/2e1367f5-15d4-4267-bd8e-04c373646128.png", audio: startAudio + 1 },
  { id: "cow", big: "🐮", emoji: "🐮", img: "https://api.removal.ai/download/g1/preview/46023926-545b-4dba-961e-7a25238cf3d4.png", audio: startAudio + 2 },
  { id: "sheep", big: "🐑", emoji: "🐑", img: "https://api.removal.ai/download/g3/preview/2f48a62d-d17d-4712-9465-324458b1807e.png", audio: startAudio + 3 },
  { id: "horse", big: "🐴", emoji: "🐴", img: "https://api.removal.ai/download/g1/preview/49f48e51-7dc2-4dd5-9df4-5d8b73d83233.png", audio: startAudio + 4 },
  { id: "lion", big: "🦁", emoji: "🦁", img: "https://api.removal.ai/download/g3/preview/0d862ebf-3847-4eb7-ac1a-c41854810862.png", audio: startAudio + 5 },
  { id: "elephant", big: "🐘", emoji: "🐘", img: "https://api.removal.ai/download/g3/preview/acb9337c-35ad-44e8-9e46-979653be3f5a.png", audio: startAudio + 6 },
  { id: "rabbit", big: "🐰", emoji: "🐰", img: "https://api.removal.ai/download/g1/preview/7381b8f7-dc8c-4e85-b253-8de91d7c686d.png", audio: startAudio + 7 },
  { id: "duck", big: "🦆", emoji: "🦆", img: "https://api.removal.ai/download/g4/preview/15f6f5d3-6721-4cc3-bbcc-37a137f5b52a.png", audio: startAudio + 8 },
  { id: "fish", big: "🐟", emoji: "🐟", img: "https://api.removal.ai/download/g2/preview/aa419df5-dd11-4234-811c-5b6f28d3ecac.png", audio: startAudio + 9 }
])

const activeId = ref(null)
const playingAll = ref(false)

const pick = async (it) => {
  activeId.value = it.id
  await play(srcOf(it.audio))
}

const playAll = async () => {
  playingAll.value = true
  const list = animals.value.map(x => srcOf(x.audio))
  await playSequence(list, (i) => activeId.value = animals.value[i].id)
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
  const set = shuffle(animals.value).slice(0, k)
  const ans = set[Math.floor(Math.random() * set.length)]
  
  console.log('📝 Yangi savol (hayvon):', ans.emoji)
  console.log('Variantlar:', set.map(x => x.emoji).join(' '))
  
  promptId.value = ans.id
  choices.value = shuffle(set)
}

const speakPrompt = async () => {
  const it = animals.value.find(x => x.id === promptId.value)
  if (!it) return
  await play(srcOf(it.audio))
}

const choose = async (c) => {
  console.log('🎯 Tanlangan:', c.emoji, '| To\'g\'ri javob:', animals.value.find(x => x.id === promptId.value)?.emoji)
  
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
  console.log('🐾 Hayvonlar o\'yini boshlandi!')
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
  background: linear-gradient(135deg, #2ec4b6, #00bbf9, #9b5de5);
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
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (min-width:860px) {
  .grid {
    grid-template-columns: repeat(5, minmax(0, 1fr));
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
  background: linear-gradient(135deg, #ff4d6d, #00bbf9);
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

.choice img {
  width: 92px;
  height: 92px;
  object-fit: contain;
  filter: drop-shadow(0 18px 24px rgba(0, 0, 0, .18))
}

.label {
  font-weight: 900;
  font-size: 28px;
}
</style>