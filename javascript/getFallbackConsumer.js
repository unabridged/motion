import { createConsumer } from '@rails/actioncable'

let fallbackConsumer = null

export default function getFallbackConsumer () {
  return fallbackConsumer || (fallbackConsumer = createConsumer())
}
