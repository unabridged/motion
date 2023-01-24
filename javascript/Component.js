import dispatchEvent from './dispatchEvent'
import serializeEvent from './serializeEvent'
import reconcile from './reconcile'

import { version } from '../package.json'

export default class Component {
  constructor (client, element) {
    this._isShutdown = false

    this.client = client
    this.element = element

    this._beforeConnect()

    const subscription = this.client.consumer.subscriptions.create(
      {
        channel: 'Motion::Channel',
        version,
        state: this.element.getAttribute(this.client.stateAttribute)
      },
      {
        connected: () => {
          if (this._isShutdown) {
            subscription.unsubscribe()
            return
          }

          this._subscription = subscription
          this._connect()
        },
        rejected: () => this._connectFailed(),
        disconnected: () => this._disconnect(),
        received: newState => this._render(newState)
      }
    )
    this._initialSubscription = subscription
  }

  processMotion (name, event = null, element = event && event.currentTarget) {
    if (!this._subscription) {
      this.client.log('Dropped motion', name, 'on', this)
      return false
    }

    this.client.log('Processing motion', name, 'on', this)

    const extraDataForEvent = event && this.client.getExtraDataForEvent(event)

    this._subscription.perform(
      'process_motion',
      {
        name,
        event: event && serializeEvent(event, extraDataForEvent, element)
      }
    )

    return true
  }

  shutdown () {
    this._isShutdown = true

    if (this._subscription) {
      this._subscription.unsubscribe()
      delete this._subscription
    }

    this._disconnect()
  }

  _beforeConnect () {
    this.client.log('Connecting component', this)

    dispatchEvent(this.element, 'motion:before-connect')
  }

  _connect () {
    this.client.log('Component connected', this)

    dispatchEvent(this.element, 'motion:connect')
  }

  _connectFailed () {
    this.client.log('Failed to connect component', this)

    dispatchEvent(this.element, 'motion:connect-failed')
  }

  _disconnect () {
    this.client.log('Component disconnected', this)

    dispatchEvent(this.element, 'motion:disconnect')
  }

  _render (newState) {
    dispatchEvent(this.element, 'motion:before-render')

    reconcile(this.element, newState, this.client.keyAttribute)

    this.client.log('Component rendered', this)

    dispatchEvent(this.element, 'motion:render')
  }
}
