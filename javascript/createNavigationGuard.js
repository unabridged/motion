export default function registerBeforeNavigate (callback) {
  const capature = () => {
    listenOnce(window, 'beforeunload', ({ defaultPrevented }) => {
      if (!defaultPrevented) {
        callback()
      }
    })
  }

  window.addEventListener('beforeunload', capature, true)

  return {
    stop () {
      window.removeEventListener('beforeunload', capature, true)
    }
  }
}

function listenOnce (target, eventName, callback) {
  target.addEventListener(eventName, function handler () {
    target.removeEventListener(eventName, handler)

    return callback.apply(this, arguments)
  })
}
