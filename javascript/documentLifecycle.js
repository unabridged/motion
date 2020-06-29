export const documentLoaded = new Promise((resolve) => {
  if (/^loaded|^i|^c/i.test(document.readyState)) {
    resolve()
  } else {
    once(document, 'DOMContentLoaded', resolve)
  }
})

export const beforeDocumentUnload = new Promise((resolve) => {
  window.addEventListener('beforeunload', () => {
    once(window, 'beforeunload', ({ defaultPrevented }) => {
      if (!defaultPrevented) {
        resolve()
      }
    })
  }, true)
})

function once (target, event, callback) {
  target.addEventListener(event, function handler (event) {
    target.removeEventListener(event, handler)

    callback(event)
  })
}
