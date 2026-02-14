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
        <div class="gTitle">🎮 Hayvon o‘yini</div>
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
import { useCoins } from "../composables/useCoins"

const emit = defineEmits(["toast"])
const fx = inject("fx")
const { play, playSequence } = useAudio()
const { addCoins } = useCoins()

const baseAudio = "/MP4/"
const startAudio = 50
const srcOf = (n) => baseAudio + n + ".ogg"

const animals = ref([
  { id: "cat", big: "😺", emoji: "😺", img: "https://openmoji.org/data/color/svg/1F408.svg", audio: startAudio + 0 },
  { id: "dog", big: "🐶", emoji: "🐶", img: "https://openmoji.org/data/color/svg/1F415.svg", audio: startAudio + 1 },
  { id: "cow", big: "🐮", emoji: "🐮", img: "https://openmoji.org/data/color/svg/1F404.svg", audio: startAudio + 2 },
  { id: "sheep", big: "🐑", emoji: "🐑", img: "https://openmoji.org/data/color/svg/1F411.svg", audio: startAudio + 3 },
  { id: "horse", big: "🐴", emoji: "🐴", img: "https://openmoji.org/data/color/svg/1F40E.svg", audio: startAudio + 4 },
  { id: "lion", big: "🦁", emoji: "🦁", img: "https://openmoji.org/data/color/svg/1F981.svg", audio: startAudio + 5 },
  { id: "elephant", big: "🐘", emoji: "🐘", img: "https://openmoji.org/data/color/svg/1F418.svg", audio: startAudio + 6 },
  { id: "rabbit", big: "🐰", emoji: "🐰", img: "https://openmoji.org/data/color/svg/1F407.svg", audio: startAudio + 7 },
  { id: "duck", big: "🦆", emoji: "🦆", img: "https://openmoji.org/data/color/svg/1F986.svg", audio: startAudio + 8 },
  { id: "fish", big: "🐟", emoji: "🐟", img: "https://openmoji.org/data/color/svg/1F41F.svg", audio: startAudio + 9 }
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
  promptId.value = ans.id
  choices.value = shuffle(set)
}

const speakPrompt = async () => {
  const it = animals.value.find(x => x.id === promptId.value)
  if (!it) return
  await play(srcOf(it.audio))
}

const choose = async (c) => {
  if (c.id === promptId.value) {
    emit("toast", "🎉", "+" + level.value + " tanga")
    addCoins(level.value)
    if (level.value < 10) level.value++
    makeRound()
  } else {
    emit("toast", "😺", "Yana bir bor!")
    await speakPrompt()
  }
}

onMounted(() => makeRound())
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
}

.choice img {
  width: 92px;
  height: 92px;
  object-fit: contain;
  filter: drop-shadow(0 18px 24px rgba(0, 0, 0, .18))
}

.label {
  font-weight: 900;
  font-size: 18px
}
</style>
