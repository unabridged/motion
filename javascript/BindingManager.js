import parseBindings, { MODE_HANDLE } from './parseBindings'

export default class BindingManager {
  constructor (client, element) {
    this.client = client
    this.element = element

    this._handlers = new Map()

    this.update()
  }

  update () {
    const bindings = this.parseBindings()

    for (const [id, [event, callback]] of this._handlers.entries()) {
      if (!bindings.has(id)) {
        this.element.removeEventListener(event, callback)
        this._handlers.delete(id)
      }
    }

    for (const [id, binding] of bindings.entries()) {
      if (!this._handlers.has(id)) {
        const { event } = binding
        const handler = this._buildHandlerForBinding(binding)

        this.element.addEventListener(event, handler)
        this._handlers.set(id, [event, handler])
      }
    }
  }

  shutdown () {
    for (const [eventName, callback] of this._handlers.values()) {
      this.element.removeEventListener(eventName, callback)
    }

    this._handlers.clear()
  }

  parseBindings () {
    const { motionAttribute } = this.client
    const bindingsString = this.element.getAttribute(motionAttribute)
    const bindings = new Map()

    for (const binding of parseBindings(bindingsString, this.element)) {
      bindings.set(binding.id, binding)
    }

    return bindings
  }

  _buildHandlerForBinding ({ mode, motion }) {
    return (event) => {
      const component = this.client.findComponent(event.target)

      if (component) {
        component.processMotion(motion, event)

        if (mode === MODE_HANDLE) {
          event.preventDefault()
        }
      }
    }
  }
}
