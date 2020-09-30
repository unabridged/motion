import { createConsumer } from '@rails/actioncable'
import { createClient } from '@unabridged/motion'

const consumer = createConsumer()

createClient({
    consumer,
    logging: true
})

// Expose client state in globals for `spec/support/system_test_helpers.rb`:
window.connectCount = 0;
window.renderCount = 0;

document.addEventListener('motion:connect', () => {
    window.connectCount += 1;
})

document.addEventListener('motion:render', () => {
    window.renderCount += 1;
})