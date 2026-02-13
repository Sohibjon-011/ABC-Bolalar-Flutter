import { ref, watch } from "vue"

export function useStorage(key, initialValue) {
  const v = ref(initialValue)
  try {
    const raw = localStorage.getItem(key)
    if (raw !== null) v.value = JSON.parse(raw)
  } catch {}
  watch(v, (nv) => {
    try { localStorage.setItem(key, JSON.stringify(nv)) } catch {}
  }, { deep: true })
  return v
}
