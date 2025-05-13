<!-- src/App.vue -->
<template lang="pug">
div#app
  //logo
  .logo-container
    a(href="https://vite.dev" target="_blank")
      img.logo(src="/vite.svg" alt="Vite logo")
    a(href="https://vuejs.org/" target="_blank")
      img.logo.vue(src="./assets/vue.svg" alt="Vue logo")

  //- navi
  nav
    router-link(to="/signup") 会員登録
    span &nbsp;|&nbsp;
    router-link(to="/login") ログイン
    span &nbsp;|&nbsp;
    router-link(to="/logout") ログアウト

  hr

  //- routecomponent
  router-view
</template>

<script setup>
</script>

<style scoped>
.logo-container {
  display: flex;
  justify-content: center;
  margin-top: 1rem;
}
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}
.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}
.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}

nav {
  text-align: center;
  margin: 1rem 0;
}
nav a {
  margin: 0 0.5rem;
  text-decoration: none;
  color: #42b983;
}
nav a.router-link-active {
  font-weight: bold;
}
hr {
  margin: 0 2rem;
}
</style>
