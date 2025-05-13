<!-- src/components/TaskList.vue -->
<template lang="pug">
div.task-list
  h1 {{ workspaceName }} のタスク一覧
  .actions
    button.back(@click="goBack") 戻る
    button.new-task(@click="showCreateTask = true") 新しいタスクを作成
  //- タスク一覧
  ul.tasks
    li.task-item(v-for="task in tasks" :key="task.id")
      h2.title {{ task.title }}
      p.content {{ task.content }}
      p.meta
        | 担当者: {{ task.user.name }}　
        | ステータス: {{ task.status }}　
        | 締切: {{ task.due_date }}
  //- 新規タスク作成モーダル
  div.modal(v-if="showCreateTask")
    .modal-content
      h2 新しいタスクを作成
      form(@submit.prevent="createTask")
        .field
          label(for="title") タイトル
          input#title(type="text" v-model="newTask.title" required)
        .field
          label(for="content") 詳細
          textarea#content(v-model="newTask.content")
        .field
          label(for="due_date") 締切日
          input#due_date(type="date" v-model="newTask.due_date" required)
        .field
          label(for="category") カテゴリ
          input#category(type="text" v-model="newTask.category")
        //- ステータスは常に pending、hidden で送信
        input(type="hidden" v-model="newTask.status")
        .actions
          button(type="submit") 作成
          button(type="button" @click="showCreateTask = false") キャンセル
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

// ルーターから workspaceId を取得
const route         = useRoute()
const router        = useRouter()
const workspaceId   = route.params.workspaceId

// 状態定義
const tasks          = ref([])
const workspaceName  = ref('')
const showCreateTask = ref(false)
const newTask        = ref({
  title:    '',
  content:  '',
  due_date: '',
  category: '',
  status:   'pending'  // ← 固定値
})

// タスク一覧とワークスペース名を取得
async function fetchTasks() {
  try {
    const { data: ws } = await axios.get(
      `/api/v1/workspaces/${workspaceId}`,
      { withCredentials: true }
    )
    workspaceName.value = ws.name

    const { data: list } = await axios.get(
      `/api/v1/workspaces/${workspaceId}/tasks`,
      { withCredentials: true }
    )
    tasks.value = list
  } catch (err) {
    console.error('タスク取得失敗', err)
    alert('タスクの取得に失敗しました')
  }
}

// 新規タスク作成
async function createTask() {
  try {
    const payload = { task: newTask.value }
    const { data: created } = await axios.post(
      `/api/v1/workspaces/${workspaceId}/tasks`,
      payload,
      { withCredentials: true }
    )
    tasks.value.push(created)
    showCreateTask.value = false
    newTask.value = {
      title:    '',
      content:  '',
      due_date: '',
      category: '',
      status:   'pending'
    }
  } catch (err) {
    console.error('タスク作成失敗', err)
    alert(err.response?.data?.errors?.join('、') || 'タスクの作成に失敗しました')
  }
}

// 戻るボタン
function goBack() {
  router.back()
}

onMounted(fetchTasks)
</script>

<style scoped lang="scss">
.task-list {
  max-width: 800px;
  margin: 2rem auto;
}
.actions {
  margin-bottom: 1rem;
}
.back,
.new-task {
  padding: .5rem 1rem;
  margin-right: .5rem;
  border: none;
  border-radius: .25rem;
  cursor: pointer;
}
.new-task {
  background: #42b983;
  color: white;
}

/* タスク一覧スタイル */
.tasks {
  list-style: none;
  padding: 0;
}
.task-item {
  border: 1px solid #ddd;
  border-radius: .5rem;
  padding: 1rem;
  margin-bottom: 1rem;
}
.title {
  margin: 0 0 .5rem;
  font-size: 1.2rem;
}
.meta {
  font-size: .9rem;
  color: #555;
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
.field {
  margin-bottom: 1rem;
}
.field label {
  display: block;
  margin-bottom: .5rem;
}
.field input,
.field textarea {
  width: 100%;
  padding: .5rem;
  border: 1px solid #ccc;
  border-radius: .25rem;
}
.actions {
  text-align: right;
}
.actions button {
  margin-left: .5rem;
  padding: .5rem 1rem;
  border: none;
  border-radius: .25rem;
  cursor: pointer;
}
</style>
