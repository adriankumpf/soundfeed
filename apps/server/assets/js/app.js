const $username = document.getElementById('username')
const $feedUrl = document.getElementById('feed-url')
const $select = document.getElementById('select')

const ctx = setupCanvasCtx()

function setupCanvasCtx () {
  const canvas = document.createElement('canvas')
  const ctx = canvas.getContext('2d')
  ctx.font = 'normal 18px Lato'

  return ctx
}

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

function getTextWidth (text) {
  return ctx.measureText(text).width
}

function centerSelect (select) {
  const optionsText = select[select.selectedIndex].text
  const emptySpace = select.offsetWidth - getTextWidth(optionsText)

  select.style['text-indent'] = `${emptySpace / 2}px`
}

// main

const init = () => {
  centerSelect($select)
  setPlaceholder()
}

init()

$select.addEventListener('change', ({ target }) => centerSelect(target))
$username.addEventListener('input', showFeedUrl)
window.addEventListener('resize', init)
