import { Controller } from "@unabridged/motion";
import consumer from "../channels/consumer";

// If you change the name of this controller (determined by the file name),
// make sure to update `Motion.config.stimulus_controller_identifier`.
export default class extends Controller {
  // To avoid creating a second websocket, make sure to reuse the application's
  // ActionCable consumer.
  getConsumer() {
      return consumer;
  }

  // It is possible to additionally customize the behavior of the client by
  // overriding these properties and methods:

  // getExtraDataForEvent(event) {}        // `Motion::Event#extra_data`

  // keyAttribute = "data-motion-key";     // `Motion.config.key_attribute`
  // stateAttribute = "data-motion-state"; // `Motion.config.state_attribute`
  // motionAttribute = "data-motion";      // `Motion.config.motion_attribute`

  // beforeConnect() { /* by default, dispatches `motion:before-connect`    */ }
  // connected()     { /* by default, dispatches `motion:connected`         */ }
  // connectFailed() { /* by default, dispatches `motion:connect-failed`    */ }
  // disconnected()  { /* by default, dispatches `motion:disconnected`      */ }
  // beforeRender()  { /* by default, dispatches `motion:before-render`     */ }
  // rendered()      { /* by default, dispatches `motion:rendered`          */ }
}
