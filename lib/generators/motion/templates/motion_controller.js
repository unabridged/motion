import { createMotionController } from "@unabridged/motion";

// To avoid creating a second WebSocket, make sure to reuse the application's
// ActionCable consumer.
import consumer from "../channels/consumer";

// If you change the name of this controller (determined by the file name),
// make sure to update the Ruby initializer.
export default createMotionController(consumer);

// It is possible to additionally customize the behavior of the client by
// extending the controller:
//
//    export default class extends createMotionController(consumer) {
//        // These values must also be updated in the Ruby initializer:
//        keyAttr           = 'data-motion-key';
//        stateAttr         = 'data-motion-state';
//
//        // These values are for the client (but may require template changes):
//        actionAttr        = 'data-motion';
//        markerAttr        = 'data-motion-component';
//        disconnectedAttr  = 'data-motion-disconnected';
//
//        // These callbacks can be freely customized:
//        serverConnected()     { /* ... */ }
//        serverDisconnected()  { /* ... */ }
//        serverRejected()      { /* ... */ }
//    };
