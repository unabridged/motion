import { Controller } from 'stimulus';
import { createConsumer } from '@rails/actioncable';

import reconcile from './reconcile';
import serializeEvent from './serializeEvent';
import addStimulusAction from './addStimulusAction';
import parseActions from './parseActions';

const channel = 'Motion::Channel';
const processActionCommand = 'process_action';
const motionStateAttr = 'data-motion-state';
const motionActionAttr = 'data-motion';
const motionComponentAttr = 'data-motion-component';
const motionDisconnectedAttr = 'data-motion-disconnected';

const motionActionSelector = `[${motionActionAttr}]`;
const motionComponentSelector = `[${motionComponentAttr}]`;

export default (consumer = createConsumer()) => {
  return class extends Controller {
    connect() {
      const state = this.element.getAttribute(motionStateAttr);

      if (!state) {
        throw new Error('Motion: Cannot use MotionController without ' + motionStateAttr);
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
      this.subscription.unsubscribe();
    }

    serverConnected() {
      this.element.removeAttribute(motionDisconnectedAttr);
    }

    serverDisconnected() {
      this.element.setAttribute(motionDisconnectedAttr, '');
    }

    serverRejected() {
      console.warn('Motion: Failed to mount component on server.');
      this.element.setAttribute(motionDisconnectedAttr, '');
    }

    receive(newState) {
      reconcile(this.element, newState);
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
      this.element.setAttribute(motionComponentAttr, '');

      for(const element of this.element.querySelectorAll(motionActionSelector)) {
        if (element.closest(motionComponentSelector) === this.element) {
          for (const { event, action } of parseActions(element.getAttribute(motionActionAttr))) {
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
