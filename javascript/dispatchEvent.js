export default function dispatchEvent (target, name) {
  try {
    const event = new CustomEvent(name, {
      bubbles: true,
      cancelable: false
    })

    target.dispatchEvent(event)
  } catch (error) {
    console.error('Error while dispatching', name, 'on', target, error)
  }
}
