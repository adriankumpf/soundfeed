/* global self, fetch */

const $username = document.getElementById('username')
const $spinner = document.querySelector('.submit-spinner')
const $select = document.getElementById('select')
const $submit = document.getElementById('submit')
const $arrow = document.querySelector('.arrow')
const $url = document.querySelector('.submit-url')
const $btn = document.querySelector('.submit-btn')

// Center select element

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

// Set placeholder text

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

function toggleClass (el, cl, s) {
  el.classList[s ? 'add' : 'remove'](cl)
}

function lookupUserId (done) {
  fetch(`/lookup/${$username.value}`)
    .then(res => res.json())
    .then(({ user_id }) => done(user_id))
    .catch(console.err)
}

function onBtnPress ({ target: { className } }) {
  if (['arrow', 'submit-btn'].indexOf(className) < 0) return
  if (className === 'arrow') return extendBtn(false)

  showSpinner()
  lookupUserId(showFeedUrl)
}

function showSpinner () {
  toggleClass($spinner, 'hide', false)
  toggleClass($btn, 'hide', true)
}

function extendBtn (state) {
  toggleClass($url, 'hide', !state)
  toggleClass($btn, 'hide', state)
  toggleClass($arrow, 'hide', !state)
  toggleClass($submit, 'full', state)
  toggleClass($spinner, 'hide', state)
}

function showFeedUrl (userId) {
  const type = $select.value.toLowerCase()
  const url = `http://0.0.0.0:4000/feeds/${userId}/${type}.rss`
  $url.setAttribute('href', url)
  $url.innerHTML = url
  extendBtn(true)
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

if (!self.fetch) throw Error('Use a modern browser')

$username.addEventListener('input', enableButton)
$select.addEventListener('change', centerSelect)
$submit.addEventListener('click', onBtnPress)
window.addEventListener('resize', init)
