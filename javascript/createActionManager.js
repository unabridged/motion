export default function createActionManager (controller, config) {
  const actionManager = new ActionManager(controller, config)
  actionManager.start()

  return actionManager
}

export class ActionManager {
  constructor (controller, { attribute, target }) {
    this.controller = controller
    this.attribute = attribute
    this.target = target

    this._mutationObserver = new MutationObserver(() => this._setupActions())
  }

  start () {
    this._setupActions()

    this._mutationObserver.observe(
      this.controller.element,
      {
        attributes: true,
        childList: true,
        subtree: true
      }
    )
  }

  stop () {
    this._mutationObserver.disconnect()
  }

  _setupActions () {
    for (const element of this._findAllElementsWithAction()) {
      for (const { event, action } of this._getActionsForElement(element)) {
        this._setupAction(element, action, event)
      }
    }
  }

  _setupAction (element, action, event = null) {
    const { dataset } = element
    const actionProxy = this._getActionProxy(action)
    const actionString =
      buildActionString(this.controller.identifier, actionProxy, event)

    if (dataset.action && dataset.action.includes(actionString)) {
      return
    }

    if (dataset.action) {
      dataset.action += ` ${actionString}`
    } else {
      dataset.action = actionString
    }
  }

  _findAllElementsWithAction () {
    const { element } = this.controller

    const selector = `[${this.attribute}]`
    const candidates = Array.from(element.querySelectorAll(selector))

    if (element.matches(selector)) {
      candidates.push(element)
    }

    return candidates.filter(candidate => this._isReceiverForAction(candidate))
  }

  _isReceiverForAction (element) {
    const receiverSelector =
      `[data-controller~="${this.controller.identifier}"]`

    return this.controller.element === element.closest(receiverSelector)
  }

  _getActionsForElement (element) {
    return parseActionsString(element.getAttribute(this.attribute))
  }

  _getActionProxy (action) {
    const handler = `__${this.target}$${action}`

    if (!(handler in this.controller)) {
      this.controller[handler] = this._buildActionProxyHandler(action)
    }

    return handler
  }

  _buildActionProxyHandler (action) {
    return event => this.controller[this.target](action, event)
  }
}

function parseActionsString (actionsString) {
  if (!actionsString) {
    return []
  }

  return actionsString.split(' ').map(actionString => {
    const [eventOrAction, action] = actionString.split('->', 2)

    if (action) {
      return {
        event: eventOrAction,
        action
      }
    } else {
      return {
        event: null,
        action: eventOrAction
      }
    }
  })
}

function buildActionString (controller, action, event = null) {
  return `${event ? `${event}->` : ''}${controller}#${action}`
}
