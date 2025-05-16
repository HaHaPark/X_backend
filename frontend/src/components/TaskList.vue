<!-- src/components/TaskList.vue -->
<template lang="pug">
div.task-list
  h1 {{ workspaceName }} のタスク一覧

  //- フィルターセクション
  .filters
    select(v-model="selectedAssignee" @change="fetchTasks")
      option(value="") — 担当者で絞り込み —
      option(v-for="u in assignees" :key="u.id" :value="u.id") {{ u.name }}
    select(v-model="selectedCategory" @change="fetchTasks")
      option(value="") — カテゴリで絞り込み —
      option(v-for="cat in CATEGORIES" :key="cat" :value="cat") {{ cat }}
    select(v-model="selectedStatus" @change="fetchTasks")
      option(value="") — ステータスで絞り込み —
      option(v-for="st in STATUSES" :key="st" :value="st") {{ st }}

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
    div.modal-overlay(@click="showCreateTask = false")
    div.modal-content
      h2.modal-title 新しいタスクを作成
      form.form-container(@submit.prevent="createTask")
        .form-field
          label(for="title") タイトル
          input#title(type="text" v-model="newTask.title" required placeholder="タスクのタイトルを入力")
        .form-field
          label(for="content") 詳細
          textarea#content(v-model="newTask.content" placeholder="詳細を入力")
        .form-field
          label(for="due_date") 締切日
          input#due_date(type="date" v-model="newTask.due_date" required)
        .form-field
          label(for="category") カテゴリ
          select#category(v-model="newTask.category" required)
            option(value="" disabled) — 選択してください —
            option(v-for="cat in CATEGORIES" :key="cat" :value="cat") {{ cat }}
        input(type="hidden" v-model="newTask.status")
        .form-actions
          button.btn-cancel(type="button" @click="showCreateTask = false") キャンセル
          button.btn-submit(type="submit") 作成

  //- 編集モーダル
  div.modal(v-if="showEditTask")
    div.modal-overlay(@click="showEditTask = false")
    div.modal-content
      h2.modal-title タスクを編集
      form.form-container(@submit.prevent="updateTask")
        .form-field
          label(for="edit-title") タイトル
          input#edit-title(type="text" v-model="editTask.title" required)
        .form-field
          label(for="edit-content") 詳細
          textarea#edit-content(v-model="editTask.content")
        .form-field
          label(for="edit-due_date") 締切日
          input#edit-due_date(type="date" v-model="editTask.due_date" required)
        .form-field
          label(for="edit-category") カテゴリ
          select#edit-category(v-model="editTask.category" required)
            option(value="" disabled) — 選択してください —
            option(v-for="cat in CATEGORIES" :key="cat" :value="cat") {{ cat }}
        .form-field
          label(for="edit-status") ステータス
          select#edit-status(v-model="editTask.status" required)
            option(value="" disabled) — 選択してください —
            option(v-for="st in STATUSES" :key="st" :value="st") {{ st }}
        .form-actions
          button.btn-cancel(type="button" @click="showEditTask = false") キャンセル
          button.btn-submit(type="submit") 更新
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

// 필터용 상수
const CATEGORIES = ['feature', 'bugfix', 'research']
const STATUSES   = ['pending', 'in_progress', 'completed']

const route       = useRoute()
const router      = useRouter()
const workspaceId = route.params.workspaceId

// 상태 관리
const tasks            = ref([])
const assignees        = ref([])
const workspaceName    = ref('')

const selectedAssignee = ref('')
const selectedCategory = ref('')
const selectedStatus   = ref('')

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

// 태스크 & 담당자 목록 불러오기
async function fetchTasks() {
  try {
    // 워크스페이스 이름 + 유저 목록
    const { data: ws } = await axios.get(`/api/v1/workspaces/${workspaceId}`, { withCredentials: true })
    workspaceName.value = ws.name

    // 파라미터 셋업
    const params = {}
    if (selectedAssignee.value) params.assignee_id = selectedAssignee.value
    if (selectedCategory.value) params.category     = selectedCategory.value
    if (selectedStatus.value)   params.status       = selectedStatus.value

    // 필터링된 태스크 호출
    const { data: list } = await axios.get(`/api/v1/workspaces/${workspaceId}/tasks`,
      { params, withCredentials: true })
    tasks.value = list

    // 담당자 리스트(중복 제거)
    const users = list.map(t => t.user)
    assignees.value = Array.from(new Map(users.map(u => [u.id, u])).values())
  } catch (err) {
    console.error('タスク取得失敗', err)
    alert('タスクの取得に失敗しました')
  }
}

// 생성
async function createTask() {
  try {
    const { data: created } = await axios.post(
      `/api/v1/workspaces/${workspaceId}/tasks`,
      { task: newTask.value },
      { withCredentials: true }
    )
    tasks.value.push(created)
    showCreateTask.value = false
    newTask.value = { title:'', content:'', due_date:'', category:'', status:'pending' }
  } catch (err) {
    console.error('タスク作成失敗', err)
    alert(err.response?.data?.errors?.join('、') || 'タスクの作成に失敗しました')
  }
}

// 삭제
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

// 편집 모달 오픈
function openEditModal(task) {
  editTask.value = { ...task }
  showEditTask.value = true
}

// 업데이트
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
    alert(err.response?.data?.errors?.join('、') || '更新に失敗しました')
  }
}

// 뒤로가기
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

/* 필터 섹션 */
.filters {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}
.filters select {
  padding: .5rem;
  border-radius: .25rem;
  border: 1px solid #ccc;
}

/* 버튼 영역 */
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
  color: #fff;
}

/* 태스크 리스트 */
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
.meta {
  font-size: .9rem;
  color: #555;
  margin: .5rem 0;
}
.buttons {
  position: absolute;
  top: 1rem;
  right: 1rem;
  display: flex;
}
.edit-btn,
.del-btn {
  margin-left: .5rem;
  padding: .25rem .5rem;
  border: none;
  border-radius: .25rem;
  cursor: pointer;
}
.edit-btn {
  background: #3477eb;
  color: #fff;
}
.del-btn {
  background: #e34c4c;
  color: #fff;
}

/* 모달 공통 */
.modal {
  position: fixed;
  top: 0; left: 0;
  width: 100%; height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}
.modal-overlay {
  position: absolute;
  width: 100%; height: 100%;
  background: rgba(0, 0, 0, 0.6);
}
.modal-content {
  position: relative;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
  padding: 2rem;
  max-width: 480px;
  width: 90%;
  z-index: 1001;
  animation: fadeIn 0.2s ease-out;

  .modal-title {
    margin: 0 0 1rem;
    font-size: 1.5rem;
    font-weight: 600;
    text-align: center;
    color: #333;
  }
}

/* 폼 스타일 */
.form-container {
  display: flex;
  flex-direction: column;

  .form-field {
    margin-bottom: 1rem;
    label {
      display: block;
      margin-bottom: .5rem;
      font-size: .95rem;
      color: #444;
    }
    input, textarea, select {
      width: 100%;
      padding: .6rem .8rem;
      border: 1px solid #ccc;
      border-radius: 6px;
      font-size: .95rem;
      transition: border-color .2s;
      &:focus {
        outline: none;
        border-color: #42b983;
      }
    }
    textarea {
      resize: vertical;
      min-height: 80px;
    }
  }

  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: .5rem;

    .btn-cancel,
    .btn-submit {
      padding: .6rem 1.2rem;
      border: none;
      border-radius: 6px;
      font-size: .95rem;
      cursor: pointer;
      transition: background .2s;
    }
    .btn-cancel {
      background: #f0f0f0;
      color: #555;
      &:hover { background: #e0e0e0; }
    }
    .btn-submit {
      background: #42b983;
      color: #fff;
      &:hover { background: #369f6e; }
    }
  }
}

/* 애니메이션 */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-10px); }
  to   { opacity: 1; transform: translateY(0); }
}
</style>
