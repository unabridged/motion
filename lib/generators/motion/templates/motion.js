import { createClient } from '@unabridged/motion'
import consumer from './channels/consumer'

export default createClient({

  // To avoid creating a second websocket, make sure to reuse the application's
  // ActionCable consumer. If you are not otherwise using ActionCable, you can
  // remove this line and the corresponding import.
  consumer,

  // Motion can log information about the lifecycle of components to the
  // browser's console. It is recommended to turn this feature off outside of
  // development.
  logging: process.env.RAILS_ENV === 'development'

  // This function will be called for every motion, and the return value will be
  // made available at `Motion::Event#extra_data`:
  //
  //    getExtraDataForEvent(event) {},

  // By default, the Motion client automatically disconnects all components when
  // it detects the browser navigating away to a new page. This is done to
  // prevent flashes of new content in components with broadcasts because of
  // some action being taken by the controller that the user is navigating to
  // (like submitting a form). If you do not want or need this functionally, you
  // can turn it off:
  //
  //    shutdownBeforeUnload: false,

  // The data attributes used by Motion can be customized, but these values must
  // also be updated in the Ruby initializer:
  //
  //    keyAttribute: 'data-motion-key',
  //    stateAttribute: 'data-motion-state',
  //    motionAttribute: 'data-motion',

})
