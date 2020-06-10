import morphdom from 'morphdom';

const keyAttr = 'data-motion-key';

export default (rootElement, newState) => {
  if (typeof(newState) !== 'string') {
    throw new TypeError("Expected raw HTML for reconcile newState");
  }

  const rootKey = rootElement.getAttribute(keyAttr);

  if (!rootKey) {
    throw new TypeError("Expected key on reconcile rootElement");
  }

  const onBeforeElUpdated = (fromElement, toElement) => {
    // When we are doing an inner update, propgrate the key and replace.
    if (rootElement === fromElement) {
      toElement.setAttribute(keyAttr, rootKey);
      return true;
    }

    // When we are doing an outer update, do not replace if the key is the same.
    const toElementKey = toElement.getAttribute(keyAttr);
    if (toElementKey && toElementKey === fromElement.getAttribute(keyAttr)) {
      return false;
    }

    // When two nodes have deep DOM equality, don't replace. This is correct because
    // we checked above that we are reconsiling against an HTML string (which *cannot
    // possibly have JavaScript state outside of the DOM because no handles have been
    // allowed to leave this function since parsing).
    //
    // See: https://github.com/patrick-steele-idem/morphdom#can-i-make-morphdom-blaze-through-the-dom-tree-even-faster-yes
    if (fromElement.isEqualNode(toElement)) {
      return false;
    }

    // Otherwise, take the new version.
    return true;
  };

  return morphdom(
    rootElement,
    newState,
    {
      onBeforeElUpdated,
    }
  );
};
