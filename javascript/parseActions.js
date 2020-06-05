export default (actionsString) => (
  (actionsString || '').split(' ').map(actionString => {
    const [eventOrAction, action] = actionString.split('->', 2);

    if (action) {
      return {
        event: eventOrAction,
        action,
      };
    } else {
      return {
        event: null,
        action: eventOrAction,
      };
    }
  })
);
