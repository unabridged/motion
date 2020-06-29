import AttributeTracker from '../../javascript/AttributeTracker.js'

describe('AttributeTracker', () => {
  let originalBody

  beforeEach(() => {
    originalBody = document.body
    document.body = document.createElement('body')
  })

  afterEach(() => {
    document.body = originalBody
  })

  const attribute = 'data-test-attribute'

  it('creates a manager for elements with the attribute', () => {
    let testManager = null

    const tracker = new AttributeTracker(attribute, (element) => {
      return (testManager = new TestManager(element))
    })

    const element = document.createElement('div')
    element.setAttribute(attribute, 'value')
    document.body.appendChild(element)

    tracker.attachRoot(document)

    expect(testManager.element).to.eq(element)

    tracker.shutdown()
  })

  it('creates a manager for elements that are added with the attr', (done) => {
    let testManager = null

    const tracker = new AttributeTracker(attribute, (element) => {
      return (testManager = new TestManager(element))
    })

    tracker.attachRoot(document)

    const element = document.createElement('div')
    element.setAttribute(attribute, 'value')
    document.body.appendChild(element)

    setTimeout(() => {
      expect(testManager.element).to.eq(element)
      tracker.shutdown()

      done()
    }, 0)
  })

  it('creates a manager for elements that have the attribute added', (done) => {
    let testManager = null

    const tracker = new AttributeTracker(attribute, (element) => {
      return (testManager = new TestManager(element))
    })

    const element = document.createElement('div')
    document.body.appendChild(element)

    tracker.attachRoot(document)
    element.setAttribute(attribute, 'value')

    setTimeout(() => {
      expect(testManager.element).to.eq(element)
      tracker.shutdown()

      done()
    }, 0)
  })

  it('calls `update` on the manager when the attribute is changed', (done) => {
    let testManager = null

    const tracker = new AttributeTracker(attribute, (element) => {
      return (testManager = new TestManager(element))
    })

    const element = document.createElement('div')
    element.setAttribute(attribute, 'value')
    document.body.appendChild(element)

    tracker.attachRoot(document)

    element.setAttribute(attribute, 'changed')

    setTimeout(() => {
      expect(testManager.updateCalled).to.eq(true)
      tracker.shutdown()

      done()
    }, 0)
  })

  it('calls `shutdown` on the manager when the attr is removed', (done) => {
    let testManager = null

    const tracker = new AttributeTracker(attribute, (element) => {
      return (testManager = new TestManager(element))
    })

    const element = document.createElement('div')
    element.setAttribute(attribute, 'value')
    document.body.appendChild(element)

    tracker.attachRoot(document)
    element.removeAttribute(attribute)

    setTimeout(() => {
      expect(testManager.shutdownCalled).to.eq(true)
      tracker.shutdown()

      done()
    }, 0)
  })

  it('calls `shutdown` on managers when the tracker is shutdown', () => {
    let testManager = null

    const tracker = new AttributeTracker(attribute, (element) => {
      return (testManager = new TestManager(element))
    })

    const element = document.createElement('div')
    element.setAttribute(attribute, 'value')
    document.body.appendChild(element)

    tracker.attachRoot(document)
    tracker.shutdown()

    expect(testManager.shutdownCalled).to.eq(true)
  })

  describe('#getManager', () => {
    it('gives the manager for an element', () => {
      let testManager = null

      const tracker = new AttributeTracker(attribute, (element) => {
        return (testManager = new TestManager(element))
      })

      const element = document.createElement('div')
      element.setAttribute(attribute, 'value')
      document.body.appendChild(element)

      tracker.attachRoot(document)

      expect(tracker.getManager(element)).to.eq(testManager)

      tracker.shutdown()
    })
  })
})

class TestManager {
  constructor (element) {
    this.element = element
    this.updateCalled = false
    this.shutdownCalled = false
  }

  update () {
    this.updateCalled = true
  }

  shutdown () {
    this.shutdownCalled = true
  }
}
