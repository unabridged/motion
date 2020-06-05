export default (element, controller, action, event = null) => {
  const eventPrefix = event ? `${event}->` : '';
  const stimulusAction = `${eventPrefix}${controller}#${action}`;
  const anyStimulusActions = ('action' in element.dataset);

  if (!anyStimulusActions || !element.dataset.action.includes(stimulusAction)) {
    if (anyStimulusActions) {
      element.dataset.action = `${stimulusAction} ${element.dataset.action}`;
    } else {
      element.dataset.action = stimulusAction;
    }
  }
};
