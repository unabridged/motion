import morphdom from 'morphdom';

const keyAttr = 'data-motion-key';

export default (rootElement, newHTML) => {
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

    // Fast path:
    //  Never replace if nodes are the same according to the DOM (since we start with
    //  HTML anyway, none of the "minor concerns" with this apply).
    //
    //  See https://github.com/patrick-steele-idem/morphdom#can-i-make-morphdom-blaze-through-the-dom-tree-even-faster-yes
    if (fromElement.isEqualNode(toElement)) {
      return false;
    }

    // Otherwise, take the new version.
    return true;
  };

  return morphdom(
    rootElement,
    newHTML,
    {
      onBeforeElUpdated,
    }
  );
};
