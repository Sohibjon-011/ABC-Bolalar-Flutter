<template>
  <div class="fx" aria-hidden="true">
    <div v-for="p in pops" :key="p.id" class="pop" :style="p.style">{{ p.ch }}</div>
    <div v-for="c in confetti" :key="c.id" class="conf" :style="c.style"></div>
    <div v-for="m in coins" :key="m.id" class="fly" :style="m.style">🪙</div>
  </div>
</template>

<script setup>
import { ref } from "vue"

const pops = ref([])
const confetti = ref([])
const coins = ref([])

const uid = () => Math.random().toString(16).slice(2) + Date.now().toString(16)

const celebrate = (kind = "trophy") => {
  const id = uid()
  const ch = kind === "trophy" ? "🏆" : kind === "star" ? "🌟" : "🎉"
  pops.value.push({
    id,
    ch,
    style: {
      left: "50%",
      top: "42%",
      transform: "translate(-50%,-50%)",
      animation: "pop 900ms ease both"
    }
  })
  setTimeout(() => pops.value = pops.value.filter(x => x.id !== id), 950)

  const base = Date.now()
  const many = 28
  const arr = []
  for (let i = 0; i < many; i++) {
    const idc = uid() + i
    const x = 50 + (Math.random() * 40 - 20)
    const y = 50 + (Math.random() * 30 - 15)
    const r = Math.random() * 360
    const s = 6 + Math.random() * 8
    arr.push({
      id: idc,
      style: {
        left: x + "%",
        top: y + "%",
        transform: `translate(-50%,-50%) rotate(${r}deg)`,
        width: s + "px",
        height: (s * 1.6) + "px",
        animation: `fall ${900 + Math.random()*600}ms ease-out both`
      }
    })
  }
  confetti.value = confetti.value.concat(arr)
  setTimeout(() => {
    confetti.value = confetti.value.filter(x => (x.id + "").indexOf(base + "") === -1)
  }, 1700)
}

const coinFly = (fromRect, toRect) => {
  const id = uid()
  const dx = (toRect.left + toRect.width/2) - (fromRect.left + fromRect.width/2)
  const dy = (toRect.top + toRect.height/2) - (fromRect.top + fromRect.height/2)
  coins.value.push({
    id,
    style: {
      left: (fromRect.left + fromRect.width/2) + "px",
      top: (fromRect.top + fromRect.height/2) + "px",
      transform: "translate(-50%,-50%)",
      "--dx": dx + "px",
      "--dy": dy + "px",
      animation: "fly 700ms cubic-bezier(.2,.9,.1,1) both"
    }
  })
  setTimeout(() => coins.value = coins.value.filter(x => x.id !== id), 720)
}

defineExpose({ celebrate, coinFly })
</script>

<style scoped>
.fx{position:fixed;inset:0;pointer-events:none;z-index:85}
.pop{
  position:absolute;font-size:86px;
  filter:drop-shadow(0 30px 35px rgba(0,0,0,.25));
}
.conf{
  position:absolute;border-radius:4px;
  background: linear-gradient(180deg, #ff4d6d, #00bbf9, #9b5de5, #ffb703);
  filter:drop-shadow(0 10px 12px rgba(0,0,0,.12));
}
.fly{
  position:absolute;font-size:30px;
  filter:drop-shadow(0 18px 20px rgba(0,0,0,.2));
}
@keyframes pop{
  0%{opacity:0;transform:translate(-50%,-50%) scale(.6) rotate(-8deg)}
  60%{opacity:1;transform:translate(-50%,-50%) scale(1.08) rotate(8deg)}
  100%{opacity:0;transform:translate(-50%,-50%) scale(.95) rotate(0deg)}
}
@keyframes fall{
  0%{opacity:0;transform:translate(-50%,-50%) rotate(0deg) scale(.7)}
  20%{opacity:1}
  100%{opacity:0;transform:translate(calc(-50% + (var(--dx, 0px) * .02)), calc(-50% + 260px)) rotate(220deg) scale(1)}
}
@keyframes fly{
  0%{opacity:1;transform:translate(-50%,-50%) scale(1)}
  70%{opacity:1;transform:translate(calc(-50% + var(--dx)), calc(-50% + var(--dy))) scale(1.1)}
  100%{opacity:0;transform:translate(calc(-50% + var(--dx)), calc(-50% + var(--dy))) scale(.85)}
}
</style>
