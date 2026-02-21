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

createApp(App).use(router).mount("#app")