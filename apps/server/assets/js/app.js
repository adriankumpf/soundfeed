/* global self, fetch */

const $profileUrl = document.querySelector('.profile-url')
const $spinner = document.querySelector('.submit-spinner')
const $select = document.querySelector('.type-select')
const $submit = document.querySelector('.submit')
const $arrow = document.querySelector('.arrow')
const $url = document.querySelector('.submit-url')
const $btn = document.querySelector('.submit-btn')
const $form = document.querySelector('.form')

// Utility

function toggleClass (el, cl, s) {
  el.classList[s ? 'add' : 'remove'](cl)
}

function keyCode (e) {
  return (e.keyCode || e.which || e.charCode || 0)
}

function getWidth () {
  return window.innerWidth ||
    document.documentElement.clientWidth ||
    document.body.clientWidth
}

// Center select element

const ctx = setupCanvasCtx()

function setupCanvasCtx () {
  const canvas = document.createElement('canvas')
  const ctx = canvas.getContext('2d')
  ctx.font = 'normal 18px sans-sarif'

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

function setPlaceholder () {
  $profileUrl.placeholder = getWidth() < 400
    ? 'Your profile URL'
    : 'Enter your profile URL'
}

// Show feed url

function extractUserId (profileUrl) {
  const uId = profileUrl.split('soundcloud.com/')[1]
  const isValid = (
    uId && !uId.includes('#') && !uId.includes('?') && !uId.includes('/')
  )

  return isValid ? uId : false
}

function lookupUserId (done) {
  const userId = extractUserId($profileUrl.value)
  if (!userId) return shakeForm()

  showSpinner()

  fetch(`/lookup/${userId}`)
    .then(res => res.json())
    .then(({ user_id }) => done(user_id))
    .catch(() => {
      shakeForm()
      showSpinner(false)
    })
}

function shakeForm () {
  $profileUrl.focus()
  toggleClass($form, 'shake', true)
  setTimeout(toggleClass.bind(null, $form, 'shake', false), 250)
}

function onBtnPress ({ target: { className } }) {
  if (['arrow', 'submit-btn'].indexOf(className) < 0) return
  if (className === 'arrow') return extendBtn(false)

  lookupUserId(showFeedUrl)
}

function onEnter (e) {
  if (keyCode(e) !== 13) return

  e.preventDefault()

  if (!$submit.classList.contains('full')) {
    onBtnPress({ target: { className: 'submit-btn' } })
  }
}

function onEsc (e) {
  if (keyCode(e) === 27) extendBtn(false)
}

function showSpinner (state = true) {
  toggleClass($spinner, 'hide', !state)
  toggleClass($btn, 'hide', state)
}

function extendBtn (state) {
  toggleClass($url, 'hide', !state)
  toggleClass($btn, 'hide', state)
  toggleClass($arrow, 'hide', !state)
  toggleClass($submit, 'full', state)
  toggleClass($spinner, 'hide', true)
}

function showFeedUrl (userId) {
  const type = $select.value.toLowerCase()
  const url = `http://0.0.0.0:4000/feeds/${userId}/${type}.rss`
  $url.setAttribute('href', url)
  $url.innerHTML = url
  extendBtn(true)
}

// main

const init = () => {
  centerSelect($select)
  setPlaceholder()
}

init()

if (!self.fetch) throw Error('Use a modern browser')

$profileUrl.addEventListener('keypress', onEnter)
window.addEventListener('keypress', onEsc)
$select.addEventListener('change', centerSelect)
$submit.addEventListener('click', onBtnPress)
window.addEventListener('resize', init)
