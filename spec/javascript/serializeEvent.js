import serializeEvent from '../../javascript/serializeEvent.js'

describe('serializeEvent', () => {
  it('extracts event object details', () => {
    const evt = new KeyboardEvent('keydown', { key: 'A', keyCode: 65 })
    const { details } = serializeEvent(evt)

    expect(details.hasOwnProperty('button')).to.eql(false)
    expect(details.key).to.eql('A')
    expect(details.keyCode).to.eql(65)
    expect(details.hasOwnProperty('x')).to.eql(false)
    expect(details.hasOwnProperty('y')).to.eql(false)
    expect(details.altKey).to.eql(false)
    expect(details.metaKey).to.eql(false)
    expect(details.shiftKey).to.eql(false)
  })
})
