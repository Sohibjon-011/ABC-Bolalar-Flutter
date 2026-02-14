<template>
  <button class="card" @click="$emit('pick')" :class="{ active }">
    <div class="pic">
      <img v-if="img" :src="img" alt="" />
      <div v-else class="emoji">{{ emoji }}</div>
    </div>
    <div class="cap">
      <div class="big">{{ big }}</div>
      <div class="small" v-if="small">{{ small }}</div>
    </div>
  </button>
</template>

<script setup>
defineProps({
  img: String,
  emoji: String,
  big: String,
  small: String,
  active: Boolean
})
defineEmits(["pick"])
</script>

<style scoped>
.card {
  width: 100%;
  display: grid;
  grid-template-rows: 1fr auto;
  gap: 10px;
  padding: 12px;
  border-radius: 22px;
  background: color-mix(in oklab, var(--card) 86%, transparent);
  border: 1px solid var(--brd);
  box-shadow: var(--shadowS);
  transition: .18s ease;
}

.card:hover {
  transform: translateY(-4px)
}

.card:active {
  transform: translateY(-2px) scale(.99)
}

.card.active {
  outline: 3px solid color-mix(in oklab, var(--acc) 60%, transparent);
  box-shadow: 0 20px 60px color-mix(in oklab, var(--glow) 42%, transparent);
}

.pic {
  border-radius: 18px;
  display: grid;
  place-items: center;
  background: linear-gradient(135deg, color-mix(in oklab, var(--acc2) 18%, transparent), color-mix(in oklab, var(--acc3) 16%, transparent));
  border: 1px dashed color-mix(in oklab, var(--brd) 60%, transparent);
  overflow: hidden;
  min-height: 92px;
}

.pic img {
  width: 92px;
  height: 92px;
  object-fit: contain;
  filter: drop-shadow(0 18px 24px rgba(0, 0, 0, .18))
}

.emoji {
  font-size: 52px;
  filter: drop-shadow(0 18px 24px rgba(0, 0, 0, .18))
}

.cap {
  display: grid;
  gap: 2px;
  justify-items: center
}

.big {
  font-weight: 900;
  font-size: 22px;
  line-height: 1
}

.small {
  opacity: .8;
  font-size: 12px
}
</style>
