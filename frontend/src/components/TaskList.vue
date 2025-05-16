<!-- src/components/TaskList.vue -->
<template lang="pug">
div.task-list
  h1 {{ workspaceName }} のタスク一覧

  .actions
    button.back(@click="goBack") 戻る
    button.new-task(@click="showCreateTask = true") 新しいタスクを作成

  ul.tasks
    li.task-item(v-for="task in tasks" :key="task.id")
      h2.title {{ task.title }}
      p.content {{ task.content }}
      p.meta
        | 担当者: {{ task.user.name }}　
        | カテゴリ: {{ task.category }}　
        | ステータス: {{ task.status }}　
        | 締切: {{ task.due_date }}
      .buttons
        button.edit-btn(@click="openEditModal(task)") 編集
        button.del-btn(@click="deleteTask(task.id)") 削除

  //- 新規作成モーダル
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
          select#category(v-model="newTask.category" required)
            option(value="" disabled) — 選択してください —
            option(v-for="cat in CATEGORIES" :key="cat" :value="cat") {{ cat }}
        // ステータスは常に pending
        input(type="hidden" v-model="newTask.status")
        .actions
          button(type="submit") 作成
          button(type="button" @click="showCreateTask = false") キャンセル

  //- 編集モーダル
  div.modal(v-if="showEditTask")
    .modal-content
      h2 タスクを編集
      form(@submit.prevent="updateTask")
        .field
          label(for="edit-title") タイトル
          input#edit-title(type="text" v-model="editTask.title" required)
        .field
          label(for="edit-content") 詳細
          textarea#edit-content(v-model="editTask.content")
        .field
          label(for="edit-due_date") 締切日
          input#edit-due_date(type="date" v-model="editTask.due_date" required)
        .field
          label(for="edit-category") カテゴリ
          select#edit-category(v-model="editTask.category" required)
            option(value="" disabled) — 選択してください —
            option(v-for="cat in CATEGORIES" :key="cat" :value="cat") {{ cat }}
        .field
          label(for="edit-status") ステータス
          select#edit-status(v-model="editTask.status" required)
            option(value="" disabled) — 選択してください —
            option(v-for="st in STATUSES" :key="st" :value="st") {{ st }}
        .actions
          button(type="submit") 更新
          button(type="button" @click="showEditTask = false") キャンセル
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

// 고정된 선택지
const CATEGORIES = ['feature', 'bugfix', 'research']
const STATUSES   = ['pending', 'in_progress', 'completed']

const route       = useRoute()
const router      = useRouter()
const workspaceId = route.params.workspaceId

const tasks          = ref([])
const workspaceName  = ref('')
const showCreateTask = ref(false)
const showEditTask   = ref(false)

const newTask = ref({
  title:   '',
  content: '',
  due_date: '',
  category: '',
  status:  'pending'
})

const editTask = ref({
  id:       null,
  title:    '',
  content:  '',
  due_date: '',
  category: '',
  status:   ''
})

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

async function createTask() {
  try {
    const { data: created } = await axios.post(
      `/api/v1/workspaces/${workspaceId}/tasks`,
      { task: newTask.value },
      { withCredentials: true }
    )
    tasks.value.push(created)
    showCreateTask.value = false
    newTask.value = {
      title:   '',
      content: '',
      due_date: '',
      category: '',
      status:  'pending'
    }
  } catch (err) {
    console.error('タスク作成失敗', err)
    alert(err.response?.data?.errors?.join('、') || 'タスクの作成に失敗しました')
  }
}

async function deleteTask(id) {
  if (!confirm('本当に削除しますか？')) return
  try {
    await axios.delete(`/api/v1/tasks/${id}`, { withCredentials: true })
    tasks.value = tasks.value.filter(t => t.id !== id)
  } catch (err) {
    console.error('タスク削除失敗', err)
    alert('削除に失敗しました')
  }
}

function openEditModal(task) {
  editTask.value = { ...task }
  showEditTask.value = true
}

async function updateTask() {
  try {
    const { id, ...payload } = editTask.value
    const { data: updated } = await axios.patch(
      `/api/v1/tasks/${id}`,
      { task: payload },
      { withCredentials: true }
    )
    tasks.value = tasks.value.map(t => t.id === id ? updated : t)
    showEditTask.value = false
  } catch (err) {
    console.error('タスク更新失敗', err)
    alert(err.response?.data?.errors?.join('、') || 'タスクの更新に失敗しました')
  }
}

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
.new-task { background: #42b983; color: white; }

.tasks {
  list-style: none;
  padding: 0;
}
.task-item {
  border: 1px solid #ddd;
  border-radius: .5rem;
  padding: 1rem;
  margin-bottom: 1rem;
  position: relative;
}
.meta { font-size: .9rem; color: #555; margin: .5rem 0; }
.buttons {
  position: absolute;
  top: 1rem; right: 1rem;
}
.edit-btn,
.del-btn {
  margin-left: .5rem;
  padding: .25rem .5rem;
  border: none;
  border-radius: .25rem;
  cursor: pointer;
}
.edit-btn { background: #3477eb; color: white; }
.del-btn  { background: #e34c4c; color: white; }

.modal {
  position: fixed; top: 0; left: 0;
  width:100%; height:100%;
  background: rgba(0,0,0,0.5);
  display: flex; justify-content: center; align-items: center;
}
.modal-content {
  background: white;
  padding: 2rem;
  border-radius: .5rem;
  width: 90%; max-width: 400px;
}
.field { margin-bottom: 1rem; }
.field label { display: block; margin-bottom: .5rem; }
.field input,
.field textarea,
.field select {
  width: 100%; padding: .5rem;
  border: 1px solid #ccc; border-radius: .25rem;
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
