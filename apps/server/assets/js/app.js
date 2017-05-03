const $username = document.getElementById('username')
const $feedUrl = document.getElementById('feed-url')

function getWidth () {
  return window.innerWidth ||
    document.documentElement.clientWidth ||
    document.body.clientWidth
}

function setPlaceholder () {
  $username.placeholder = getWidth() < 400
    ? 'Username'
    : 'Enter your username'
}

function showFeedUrl ({ target: { value } }) {
  $feedUrl.classList[value ? 'add' : 'remove']('show')
  $feedUrl.innerHTML = `https://sndcld-rss.com/${value}/likes/feed.rss`
}

// main

setPlaceholder()
window.addEventListener('resize', setPlaceholder)
// $username.addEventListener('click', () => {$username.placeholder = ''})
$username.addEventListener('input', showFeedUrl)
$typeSel.addEventListener('click', showFeedUrl)

