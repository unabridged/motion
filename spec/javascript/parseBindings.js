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
          id: 'sing',
          event: 'click',
          mode: 'handle',
          motion: 'sing'
        },
        {
          id: 'song:finished->dance',
          event: 'song:finished',
          mode: 'handle',
          motion: 'dance'
        },
        {
          id: 'click(listen)->backflip',
          event: 'click',
          mode: 'listen',
          motion: 'backflip'
        }
      ])
    })

    context('on a form', () => {
      const tagName = 'FORM'

      it('gives the correct parsing', () => {
        expect(parseBindings(input, tagName)).to.eql([
          {
            id: 'sing',
            event: 'submit',
            mode: 'handle',
            motion: 'sing'
          },
          {
            id: 'song:finished->dance',
            event: 'song:finished',
            mode: 'handle',
            motion: 'dance'
          },
          {
            id: 'click(listen)->backflip',
            event: 'click',
            mode: 'listen',
            motion: 'backflip'
          }
        ])
      })
    })

    context('on an input', () => {
      const tagName = 'INPUT'

      it('gives the correct parsing', () => {
        expect(parseBindings(input, tagName)).to.eql([
          {
            id: 'sing',
            event: 'change',
            mode: 'listen',
            motion: 'sing'
          },
          {
            id: 'song:finished->dance',
            event: 'song:finished',
            mode: 'handle',
            motion: 'dance'
          },
          {
            id: 'click(listen)->backflip',
            event: 'click',
            mode: 'listen',
            motion: 'backflip'
          }
        ])
      })
    })
  })
})
