export default function serializeEvent (event, extraData = null, element = null) {
  const { type } = event
  const details = serializeEventDetails(event)
  const target = serializeElement(event.target)

  return {
    type,
    details,
    extraData,
    target,
    element: element && serializeElement(element)
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
    if (event[property] !== undefined) {
      details[property] = event[property]
    }
  }

  return details
}

function serializeElement (element) {
  if (!element) return {}

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

  return Array
    .from(
      formData.entries(),
      ([key, value]) => (
        `${encodeURIComponent(key)}=${encodeURIComponent(value)}`
      )
    )
    .join('&')
}
