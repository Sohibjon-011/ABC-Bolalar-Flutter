let current = null

export function useAudio() {
  const stop = () => {
    if (current) {
      try { current.pause() } catch {}
      try { current.currentTime = 0 } catch {}
      current = null
    }
  }

  const play = async (src) => {
    stop()
    const a = new Audio(src)
    current = a
    a.preload = "auto"
    a.volume = 1
    try { await a.play() } catch {}
    a.onended = () => {
      if (current === a) current = null
    }
    return a
  }

  const playSequence = async (list, onStep) => {
    stop()
    for (let i = 0; i < list.length; i++) {
      onStep && onStep(i)
      const a = await play(list[i])
      if (!a) break
      await new Promise((res) => {
        a.onended = res
        a.onerror = res
      })
      if (current === null) break
    }
  }

  return { play, stop, playSequence }
}
