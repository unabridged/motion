import Client from './Client'

export function createClient (options) {
  return new Client(options)
}

export default createClient
