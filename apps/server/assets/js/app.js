function getWidth () {
  return window.innerWidth ||
    document.documentElement.clientWidth ||
    document.body.clientWidth
}

function setPlaceholder () {
  const placeholder = getWidth() < 400 ? 'Username' : 'Enter your username'
  document.querySelector('.input-username').placeholder = placeholder
}

setPlaceholder()
window.addEventListener('resize', setPlaceholder)
