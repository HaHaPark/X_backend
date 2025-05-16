<template lang="pug">
div.progress-view
  h1 {{ workspaceName }} の進捗レポート

  table
    thead
      tr
        th 担当者
        th 全タスク数
        th 完了タスク数
        th 進捗率
    tbody
      tr(v-for="row in report" :key="row.user.id")
        td {{ row.user.name }}
        td {{ row.total_tasks }}
        td {{ row.completed_tasks }}
        td {{ row.progress_rate }}%

  button.back(@click="goBack") 戻る
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

const route       = useRoute()
const router      = useRouter()
const workspaceId = route.params.workspaceId

const report        = ref([])
const workspaceName = ref('')

async function fetchProgress() {
  try {
    // 워크스페이스 정보로 이름 가져오기
    const { data: ws } = await axios.get(
      `/api/v1/workspaces/${workspaceId}`,
      { withCredentials: true }
    )
    workspaceName.value = ws.name

    // 진행률 API 호출
    const { data } = await axios.get(
      `/api/v1/workspaces/${workspaceId}/progress`,
      { withCredentials: true }
    )
    report.value = data
  } catch (err) {
    console.error('進捗レポート取得失敗', err)
    alert('進捗レポートの取得に失敗しました')
  }
}

function goBack() {
  router.back()
}

onMounted(fetchProgress)
</script>

<style scoped lang="scss">
.progress-view {
  max-width: 800px;
  margin: 2rem auto;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
th, td {
  padding: .75rem;
  border: 1px solid #ddd;
  text-align: center;
}
.back {
  padding: .5rem 1rem;
  background: #42b983;
  color: white;
  border: none;
  border-radius: .25rem;
  cursor: pointer;
}
</style>
