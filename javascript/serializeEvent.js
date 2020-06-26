export default function serializeEvent (event, extraData = null) {
  const { type } = event
  const details = serializeEventDetails(event)
  const target = serializeElement(event.target)

  return {
    type,
    details,
    extraData,
    target
  }
};

function serializeEventDetails (event) {
  if (event instanceof MouseEvent) {
    const { button, x, y, altKey, ctrlKey, metaKey, shiftKey } = event

    return {
      button,
      x,
      y,
      altKey,
      ctrlKey,
      metaKey,
      shiftKey
    }
  } else if (event instanceof KeyboardEvent) {
    const { key, keyCode, altKey, ctrlKey, metaKey, shiftKey } = event

    return {
      key,
      keyCode,
      altKey,
      ctrlKey,
      metaKey,
      shiftKey
    }
  } else {
    return event // take any enumerable properties
  }
}

function serializeElement (element) {
  const { tagName, value } = element
  const attributes = serializeElementAttributes(element)
  const formData = serializeElementFormData(element)

  return {
    tagName,
    value,
    attributes,
    formData
  }
}

function serializeElementAttributes (element) {
  const attributes = {}

  for (const attributeName of element.getAttributeNames()) {
    attributes[attributeName] = element.getAttribute(attributeName)
  }

  return attributes
}

function serializeElementFormData (element) {
  const form = element.form || element.closest('form')

  if (!form) {
    return null
  }

  const formData = new FormData(form)

  return Array.from(formData.entries())
    .map(([key, value]) =>
      `${encodeURIComponent(key)}=${encodeURIComponent(value)}`
    )
    .join('&')
}
