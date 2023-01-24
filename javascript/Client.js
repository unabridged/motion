import AttributeTracker from './AttributeTracker'
import BindingManager from './BindingManager'
import Component from './Component'
import { documentLoaded, beforeDocumentUnload } from './documentLifecycle'
import getFallbackConsumer from './getFallbackConsumer'

export default class Client {
  constructor (options = {}) {
    Object.assign(this, Client.defaultOptions, options)

    this.consumer = this.consumer || getFallbackConsumer()

    this._componentSelector = `[${this.keyAttribute}][${this.stateAttribute}]`

    this._componentTracker =
      new AttributeTracker(this.keyAttribute, (element) => (
        element.hasAttribute(this.stateAttribute) // ensure matches selector
          ? new Component(this, element)
          : null
      ))

    this._motionTracker =
      new AttributeTracker(this.motionAttribute, (element) => (
        new BindingManager(this, element)
      ))

    documentLoaded.then(() => { // avoid mutations while loading the document
      this._componentTracker.attachRoot(this.root)
      this._motionTracker.attachRoot(this.root)
    })

    if (this.shutdownBeforeUnload) {
      beforeDocumentUnload.then(() => this.shutdown())
    }
  }

  log (...args) {
    if (this.logging) {
      console.log('[Motion]', ...args)
    }
  }

  getComponent (element) {
    return this._componentTracker.getManager(
      element.closest(this._componentSelector)
    )
  }

  shutdown () {
    this._componentTracker.shutdown()
    this._motionTracker.shutdown()
  }
}

Client.defaultOptions = {
  getExtraDataForEvent (_event) {
    // noop
  },

  logging: false,

  root: document,
  shutdownBeforeUnload: true,

  keyAttribute: 'data-motion-key',
  stateAttribute: 'data-motion-state',
  motionAttribute: 'data-motion'
}
