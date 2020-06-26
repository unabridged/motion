const identifier = '[^\\s\\(\\)]+'
const binding = `((${identifier})(\\((${identifier})\\))?->)?(${identifier})`
const regExp = new RegExp(binding, 'g')

const captureIndicies = {
  event: 2,
  mode: 4,
  motion: 5
}

export default function parseBindings (input) {
  if (!input) {
    return []
  }

  return Array.from(input.matchAll(regExp), match => ({
    event: match[captureIndicies.event] || null,
    mode: match[captureIndicies.mode] || null,
    motion: match[captureIndicies.motion] || null
  }))
}
