import { createRouter, createWebHistory } from 'vue-router'
import Signup from '@/components/Signup.vue'
import Login  from '@/components/Login.vue'
import Logout from '@/components/Logout.vue'

const routes = [
  { path: '/signup', component: Signup },
  { path: '/login',  component: Login },
  { path: '/logout', component: Logout },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
