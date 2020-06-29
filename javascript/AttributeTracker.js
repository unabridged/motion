export default class AttributeTracker {
  constructor (attribute, createManager) {
    this.attribute = attribute
    this.createManager = createManager

    this._managers = new Map()
    this._attributeSelector = `[${attribute}]`

    this._mutationObserver = new MutationObserver(mutations => {
      for (const mutation of mutations) {
        this._processMutation(mutation)
      }
    })
  }

  attachRoot (element) {
    this._forEachMatchingUnder(element, (match) => this._detect(match))

    this._mutationObserver.observe(element, {
      attributes: true,
      attributeFilter: [
        this.attribute
      ],
      childList: true,
      subtree: true
    })
  }

  shutdown () {
    this._mutationObserver.disconnect()

    for (const manager of this._managers.values()) {
      if (manager) {
        try {
          manager.shutdown()
        } catch (error) {
          console.error('An error occurred within Motion', error)
        }
      }
    }

    this._managers.clear()
  }

  getManager (element) {
    return this._managers.get(element)
  }

  _detect (element) {
    let manager = null

    try {
      if (this._managers.has(element)) {
        throw new Error('Double detect in AttributeTracker')
      }

      manager = this.createManager(element)
    } catch (error) {
      console.error('An error occurred within Motion', error)
    }

    this._managers.set(element, manager)
  }

  _update (element) {
    const manager = this._managers.get(element)

    if (manager && manager.update) {
      try {
        manager.update()
      } catch (error) {
        console.error('An error occurred within Motion', error)
      }
    }
  }

  _remove (element) {
    const manager = this._managers.get(element)

    if (manager && manager.shutdown) {
      try {
        manager.shutdown()
      } catch (error) {
        console.error('An error occurred within Motion', error)
      }
    }

    this._managers.delete(element)
  }

  _processMutation (mutation) {
    if (mutation.type === 'childList') {
      this._processChildListMutation(mutation)
    } else if (mutation.type === 'attributes') {
      this._processAttributesMutation(mutation)
    } else {
      // noop
    }
  }

  _processChildListMutation ({ removedNodes, addedNodes }) {
    this._forEachMatchingIn(removedNodes, (match) => this._remove(match))
    this._forEachMatchingIn(addedNodes, (match) => this._detect(match))
  }

  _processAttributesMutation ({ target }) {
    const didHaveAttribute = this._managers.has(target)
    const hasAttribute = target.hasAttribute(this.attribute)

    if (didHaveAttribute) {
      if (hasAttribute) {
        this._update(target)
      } else {
        this._remove(target)
      }
    } else {
      if (hasAttribute) {
        this._detect(target)
      } else {
        // noop
      }
    }
  }

  _forEachMatchingIn (nodes, callback) {
    for (const node of nodes) {
      this._forEachMatchingUnder(node, callback)
    }
  }

  _forEachMatchingUnder (node, callback) {
    if (node.hasAttribute && node.hasAttribute(this.attribute)) {
      callback(node)
    }

    if (node.querySelectorAll) {
      for (const match of node.querySelectorAll(this._attributeSelector)) {
        callback(match)
      }
    }
  }
}
