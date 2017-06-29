/* global self, fetch */

const $profileUrl = document.querySelector('.profile-url')
const $select = document.querySelector('.type-select')
const $submit = document.querySelector('.submit')
const $url = document.querySelector('.submit-url')
const $form = document.querySelector('.form')

// Utility

function toggleClass (el, cl, s) {
  el.classList[s ? 'add' : 'remove'](cl)
}

function keyCode (e) {
  return (e.keyCode || e.which || e.charCode || 0)
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
  if (typeof InstallTrigger !== 'undefined') return // skip FireFox
  const optionsText = $select[$select.selectedIndex].text
  const emptySpace = $select.offsetWidth - getTextWidth(optionsText)

  $select.style['padding-left'] = `${emptySpace / 2}px`
}

// Show feed url

function extractUserId (profileUrl) {
  const uId = profileUrl
    .trim()
    .toLowerCase()
    .split('soundcloud.com/')[1]

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
    .then(() => showSpinner(false))
    .catch(() => {
      showSpinner(false)
      shakeForm()
    })
}

function shakeForm () {
  $profileUrl.focus()
  toggleClass($form, 'shake', true)
  setTimeout(toggleClass.bind(null, $form, 'shake', false), 250)
}

function showSpinner (state = true) {
  toggleClass($submit, 'loading', state)
}

function extendBtn (state = true) {
  toggleClass($submit, 'full', state)
}

function showFeedUrl (userId) {
  const type = $select.value.toLowerCase()
  const url = `${window.location}feeds/${userId}/${type}.rss`
  $url.setAttribute('href', url)
  $url.innerHTML = url
  extendBtn()
}

// main

const onBtnPress = ({ target: { className } }) => {
  if (['close', 'submit-btn'].indexOf(className) < 0) return
  if (className === 'close') return extendBtn(false)

  lookupUserId(showFeedUrl)
}

const onEnter = (e) => {
  if (keyCode(e) !== 13) return

  e.preventDefault()

  if (!$submit.classList.contains('full')) {
    onBtnPress({ target: { className: 'submit-btn' } })
  }
}

const onEsc = (e) => {
  if (keyCode(e) === 27) extendBtn(false)
}

centerSelect()

$profileUrl.addEventListener('keypress', onEnter)
$select.addEventListener('change', centerSelect)
window.addEventListener('resize', centerSelect)
$submit.addEventListener('click', onBtnPress)
window.addEventListener('keydown', onEsc)

if (!self.fetch) window.alert('Please upgrade your browser!')
