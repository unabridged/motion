export default function serializeEvent (event, extraData = null) {
  const { type } = event
  const details = serializeEventDetails(event)
  const target = serializeElement(event.target)
  const currentTarget = serializeElement(event.currentTarget)

  return {
    type,
    details,
    extraData,
    target,
    currentTarget
  }
};

const detailProperties = [
  'button',
  'x',
  'y',
  'key',
  'keyCode',
  'altKey',
  'ctrlKey',
  'metaKey',
  'shiftKey'
]

function serializeEventDetails (event) {
  const details = {}

  for (const property of detailProperties) {
    if (Object.prototype.hasOwnProperty.call(event, property)) {
      details[property] = event[property]
    }
  }

  return details
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
