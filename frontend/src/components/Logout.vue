<template lang="pug">
div.logout
  h1 ログアウト完了
  p ログアウトしました。
  p
    router-link(to="/login") 再度ログイン
</template>

<script setup>
import { onMounted } from 'vue'
import axios from 'axios'

onMounted(async () => {
  await axios.delete('/api/v1/logout', { withCredentials: true })
})
</script>

<style scoped>
.logout { max-width: 400px; margin: 2rem auto; text-align: center; }
.logout p { margin: 1rem 0; }
</style>
