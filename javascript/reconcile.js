import morphdom from 'morphdom';

const keyAttr = 'data-motion-key';

export default (element, newHTML) => (
  morphdom(
    element,
    newHTML,
    {
      onBeforeElUpdated: (fromElement, toElement) => {
        // Don't replace if nodes are exactly the same according to the DOM.
        if (fromElement.isEqualNode(toElement)) {
          return false;
        }

        // Don't replace if the keys are the same.
        if (
          toElement.hasAttribute(keyAttr) &&
          toElement.getAttribute(keyAttr) === fromElement.getAttribute(keyAttr)
        ) {
          return false;
        }

        // Try to forward the key.
        if (
          fromElement.hasAttribute(keyAttr) &&
          !toElement.hasAttribute(keyAttr)
        ) {
          toElement.setAttribute(keyAttr, fromElement.getAttribute(keyAttr));
        }

        // Default to taking the new value.
        return true;
      },
    },
  )
)
