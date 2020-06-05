// TODO: Something much more robust.
export default (event = null) => {
  const { type, target: { value } } = event;

  return {
    type,
    target: {
      value,
    },
  };
};
