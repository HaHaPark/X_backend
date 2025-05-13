<!-- src/components/Signup.vue -->
<template lang="pug">
div.signup
  h1 会員登録
  form(@submit.prevent="onSubmit")
    .field
      label(for="email") メールアドレス
      input#email(type="email" v-model="form.email" required)
    .field
      label(for="name") 名前
      input#name(type="text" v-model="form.name" required)
    .field
      label(for="password") パスワード
      input#password(type="password" v-model="form.password" required)
    .field
      label(for="password_confirmation") パスワード（確認）
      input#password_confirmation(type="password" v-model="form.password_confirmation" required)
    button(type="submit") 登録する
    p.error(v-if="error") {{ error }}
    p
      | すでにアカウントをお持ちですか？
      router-link(to="/login") こちらからログイン
</template>

<script setup>
import { reactive, ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const form = reactive({
  email: '',
  name: '',
  password: '',
  password_confirmation: ''
})
const error = ref('')

async function onSubmit() {
  error.value = ''
  try {
    await axios.post(
      '/api/v1/users',
      { user: form },
      { withCredentials: true }
    )
    alert('会員登録が完了しました。')
    router.push('/login')
  } catch (e) {
    error.value = e.response?.data?.errors?.join('、') || '不明なエラー'
  }
}
</script>

<style scoped>
.signup { max-width: 400px; margin: 2rem auto; }
.field { margin-bottom: 1rem; }
label { display: block; margin-bottom: .25rem; }
input { width: 100%; padding: .5rem; }
button { padding: .75rem 1.5rem; }
.error { color: red; margin-top: .5rem; }
</style>
