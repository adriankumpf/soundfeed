const $username = document.getElementById('username')
const $btn = document.querySelector('.submit-btn')
const $url = document.querySelector('.submit-url')
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

function centerSelect () {
  const optionsText = $select[$select.selectedIndex].text
  const emptySpace = $select.offsetWidth - getTextWidth(optionsText)

  $select.style['text-indent'] = `${emptySpace / 2}px`
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

function showFeedUrl ({ target: { className } }) {
  if (['arrow', 'submit-btn'].indexOf(className) < 0) return

  const state = className !== 'arrow'

  const type = $select.value.toLowerCase()
  const user = $username.value

  $url.value = `https://sndcld-rss.com/feeds/${user}/${type}.rss`
  $url.classList[!state ? 'add' : 'remove']('hide')
  $btn.classList[state ? 'add' : 'remove']('hide')

  $submit.classList[state ? 'add' : 'remove']('full')

  document.querySelector('.arrow').classList[!state ? 'add' : 'remove']('hide')

  // $url.focus()
  $url.select()
}

function enableButton () {
  $submit.disabled = false
}

// main

const init = () => {
  centerSelect($select)
  setPlaceholder()
}

init()

$username.addEventListener('input', enableButton)
$select.addEventListener('change', centerSelect)
$submit.addEventListener('click', showFeedUrl)
window.addEventListener('resize', init)
