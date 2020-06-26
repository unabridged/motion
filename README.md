# Motion

[![Gem Version](https://badge.fury.io/rb/motion.svg)](https://badge.fury.io/rb/motion)
[![npm version](https://badge.fury.io/js/%40unabridged%2Fmotion.svg)](https://badge.fury.io/js/%40unabridged%2Fmotion)
[![Build Status](https://travis-ci.com/unabridged/motion.svg?branch=master)](https://travis-ci.com/unabridged/motion)
[![Maintainability](https://api.codeclimate.com/v1/badges/3167364a38b1392a5478/maintainability)](https://codeclimate.com/github/unabridged/motion/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/3167364a38b1392a5478/test_coverage)](https://codeclimate.com/github/unabridged/motion/test_coverage)
[![Ruby Code Style](https://img.shields.io/badge/Ruby_Code_Style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![JavaScript Code Style](https://img.shields.io/badge/JavaScript_Code_Style-standard-brightgreen.svg)](https://standardjs.com)

Motion allows you to build reactive, real-time frontend UI components in your Rails application using pure Ruby.

* Plays nicely with the Rails monolith you have.
* Peacfully coexists with your existing tech: Strong Parameters, Turbolinks, Trix, React, Vue, etc.
* Real-time frontend UI updates from frontend user interaction AND server-side updates.
* Leans on Stimulus, ActionCable, and ViewComponent for the heavy lifting.
* No more frontend models, stores, or syncing; your source of truth is the database you already have.
* No JavaScript required!


## Installation

Motion has Ruby and JavaScript parts, execute both of these commands:

```sh
bundle add motion
yarn add @unabridged/motion
```

Motion also relies on but does not currently enforce the following libraries:

```sh
bundle add view_component
yarn add stimulus
```

Motion communicates over and therefore requires ActionCable. AnyCable support coming soon!

After installing all libraries, run the install script:

```sh
bin/rails g motion:install
```

This will install 2 files, both of which you are free to leave alone. If you already have Stimulus set up and working, no more work is required.


### Note: Component Support in Rails 6

Github's [ViewComponent](https://github.com/github/view_component) is currently the most popular Ruby gem for component/presenter-style libraries in Rails. Formal support for 3rd-party component frameworks [landed in Rails 6](rails/rails#36388), and it's very possible that a blessed component framework will become "ActionView::Component" or similar for Rails 6.1. Until then, we plan to *not* enforce this dependency and are exploring support for other, similar libraries.


## How does it work?

Motion allows you to mount special DOM elements (henceforth "Motion components") in your standard Rails views that can be real-time updated from frontend interactions, backend state changes, or a combination of both. This is similar to something like [Stimulus Reflex](https://github.com/hopsoft/stimulus_reflex) in a few ways:

- **Websockets Communication** - Communication with your Rails backend is performed via ActionCable (AnyCable support coming soon).
- **No Full Page Reload** - The current page for a user is updated in place.
- **Fast DOM Diffing** - DOM diffing is performed when replacing existing content with new content.
- **Server Triggered Events** - Server-side events can trigger updates to arbitrarily many components via WebSocket channels.

However Motion has a fundamentally different architecture than Stimulus Reflex and is much more like [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) (and even React!) in some key ways:

- **Partial Page Replacement** - Motion does not use full page replacement, but rather replaces only the component on the page with new HTML, DOM diffed for performance.
- **Encapsulated, consistent stateful components** - Components have continuous internal state that persists and updates. This means each time a component changes, new rendered HTML is generated and can replace what was there before.
- **Blazing Fast** - Communication does not have to go through the full Rails router and controller stack. No changes to your routing or controller are required to get the full functionality of Motion.


### Frontend interactions

Frontend interactions can update your Motion components using standard JavaScript events that you're already familiar with: `change`, `blur`, form submission, and more. You can invoke Motion actions manually using JavaScript if you need to.

The primary way to handle user interactions on the frontend is by using `map_motion`:

```ruby
class MyComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :total

  def initialize(total: 0)
    @total = 0
  end

  map_motion :add

  def add
    @total += 1
  end
end
```

To invoke this motion on the frontend, add `data-motion='add'` to your component's template:

```erb
<div>
  <span><%= total %></span>
  <%= button_tag "Increment", data: { motion: "add" } %>
</div>
```

This component can be included on your page the same as always with ViewComponent:

```erb
<%= render MyComponent.new(total: 5) %>
```

Every time the "Increment" button is clicked, MyComponent will call the `add` method, re-render your component and send it back to the frontend to replace the existing DOM. All invocations of mapped motions will cause the component to re-render, and unchanged rendered HTML will not perform any changes.


### Backend interactions

Backend changes can be streamed to your Motion components in 2 steps.

1. Broadcast changes using ActionCable after an event you care about:

```ruby
class Todo < ApplicationModel
  after_commit :broadcast_created, on: :create

  def broadcast_created
    ActionCable.server.broadcast("todos:created", id)
  end
end
```

2. Configure your Motion component to listen to an ActionCable channel:

```ruby
class MyComponent < ViewComponent::Base
  include Motion::Component

  stream_from "todos:created", :handle_created

  def handle_created
    @todos = Todo.all
  end
end
```

This will cause any user that has a page open with `MyComponent` mounted on it to re-render that component's portion of the page.

All invocations of `stream_from` connected methods will cause the component to re-render everywhere, and unchanged rendered HTML will not perform any changes.


## Motion::Event and Motion::Element

Methods that are mapped using `map_motion` or `stream_from` accept an `event` parameter which is a `Motion::Event`. This object has a `target` attribute which is a `Motion::Element`, the element in the DOM that triggered the motion. Useful state and attributes can be extracted from these objects, including value, selected, checked, form state, data attributes, and more.

```ruby
  map_motion :example

  def example(event)
    event.type # => "change"
    event.name # alias for type

    element = event.target # => Motion::Element instance
    element.tag_name # => "input"
    element.value # => "5"
    element[:value] # hash lookup version, works for all attributes
    element.attributes # { class: "col-xs-12", ... }

    # DOM element with data-field="..."
    element.data[:field]

    # ActionController::Parameters instance with all form params. Also
    # available on Motion::Event objects for convenience.
    element.form_data
  end
```

See the code for full API for [Event](https://github.com/unabridged/motion/blob/master/lib/motion/event.rb) and [Element](https://github.com/unabridged/motion/blob/master/lib/motion/element.rb).


## Limitations

* Due to the way that your components are replaced on the page, Motion ViewComponents templates are limited to a single top-level DOM element. If you have multiple DOM elements in your template at the top level, you must wrap them in a single element. This is a similar limitation that React enforced until `React.Fragment` appeared and is for a very similar reason.


## Roadmap

Broadly speaking, these initiatives are on our roadmap:

- Decouple from Stimulus for fewer dependencies (in progress)
- Enhanced documentation and usage examples
- Support more ViewComponent-like libraries: [trailblazer/cells](https://github.com/trailblazer/cells), [dry-rb/dry-view](https://github.com/dry-rb/dry-view), [komposable/komponent](https://github.com/komposable/komponent)
- AnyCable support for ultra-scalable performance
- Support communication via AJAX instead of (or in addition to) websockets


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unabridged/motion.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
