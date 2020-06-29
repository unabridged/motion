import dispatchEvent from './dispatchEvent'
import serializeEvent from './serializeEvent'
import reconcile from './reconcile'

import { version } from '../package.json'

export default class Component {
  constructor (client, element) {
    this.client = client
    this.element = element

    this._beforeConnect()

    this._subscription = this.client.consumer.subscriptions.create(
      {
        channel: 'Motion::Channel',
        version,
        state: this.element.getAttribute(this.client.stateAttribute)
      },
      {
        connected: () => this._connect(),
        rejected: () => this._connectFailed(),
        disconnected: () => this._disconnect(),
        received: newState => this._render(newState)
      }
    )
  }

  processMotion (name, event = null) {
    if (this.client.logging) {
      console.log('Processing motion', name, 'on', this.element)
    }

    if (!this._subscription) {
      if (this.client.logging) {
        console.log('Dropped motion', name, 'on', this.element)
      }

      return
    }

    const extraDataForEvent = event && this.client.getExtraDataForEvent(event)

    this._subscription.perform(
      'process_motion',
      {
        name,
        event: event && serializeEvent(event, extraDataForEvent)
      }
    )
  }

  shutdown () {
    this._subscription.unsubscribe()
    delete this._subscription

    this._disconnect()
  }

  _beforeConnect () {
    if (this.client.logging) {
      console.log('Connecting component', this.element)
    }

    dispatchEvent(this.element, 'motion:before-connect')
  }

  _connect () {
    if (this.client.logging) {
      console.log('Component connected', this.element)
    }

    dispatchEvent(this.element, 'motion:connect')
  }

  _connectFailed () {
    if (this.client.logging) {
      console.log('Failed to connect component', this.element)
    }

    dispatchEvent(this.element, 'motion:connect-failed')
  }

  _disconnect () {
    if (this.client.logging) {
      console.log('Component disconnected', this.element)
    }

    dispatchEvent(this.element, 'motion:disconnect')
  }

  _render (newState) {
    dispatchEvent(this.element, 'motion:before-render')

    reconcile(this.element, newState, this.client.keyAttribute)

    if (this.client.logging) {
      console.log('Component rendered', this.element)
    }

    dispatchEvent(this.element, 'motion:render')
  }
}
