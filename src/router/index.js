import { createRouter, createWebHistory } from "vue-router"
import AbcPage from "../pages/AbcPage.vue"
import NumbersPage from "../pages/NumbersPage.vue"
import ColorsPage from "../pages/ColorsPage.vue"
import AnimalsPage from "../pages/AnimalsPage.vue"
import CartPage from "../pages/CartPage.vue"

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", redirect: "/abc" },
    { path: "/abc", component: AbcPage },
    { path: "/numbers", component: NumbersPage },
    { path: "/colors", component: ColorsPage },
    { path: "/animals", component: AnimalsPage },
    { path: "/cart", component: CartPage }
  ],
  scrollBehavior() {
    return { top: 0 }
  }
})



export default router
