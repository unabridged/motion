import { Controller } from 'stimulus';
import { createConsumer } from '@rails/actioncable';

import constants from './constants.json';

import reconcile from './reconcile';
import serializeEvent from './serializeEvent';
import addStimulusAction from './addStimulusAction';
import parseActions from './parseActions';

const channel = 'Motion::Channel';
const processActionCommand = 'process_action';

export default (consumer = createConsumer()) => {
  return class extends Controller {
    // Define these values here so they can be overwritten in a subclass
    keyAttr = constants.keyAttr;
    stateAttr = constants.stateAttr;
    actionAttr = constants.actionAttr;
    markerAttr = constants.markerAttr;
    disconnectedAttr = constants.disconnectedAttr;

    connect() {
      const state = this.element.getAttribute(this.stateAttr);

      if (!state) {
        console.warn(`Motion: Missing state ${this.stateAttr}`, this.element);
        return;
      }

      this.subscription = consumer.subscriptions.create(
        {
          channel,
          state,
        },
        {
          connected: () => this.serverConnected(),
          rejected: () => this.serverRejected(),
          disconnected: () => this.serverDisconnected(),
          received: data => this.receive(data),
        },
      );

      this.setupActions();
    }

    disconnect() {
      if (!this.subscription) {
        return;
      }

      this.subscription.unsubscribe();
    }

    serverConnected() {
      this.element.removeAttribute(this.disconnectedAttr);
    }

    serverDisconnected() {
      this.element.setAttribute(this.disconnectedAttr, '');
    }

    serverRejected() {
      console.warn('Motion: Failed to mount component on server.', this.element);
      this.element.serverDisconnected();
    }

    receive(newState) {
      reconcile(this.element, newState, this.keyAttr);
      this.setupActions();
    }

    performAction(name, event = null) {
      this.subscription.perform(
        processActionCommand,
        {
          name,
          event: this.serializeEvent(event),
        },
      );
    }

    serializeEvent(event = null) {
      return serializeEvent(event);
    }

    setupActions() {
      this.element.setAttribute(this.markerAttr, '');

      for(const element of this.element.querySelectorAll(`[${this.actionAttr}]`)) {
        if (element.closest(`[${this.markerAttr}]`) === this.element) {
          for (const { event, action } of parseActions(element.getAttribute(this.actionAttr))) {
            this.setupAction(element, action, event)
          }
        }
      }
    }

    setupAction(element, action, event = null) {
      const proxy = this.setupActionProxy(action);

      addStimulusAction(element, this.identifier, proxy, event);
    }

    setupActionProxy(action) {
      const handler = `performAction$${action}`;

      if (!(handler in this)) {
        this[handler] = this.buildActionProxyHandler(action);
      }

      return handler;
    }

    buildActionProxyHandler(action) {
      return event => this.performAction(action, event);
    }
  };
}
