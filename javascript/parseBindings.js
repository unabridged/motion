const identifier = '[^\\s\\(\\)]+'
const binding = `((${identifier})(\\((${identifier})\\))?->)?(${identifier})`
const regExp = new RegExp(binding, 'g')

const captureIndicies = {
  id: 0,
  event: 2,
  mode: 4,
  motion: 5
}

export const MODE_LISTEN = 'listen'
export const MODE_HANDLE = 'handle'

const DEFAULT_EVENT = {
  _other: 'click',

  FORM: 'submit',
  INPUT: 'change',
  SELECT: 'change',
  TEXTAREA: 'change'
}

const DEFAULT_MODE = {
  _other: MODE_HANDLE,
  change: MODE_LISTEN
}

export default function parseBindings (input, tagName = '_other') {
  if (!input) {
    return []
  }

  return Array.from(input.matchAll(regExp), match => {
    const id = match[captureIndicies.id]
    const motion = match[captureIndicies.motion]

    const event =
      match[captureIndicies.event] ||
      DEFAULT_EVENT[tagName] ||
      DEFAULT_EVENT._other

    const mode =
      match[captureIndicies.mode] ||
      DEFAULT_MODE[event] ||
      DEFAULT_MODE._other

    return {
      id,
      motion,
      event,
      mode
    }
  })
}
