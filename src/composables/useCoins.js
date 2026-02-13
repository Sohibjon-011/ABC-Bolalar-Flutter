import { computed } from "vue"
import { useStorage } from "./useStorage"

export function useCoins() {
  const coins = useStorage("abc_coins", 5)
  const purchased = useStorage("abc_purchased", { words: {}, phrases: {} })
  const cart = useStorage("abc_cart", { words: {}, phrases: {} })

  const addCoins = (n) => {
    coins.value = Math.max(0, Number(coins.value || 0) + Number(n || 0))
  }

  const spendCoins = (n) => {
    const need = Number(n || 0)
    if (coins.value < need) return false
    coins.value = coins.value - need
    return true
  }

  const ownedWord = (id) => !!purchased.value.words[id]
  const ownedPhrase = (id) => !!purchased.value.phrases[id]

  const cartCount = computed(() => {
    const w = Object.keys(cart.value.words || {}).length
    const p = Object.keys(cart.value.phrases || {}).length
    return w + p
  })

  const addToCart = (type, id, item) => {
    if (type === "words") cart.value.words[id] = item
    else cart.value.phrases[id] = item
  }

  const removeFromCart = (type, id) => {
    if (type === "words") delete cart.value.words[id]
    else delete cart.value.phrases[id]
  }

  const clearCart = () => {
    cart.value = { words: {}, phrases: {} }
  }

  const checkout = () => {
    const words = Object.values(cart.value.words || {})
    const phrases = Object.values(cart.value.phrases || {})
    const total = words.length * 1 + phrases.length * 5
    if (!spendCoins(total)) return { ok: false, need: total }
    words.forEach((it) => purchased.value.words[it.id] = it)
    phrases.forEach((it) => purchased.value.phrases[it.id] = it)
    clearCart()
    return { ok: true, spent: total }
  }

  return {
    coins,
    purchased,
    cart,
    cartCount,
    addCoins,
    spendCoins,
    ownedWord,
    ownedPhrase,
    addToCart,
    removeFromCart,
    checkout
  }
}
