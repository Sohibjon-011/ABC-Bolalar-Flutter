<template>
  <section class="page">
    <div class="hero">
      <div class="hL">
        <div class="hTitle">🔤 Alifbo</div>
        <div class="hSub">Bos → ovoz 🎵</div>
      </div>
      <button class="playAll" @click="playAll" :disabled="playingAll">
        <span>▶️</span><b>Hammasini ijro etish</b>
      </button>
    </div>

    <div class="grid">
      <GameCard v-for="(it, idx) in letters" :key="it.id" :img="it.img" :emoji="it.emoji" :big="it.big" :small="it.small"
        :active="activeId === it.id" @pick="pick(it, idx)" />
    </div>

    <div class="game">
      <div class="gTop">
        <div class="gTitle">🎮 Alifbo o'yini</div>
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

const letters = ref([
  { id: "a", big: "A", small: "Apelsin", img: "https://openmoji.org/data/color/svg/1F34A.svg", audio: 1 },
  { id: "b", big: "B", small: "Baliq", img: "https://openmoji.org/data/color/svg/1F41F.svg", audio: 2 },
  { id: "d", big: "D", small: "Daraxt", img: "https://openmoji.org/data/color/svg/1F333.svg", audio: 3 },
  { id: "e", big: "E", small: "Eshik", img: "https://openmoji.org/data/color/svg/1F6AA.svg", audio: 4 },
  { id: "f", big: "F", small: "Futbol", img: "https://openmoji.org/data/color/svg/26BD.svg", audio: 5 },
  { id: "g", big: "G", small: "Gul", img: "https://openmoji.org/data/color/svg/1F339.svg", audio: 6 },
  { id: "h", big: "H", small: "Hayvon", img: "https://openmoji.org/data/color/svg/1F43B.svg", audio: 7 },
  { id: "i", big: "I", small: "Ilon", img: "https://openmoji.org/data/color/svg/1F40D.svg", audio: 8 },
  { id: "j", big: "J", small: "Jiraffa", img: "https://openmoji.org/data/color/svg/1F992.svg", audio: 9 },
  { id: "k", big: "K", small: "Kitob", img: "https://openmoji.org/data/color/svg/1F4D6.svg", audio: 10 },
  { id: "l", big: "L", small: "Lampa", img: "https://openmoji.org/data/color/svg/1F4A1.svg", audio: 11 },
  { id: "m", big: "M", small: "Mashina", img: "https://openmoji.org/data/color/svg/1F697.svg", audio: 12 },
  { id: "n", big: "N", small: "Non", img: "https://openmoji.org/data/color/svg/1F35E.svg", audio: 13 },
  { id: "o", big: "O", small: "Oy", img: "https://openmoji.org/data/color/svg/1F319.svg", audio: 14 },
  { id: "p", big: "P", small: "Poyezd", img: "https://openmoji.org/data/color/svg/1F686.svg", audio: 15 },
  { id: "r", big: "R", small: "Raketa", img: "https://openmoji.org/data/color/svg/1F680.svg", audio: 16 },
  { id: "s", big: "S", small: "Sut", img: "https://openmoji.org/data/color/svg/1F95B.svg", audio: 17 },
  { id: "t", big: "T", small: "Telefon", img: "https://openmoji.org/data/color/svg/1F4F1.svg", audio: 18 },
  { id: "u", big: "U", small: "Uzuk", img: "https://openmoji.org/data/color/svg/1F48D.svg", audio: 19 },
  { id: "v", big: "V", small: "Velosiped", img: "https://openmoji.org/data/color/svg/1F6B2.svg", audio: 20 },
  { id: "x", big: "X", small: "Xarita", img: "https://openmoji.org/data/color/svg/1F5FA.svg", audio: 21 },
  { id: "y", big: "Y", small: "Yulduz", img: "https://openmoji.org/data/color/svg/2B50.svg", audio: 22 },
  { id: "z", big: "Z", small: "Zebra", img: "https://openmoji.org/data/color/svg/1F993.svg", audio: 23 },
  { id: "sh", big: "SH", small: "Shar", img: "https://openmoji.org/data/color/svg/1F388.svg", audio: 24 },
  { id: "ch", big: "CH", small: "Choynak", img: "https://openmoji.org/data/color/svg/1FAD6.svg", audio: 25 },
  { id: "o2", big: "O'", small: "O'rdak", img: "https://openmoji.org/data/color/svg/1F986.svg", audio: 26 },
  { id: "g2", big: "G'", small: "G'oz", img: "https://openmoji.org/data/color/svg/1FABF.svg", audio: 27 },
  { id: "q", big: "Q", small: "Qush", img: "https://openmoji.org/data/color/svg/1F426.svg", audio: 28 },
  { id: "ng", big: "NG", small: "Nongul", img: "https://openmoji.org/data/color/svg/1F33A.svg", audio: 29 }
])

const baseAudio = "/MP4/"
const srcOf = (n) => baseAudio + n + ".ogg"

const activeId = ref(null)
const playingAll = ref(false)

const pick = async (it) => {
  activeId.value = it.id
  await play(srcOf(it.audio))
}

const playAll = async () => {
  playingAll.value = true
  activeId.value = null
  const list = letters.value.map(x => srcOf(x.audio))
  await playSequence(list, (i) => activeId.value = letters.value[i].id)
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
  const pool = shuffle(letters.value)
  const set = pool.slice(0, k)
  const ans = set[Math.floor(Math.random() * set.length)]
  
  console.log('📝 Yangi savol yaratildi:', ans.big, '-', ans.small)
  console.log('Variantlar:', set.map(x => x.big).join(', '))
  
  promptId.value = ans.id
  choices.value = shuffle(set)
}

const speakPrompt = async () => {
  const it = letters.value.find(x => x.id === promptId.value)
  if (!it) return
  await play(srcOf(it.audio))
}

const choose = async (c) => {
  console.log('🎯 Tanlangan:', c.big, '| To\'g\'ri javob:', letters.value.find(x => x.id === promptId.value)?.big)
  
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
      // 10-bosqich tugallandi
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
  console.log('🎮 O\'yin boshlandi!')
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
  background: linear-gradient(135deg, #ff4d6d, #ffb703, #00bbf9);
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
  margin-top: 6px;
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
  background: linear-gradient(135deg, #00bbf9, #9b5de5);
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
  gap: 8px;
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
  width: 86px;
  height: 86px;
  object-fit: contain;
  filter: drop-shadow(0 18px 24px rgba(0, 0, 0, .18))
}

.label {
  font-weight: 900;
  font-size: 22px
}
</style>