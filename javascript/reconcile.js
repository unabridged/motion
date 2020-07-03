import morphdom from 'morphdom'

export default (rootElement, newState, keyAttribute) => {
  if (typeof (newState) !== 'string') {
    throw new TypeError('Expected raw HTML for reconcile newState')
  }

  // remove root element when component sends an empty state
  if (!newState) return rootElement.remove()

  const rootKey = rootElement.getAttribute(keyAttribute)

  if (!rootKey) {
    throw new TypeError('Expected key on reconcile rootElement')
  }

  const onBeforeElUpdated = (fromElement, toElement) => {
    // When we are doing an inner update, propgrate the key and replace.
    if (rootElement === fromElement) {
      toElement.setAttribute(keyAttribute, rootKey)
      return true
    }

    // When we are doing an outer update, do not replace if the key is the same.
    const toKey = toElement.getAttribute(keyAttribute)
    if (toKey && toKey === fromElement.getAttribute(keyAttribute)) {
      return false
    }

    if (
      // For some reason, it it seems like all TEXTAREAs are equal to eachother
      // regardless of their content which is super werid because the same thing
      // does not seem to be true for INPUTs or SELECTs whose value has changed.
      fromElement.tagName !== 'TEXTAREA' &&

      // When two nodes have (deep) DOM equality, don't replace. This is correct
      // because we checked above that we are reconsiling against an HTML string
      // (which cannot possibly have state outside of the DOM because no handles
      // have been allowed to leave this function since parsing).
      fromElement.isEqualNode(toElement)
    ) {
      return false
    }

    // Otherwise, take the new version.
    return true
  }

  return morphdom(
    rootElement,
    newState,
    {
      onBeforeElUpdated
    }
  )
}
