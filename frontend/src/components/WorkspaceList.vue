<!-- src/components/WorkspaceList.vue -->
<template lang="pug">
div.workspace-list
  h1 워크스페이스 선택
  .grid
    //- 전체 워크스페이스 카드
    div.card(v-for="ws in workspaces" :key="ws.id")
      h2 {{ ws.name }}
      p.description {{ ws.description }}
      //- 이미 참여한 워크스페이스
      button.joined(v-if="joinedIds.includes(ws.id)" disabled) 참여됨
      //- 아직 참여하지 않은 워크스페이스
      button.join-btn(v-else @click="joinWorkspace(ws.id)") 참가
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const workspaces = ref([])
const joinedIds  = ref([])

async function fetchWorkspaces() {
  try {
    // 전체 공개 워크스페이스
    const { data: all } = await axios.get('/api/v1/workspaces/public')
    workspaces.value = all

    // 내가 속한 워크스페이스
    const { data: mine } = await axios.get('/api/v1/workspaces', { withCredentials: true })
    joinedIds.value = mine.map(ws => ws.id)
  } catch (err) {
    console.error('워크스페이스 불러오기 실패', err)
  }
}

async function joinWorkspace(id) {
  try {
    await axios.post(`/api/v1/workspaces/${id}/join`, {}, { withCredentials: true })
    joinedIds.value.push(id)
  } catch (err) {
    console.error('워크스페이스 참가 실패', err)
    alert(err.response?.data?.errors?.join('、') || '참가에 실패했습니다')
  }
}

function goToTasks(id) {
  router.push({ name: 'tasks', params: { workspaceId: id } })
}

onMounted(fetchWorkspaces)
</script>

<style scoped lang="scss">
.workspace-list {
  max-width: 800px;
  margin: 2rem auto;
}
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 1rem;
}
.card {
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: .5rem;
  h2 { margin: 0 0 .5rem; }
  .description { font-size: .9rem; color: #555; margin-bottom: .5rem; }
}
button {
  padding: .5rem 1rem;
  border: none;
  border-radius: .25rem;
  cursor: pointer;
}
.join-btn {
  background: #42b983;
  color: white;
}
.joined {
  background: #ccc;
  color: #666;
  cursor: default;
}
</style>
