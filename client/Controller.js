import { Controller } from 'stimulus';

import { version } from './package.json';

import createActionManager from './createActionManager';
import createNavigationGuard from './createNavigationGuard';
import dispatchEvent from './dispatchEvent';
import getFallbackConsumer from './getFallbackConsumer';
import reconcile from './reconcile';
import serializeEvent from './serializeEvent';

export default class extends Controller {
  // == STIMULUS CALLBACKS =====================================================
  connect() {
    this._setupActionManager();
    this._setupSubscription();
    this._setupNavigationGuard();
  }

  disconnect() {
    this._teardownActionManager();
    this._teardownSubscription();
    this._teardownNavigationGuard();
  }

  // == OVERRIDE FREELY IN SUBCLASSES ==========================================
  keyAttribute = "data-motion-key";     // <--> `Motion.config.key_attribute`
  stateAttribute = "data-motion-state"; // <--> `Motion.config.state_attribute`
  motionAttribute = "data-motion";      // <--> `Motion.config.motion_attribute`

  // Override with the application's consumer to avoid an extra websocket
  getConsumer() {
    return getFallbackConsumer();
  }

  // Available at `Motion::Event#extra_data`
  getExtraDataForEvent(_event) {}

  // Lifecycle callbacks (dispatch DOM events by default)
  beforeConnect()   { dispatchEvent(this.element, 'motion:before-connect'); }
  connected()       { dispatchEvent(this.element, 'motion:connected'); }
  connectFailed()   { dispatchEvent(this.element, 'motion:connect-failed'); }
  disconnected()    { dispatchEvent(this.element, 'motion:disconnected'); }
  beforeRender()    { dispatchEvent(this.element, 'motion:before-render'); }
  rendered()        { dispatchEvent(this.element, 'motion:rendered'); }

  // == USE FREELY IN SUBCLASSES ===============================================
  performMotion(name, event = null) {
    if (!this._subscription) {
      return;
    }

    const extraDataForEvent = event && this.getExtraDataForEvent(event);

    this._subscription.perform(
      'process_motion',
      {
        name,
        event: event && serializeEvent(event, extraDataForEvent),
      },
    );

    if (event) {
      event.preventDefault();
    }
  }

  // == PRIVATE ================================================================
  _setupActionManager() {
    if (this._actionManager) {
      return;
    }

    this._actionManager = createActionManager(
      this,
      {
        target: 'performMotion',
        attribute: this.motionAttribute
      },
    );
  }

  _teardownActionManager() {
    if (!this._actionManager) {
      return;
    }

    this._actionManager.stop();
    this._actionManager = null;
  }

  _setupSubscription() {
    if (this._subscription) {
      return;
    }

    this.beforeConnect();

    const state = this.element.getAttribute(this.stateAttribute);

    if (!state) {
      return this.connectFailed();
    }

    this._subscription = this.getConsumer().subscriptions.create(
      {
        channel: 'Motion::Channel',
        version,
        state,
      },
      {
        connected: () => this.connected(),
        rejected: () => this.connectFailed(),
        disconnected: () => this.disconnected(),
        received: newState => this._render(newState),
      },
    );
  }

  _teardownSubscription() {
    if (!this._subscription) {
      return;
    }

    this._subscription.unsubscribe();
    this._subscription = null;
  }

  _setupNavigationGuard() {
    if (this._navigationGuard) {
      return;
    }

    // Disconncting the component when the browser starts to navigate away works
    // around changes flashing just before the page disappears because the
    // controller action that they are navigating to has some effect on the
    // component.
    this._navigationGuard = createNavigationGuard(() => {
      this._teardownSubscription();
    });
  }

  _teardownNavigationGuard() {
    if (!this._navigationGuard) {
      return;
    }

    this._navigationGuard.stop();
    this._navigationGuard = null;
  }

  _render(newState) {
    this.beforeRender();

    reconcile(this.element, newState, this.keyAttribute);

    this.rendered();
  }
}
