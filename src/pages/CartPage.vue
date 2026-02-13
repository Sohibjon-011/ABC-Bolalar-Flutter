<template>
  <section class="page">
    <div class="hero">
      <div class="hL">
        <div class="hTitle">🛒 Korzinka</div>
        <div class="hSub">Sotib ol → ochilsin ✅</div>
      </div>
      <button class="buy" @click="buyAll" :disabled="total===0">
        <span>💳</span><b>Sotib olish</b>
        <i>🪙{{ total }}</i>
      </button>
    </div>

    <div class="box">
      <div class="sec">
        <div class="st">🧺 So‘zlar</div>
        <div v-if="wordItems.length===0" class="empty">—</div>
        <div v-else class="list">
          <div class="row" v-for="it in wordItems" :key="it.id">
            <span class="e">{{ it.emoji }}</span>
            <b class="t">{{ it.text }}</b>
            <span class="p">🪙1</span>
            <button class="x" @click="remove('words', it.id)">✖️</button>
          </div>
        </div>
      </div>

      <div class="sec">
        <div class="st">💬 Gaplar</div>
        <div v-if="phraseItems.length===0" class="empty">—</div>
        <div v-else class="list">
          <div class="row" v-for="it in phraseItems" :key="it.id">
            <span class="e">{{ it.emoji }}</span>
            <b class="t">{{ it.text }}</b>
            <span class="p">🪙5</span>
            <button class="x" @click="remove('phrases', it.id)">✖️</button>
          </div>
        </div>
      </div>
    </div>

    <div class="owned">
      <div class="ot">✅ Ochildi</div>
      <div class="pillRow">
        <span class="pill" v-for="it in ownedTop" :key="it">{{ it }}</span>
        <span v-if="ownedTop.length===0" class="pill">—</span>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed } from "vue"
import { useCoins } from "../composables/useCoins"

const emit = defineEmits(["toast"])
const { cart, removeFromCart, checkout, purchased } = useCoins()

const wordItems = computed(() => Object.values(cart.value.words || {}))
const phraseItems = computed(() => Object.values(cart.value.phrases || {}))
const total = computed(() => wordItems.value.length * 1 + phraseItems.value.length * 5)

const remove = (type, id) => removeFromCart(type, id)

const buyAll = () => {
  const res = checkout()
  if (!res.ok) {
    emit("toast", "🪙", "Yetmadi!")
    return
  }
  emit("toast", "✅", "Sotib olindi!")
}

const ownedTop = computed(() => {
  const w = Object.values(purchased.value.words || {}).slice(0, 10).map(x => x.emoji + " " + x.text)
  const p = Object.values(purchased.value.phrases || {}).slice(0, 6).map(x => x.emoji + " " + x.text)
  return w.concat(p)
})
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
.buy{
  display:flex;gap:10px;align-items:center;
  padding:12px 14px;border-radius:18px;
  border:1px solid var(--brd);
  background: linear-gradient(135deg, #00bbf9, #2ec4b6);
  color:white;font-weight:900;
}
.buy i{font-style:normal;opacity:.95}
.buy:disabled{opacity:.55}
.box{
  display:grid;gap:12px;
  padding:14px;border-radius:26px;
  background: color-mix(in oklab, var(--card) 80%, transparent);
  border:1px solid var(--brd);
  box-shadow: var(--shadowM);
}
.sec{display:grid;gap:10px}
.st{font-weight:900}
.empty{opacity:.7}
.list{display:grid;gap:10px}
.row{
  display:grid;grid-template-columns: 34px 1fr 54px 44px;
  gap:10px;align-items:center;
  padding:12px;border-radius:20px;
  background: color-mix(in oklab, var(--card) 88%, transparent);
  border:1px solid var(--brd);
  box-shadow: var(--shadowS);
}
.e{font-size:22px}
.t{font-weight:900}
.p{font-weight:900;opacity:.9}
.x{
  width:44px;height:44px;border-radius:16px;
  border:1px solid var(--brd);
  background: color-mix(in oklab, var(--card) 92%, transparent);
}
.owned{
  padding:14px;border-radius:26px;
  background: color-mix(in oklab, var(--card) 76%, transparent);
  border:1px solid var(--brd);
  box-shadow: var(--shadowS);
  display:grid;gap:10px;
}
.ot{font-weight:900}
.pillRow{display:flex;gap:10px;flex-wrap:wrap}
.pill{
  padding:10px 12px;border-radius:999px;
  background: color-mix(in oklab, var(--card) 90%, transparent);
  border:1px solid var(--brd);
  font-weight:900;
}
</style>
