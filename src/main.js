import { createApp } from "vue"
import App from "./App.vue"
import router from "./router"

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker
      .register('/service-worker.js')
      .then(() => console.log("Service Worker registered"))
      .catch(err => console.log("SW error:", err))
  })
}

let deferredPrompt = null

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault()
  deferredPrompt = e
  window.dispatchEvent(new Event('pwa-install-available'))
})

window.installPWA = async () => {
  if (!deferredPrompt) return
  deferredPrompt.prompt()
  await deferredPrompt.userChoice
  deferredPrompt = null
}

createApp(App).use(router).mount("#app")