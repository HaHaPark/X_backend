import { createRouter, createWebHistory } from 'vue-router'
import Signup from '@/components/Signup.vue'
import Login  from '@/components/Login.vue'
import Logout from '@/components/Logout.vue'
import WorkspaceList from '@/components/WorkspaceList.vue'
import TaskList      from '@/components/TaskList.vue'

const routes = [
  { path: '/signup', component: Signup },
  { path: '/login',  component: Login },
  { path: '/logout', component: Logout },
  { path: '/workspaces', name: 'workspaces', component: WorkspaceList },
  {
    path: '/workspaces/:workspaceId/tasks',
    name: 'tasks',
    component: TaskList,
    props: true
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
