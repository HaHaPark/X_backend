<template lang="pug">
div.login
  h1 ログイン
  form(@submit.prevent="onSubmit")
    .field
      label(for="email") メールアドレス
      input#email(type="email" v-model="form.email" required)
    .field
      label(for="password") パスワード
      input#password(type="password" v-model="form.password" required)
    button(type="submit") ログイン
    p.error(v-if="error") {{ error }}
    p
      | アカウントをお持ちでない方は
      router-link(to="/signup") こちらから会員登録
</template>

<script setup>
import { reactive, ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const form = reactive({ email: '', password: '' })
const error = ref('')

async function onSubmit() {
  error.value = ''
  try {
    await axios.post('/api/v1/login', form, { withCredentials: true })
    router.push('/logout')
  } catch (e) {
    error.value = e.response?.data?.errors?.join('、') || 'ログインに失敗しました'
  }
}
</script>

<style scoped>
.login { max-width: 400px; margin: 2rem auto; }
.field { margin-bottom: 1rem; }
input { width: 100%; padding: .5rem; }
button { padding: .75rem 1.5rem; }
.error { color: red; margin-top: .5rem; }
</style>
