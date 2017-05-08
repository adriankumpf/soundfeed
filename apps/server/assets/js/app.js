const $username = document.getElementById('username')
const $select = document.getElementById('select')
const $submit = document.getElementById('submit')

// Centering select element

const ctx = setupCanvasCtx()

function setupCanvasCtx () {
  const canvas = document.createElement('canvas')
  const ctx = canvas.getContext('2d')
  ctx.font = 'normal 18px Lato'

  return ctx
}

function getTextWidth (text) {
  return ctx.measureText(text).width
}

function centerSelect (select) {
  const optionsText = select[select.selectedIndex].text
  const emptySpace = select.offsetWidth - getTextWidth(optionsText)

  select.style['text-indent'] = `${emptySpace / 2}px`
}

// Setting placeholder text

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

// Showing feed url

let state = true
function showFeedUrl () {
  const $btn = document.querySelector('.submit-btn')
  const $url = document.querySelector('.submit-url')

  $url.innerHTML = `https://sndcld-rss.com/${$username.value}/likes/feed.rss`
  $url.classList[!state ? 'add' : 'remove']('hide')
  $btn.classList[state ? 'add' : 'remove']('hide')

  $submit.classList[state ? 'add' : 'remove']('full')

  state = !state
}

// main

const init = () => {
  centerSelect($select)
  setPlaceholder()
}

init()

$select.addEventListener('change', centerSelect.bind(null, $select))
$submit.addEventListener('click', showFeedUrl)
window.addEventListener('resize', init)
