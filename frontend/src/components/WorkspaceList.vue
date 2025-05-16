<template lang="pug">
div.workspace-list
  h1 ワークスペース選択
  //- 作成ボタン
  button.create-btn(@click="showCreateModal = true") ワークスペース作成
  .grid
    div.card(v-for="ws in workspaces" :key="ws.id")
      h2 {{ ws.name }}
      p.description {{ ws.description }}
      //- 参加済みなら「開く」と「進捗を見る」ボタン
      .btn-group(v-if="joinedIds.includes(ws.id)")
        button.enter-btn(@click="goToTasks(ws.id)") ワークスペースを開く
        button.progress-btn(@click="goToProgress(ws.id)") 進捗を見る
      //- 未参加なら「参加」ボタン
      button.join-btn(v-else @click="joinWorkspace(ws.id)") 参加

  //- 作成モーダル
  div.modal(v-if="showCreateModal")
    .modal-content
      h2 新しいワークスペースを作成
      form(@submit.prevent="createWorkspace")
        .field
          label(for="name") 名前
          input#name(type="text" v-model="newWorkspace.name" required)
        .field
          label(for="description") 説明
          textarea#description(v-model="newWorkspace.description")
        .actions
          button(type="submit") 作成
          button(type="button" @click="showCreateModal = false") キャンセル
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router         = useRouter()
const workspaces     = ref([])
const joinedIds      = ref([])

// モーダル制御
const showCreateModal = ref(false)
const newWorkspace    = ref({ name: '', description: '' })

async function fetchWorkspaces() {
  try {
    const { data: all }  = await axios.get('/api/v1/workspaces/public')
    workspaces.value      = all
    const { data: mine } = await axios.get('/api/v1/workspaces', { withCredentials: true })
    joinedIds.value       = mine.map(ws => ws.id)
  } catch (err) {
    console.error('ワークスペース取得失敗', err)
  }
}

async function joinWorkspace(id) {
  try {
    await axios.post(`/api/v1/workspaces/${id}/join`, {}, { withCredentials: true })
    joinedIds.value.push(id)
  } catch (err) {
    console.error('ワークスペース参加失敗', err)
    alert(err.response?.data?.errors?.join('、') || '参加に失敗しました')
  }
}

async function createWorkspace() {
  try {
    await axios.post('/api/v1/workspaces', newWorkspace.value, { withCredentials: true })
    showCreateModal.value = false
    newWorkspace.value    = { name: '', description: '' }
    fetchWorkspaces()
  } catch (err) {
    console.error('ワークスペース作成失敗', err)
    alert(err.response?.data?.errors?.join('、') || '作成に失敗しました')
  }
}

function goToTasks(id) {
  router.push({ name: 'tasks', params: { workspaceId: id } })
}

function goToProgress(id) {
  router.push({ name: 'progress', params: { workspaceId: id } })
}

onMounted(fetchWorkspaces)
</script>

<style scoped lang="scss">
.workspace-list {
  max-width: 800px;
  margin: 2rem auto;
  text-align: center;
}
.create-btn {
  margin-bottom: 1rem;
  padding: .5rem 1rem;
  background: #42b983;
  color: white;
  border: none;
  border-radius: .25rem;
  cursor: pointer;
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
  text-align: left;
  h2 { margin: 0 0 .5rem; }
  .description { font-size: .9rem; color: #555; margin-bottom: .5rem; }
}
.btn-group {
  display: flex;
  gap: 0.5rem;
}
.join-btn,
.enter-btn,
.progress-btn {
  padding: .5rem 1rem;
  border: none;
  border-radius: .25rem;
  cursor: pointer;
}
.join-btn {
  background: #42b983;
  color: white;
}
.enter-btn {
  background: #3477eb;
  color: white;
}
.progress-btn {
  background: #ff9900;
  color: white;
}

/* モーダルスタイル */
.modal {
  position: fixed;
  top: 0; left: 0;
  width: 100%; height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}
.modal-content {
  background: white;
  padding: 2rem;
  border-radius: .5rem;
  width: 90%; max-width: 400px;
}
.field { margin-bottom: 1rem; text-align: left; }
.field label { display: block; margin-bottom: .5rem; }
.field input,
.field textarea { width: 100%; padding: .5rem; border: 1px solid #ccc; border-radius: .25rem; }
.actions { text-align: right; }
.actions button { margin-left: .5rem; }
</style>
