import AttributeTracker from './AttributeTracker'
import BindingManager from './BindingManager'
import Component from './Component'
import { documentLoaded, beforeDocumentUnload } from './documentLifecycle'
import getFallbackConsumer from './getFallbackConsumer'

export default class Client {
  constructor (options = {}) {
    Object.assign(this, Client.defaultOptions, options)

    this._componentSelector = `[${this.stateAttribute}]`

    this._componentTracker =
      new AttributeTracker(this.stateAttribute, (element) => (
        new Component(this, element)
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

  findComponent (element) {
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
  get consumer () {
    return getFallbackConsumer()
  },

  get root () {
    return document
  },

  getExtraDataForEvent (_event) {
    // noop
  },

  shutdownBeforeUnload: true,
  logging: false,

  keyAttribute: 'data-motion-key',
  stateAttribute: 'data-motion-state',
  motionAttribute: 'data-motion'
}
