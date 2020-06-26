import parseBindings from '../../javascript/parseBindings.js'

describe('parseBindings', () => {
  context('with an empty string', () => {
    const input = ''

    it('gives an empty array', () => {
      expect(parseBindings(input)).to.eql([])
    })
  })

  context('with `null`', () => {
    const input = null

    it('gives an empty array', () => {
      expect(parseBindings(input)).to.eql([])
    })
  })

  context('with a valid binding string', () => {
    const input = 'sing song:finished->dance click(listen)->backflip'

    it('gives the correct parsing', () => {
      expect(parseBindings(input)).to.eql([
        {
          event: null,
          mode: null,
          motion: 'sing'
        },
        {
          event: 'song:finished',
          mode: null,
          motion: 'dance'
        },
        {
          event: 'click',
          mode: 'listen',
          motion: 'backflip'
        }
      ])
    })
  })
})
