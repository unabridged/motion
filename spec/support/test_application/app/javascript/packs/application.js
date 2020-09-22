import { createConsumer } from '@rails/actioncable'
import { createClient } from '@unabridged/motion'

const consumer = createConsumer()
const motionClient = createClient({ consumer })
