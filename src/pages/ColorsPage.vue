<template>
  <section class="page">
    <div class="hero">
      <div class="hL">
        <div class="hTitle">🎨 Ranglar</div>
        <div class="hSub">Bos → ovoz 🎵</div>
      </div>
      <button class="playAll" @click="playAll" :disabled="playingAll">
        <span>▶️</span><b>Hammasini ijro etish</b>
      </button>
    </div>

    <div class="grid">
      <button v-for="it in colors" :key="it.id" class="cCard" :class="{active: activeId===it.id}" @click="pick(it)">
        <div class="blob" :style="{ background: it.hex }"></div>
        <div class="cap">{{ it.emoji }}</div>
      </button>
    </div>

    <div class="game">
      <div class="gTop">
        <div class="gTitle">🎮 Rang o‘yini</div>
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
          <div class="blob2" :style="{ background: c.hex }"></div>
          <div class="label">{{ c.emoji }}</div>
        </button>
      </div>
    </div>
  </section>
</template>

<script setup>
import { inject, onMounted, ref } from "vue"
import { useAudio } from "../composables/useAudio"
import { useCoins } from "../composables/useCoins"

const emit = defineEmits(["toast"])
const fx = inject("fx")
const { play, playSequence } = useAudio()
const { addCoins } = useCoins()

const baseAudio = "/MP4/"
const startAudio = 50
const srcOf = (n) => baseAudio + n + ".ogg"

const colors = ref([
  { id:"red", emoji:"🔴", hex:"#ff4d6d", audio:startAudio+0 },
  { id:"blue", emoji:"🔵", hex:"#00bbf9", audio:startAudio+1 },
  { id:"yellow", emoji:"🟡", hex:"#ffb703", audio:startAudio+2 },
  { id:"green", emoji:"🟢", hex:"#2ec4b6", audio:startAudio+3 },
  { id:"purple", emoji:"🟣", hex:"#9b5de5", audio:startAudio+4 },
  { id:"orange", emoji:"🟠", hex:"#fb8500", audio:startAudio+5 },
  { id:"pink", emoji:"💗", hex:"#ff7aa2", audio:startAudio+6 },
  { id:"brown", emoji:"🟤", hex:"#a47148", audio:startAudio+7 },
  { id:"black", emoji:"⚫", hex:"#111827", audio:startAudio+8 },
  { id:"white", emoji:"⚪", hex:"#f8fafc", audio:startAudio+9 }
])

const activeId = ref(null)
const playingAll = ref(false)

const pick = async (it) => {
  activeId.value = it.id
  await play(srcOf(it.audio))
}

const playAll = async () => {
  playingAll.value = true
  const list = colors.value.map(x => srcOf(x.audio))
  await playSequence(list, (i) => activeId.value = colors.value[i].id)
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
  const set = shuffle(colors.value).slice(0, k)
  const ans = set[Math.floor(Math.random() * set.length)]
  promptId.value = ans.id
  choices.value = shuffle(set)
}

const speakPrompt = async () => {
  const it = colors.value.find(x => x.id === promptId.value)
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
.page{display:grid;gap:14px}
.hero{
  display:flex;align-items:center;justify-content:space-between;gap:12px;
  padding:14px;border-radius:24px;
  background: color-mix(in oklab, var(--card) 80%, transparent);
  border:1px solid var(--brd);
  box-shadow: var(--shadowM);
}
.hTitle{font-weight:900;font-size:22px}
.hSub{opacity:.8;font-size:13px}
.playAll{
  display:flex;gap:10px;align-items:center;
  padding:12px 14px;border-radius:18px;
  border:1px solid var(--brd);
  background: linear-gradient(135deg, #9b5de5, #00bbf9, #ffb703);
  color:white;font-weight:900;
  box-shadow: 0 18px 45px rgba(0,0,0,.22);
}
.grid{display:grid;gap:12px;grid-template-columns: repeat(2, minmax(0,1fr));}
@media (min-width:520px){.grid{grid-template-columns: repeat(5, minmax(0,1fr));}}
.cCard{
  width:100%;
  padding:12px;border-radius:22px;
  background: color-mix(in oklab, var(--card) 86%, transparent);
  border:1px solid var(--brd);
  box-shadow: var(--shadowS);
  display:grid;gap:10px;justify-items:center;
  transition:.18s ease;
}
.cCard:hover{transform:translateY(-4px)}
.cCard.active{outline:3px solid color-mix(in oklab, var(--acc) 60%, transparent)}
.blob{
  width:84px;height:84px;border-radius:28px;
  box-shadow: 0 20px 45px rgba(0,0,0,.18);
  border:1px solid color-mix(in oklab, var(--brd) 60%, transparent);
}
.cap{font-size:22px;font-weight:900}
.game{
  padding:14px;border-radius:26px;
  background: color-mix(in oklab, var(--card) 82%, transparent);
  border:1px solid var(--brd);
  box-shadow: var(--shadowM);
  display:grid;gap:12px;
}
.gTop{display:flex;justify-content:space-between;align-items:center}
.gTitle{font-weight:900}
.lvl{opacity:.85}
.prompt{display:grid;place-items:center;padding:6px}
.bigBtn{
  width:min(320px, 100%);
  padding:16px 16px;border-radius:22px;
  border:1px solid var(--brd);
  background: linear-gradient(135deg, #00bbf9, #ff4d6d);
  color:white;font-weight:900;
  display:flex;gap:12px;align-items:center;justify-content:center;
}
.ico{font-size:22px}
.choices{display:grid;gap:12px;grid-template-columns: repeat(2, minmax(0,1fr));}
@media (min-width:520px){.choices{grid-template-columns: repeat(3, minmax(0,1fr));}}
.choice{
  border-radius:22px;padding:12px;
  background: color-mix(in oklab, var(--card) 86%, transparent);
  border:1px solid var(--brd);
  box-shadow: var(--shadowS);
  display:grid;gap:10px;justify-items:center;
}
.blob2{
  width:92px;height:92px;border-radius:30px;
  box-shadow: 0 22px 55px rgba(0,0,0,.20);
  border:1px solid color-mix(in oklab, var(--brd) 60%, transparent);
}
.label{font-weight:900;font-size:18px}
</style>
