# Motion

Motion allows you to build reactive frontend UI components in your Rails application using pure Ruby.

* Plays nicely with the Rails monolith you have.
* Leans on Stimulus, ActionCable, and ViewComponent for the heavy lifting.
* Supports graceful degradation when JavaScript is turned off.
* Real-time frontend updates in response to frontend user interaction AND to server-side updates.
* No JavaScript required!


## Installation

Motion has ruby and javascript parts, execute both of these commands:

```sh
bundle add motion
yarn add motion
```

Motion also relies on but does not currently enforce the following libraries:

```sh
bundle add view_component
yarn add stimulus
```

Motion communicates over and therefore requires ActionCable. AnyCable support coming soon!

Github's [ViewComponent](https://github.com/github/view_component) is currently the de-facto standard for component/presenter-style libraries for use with Rails and likely will make it into Rails eventually. Until then, we plan to not enforce this dependency and are open to supporting other, similar libraries.

After installing all libraries, run the install script:

```sh
bin/rails motion:install
```

This will install 2 files, both of which you are free to leave alone. If you already have Stimulus set up and working, no more work is required.


## Usage

Using Motion with your existing ViewComponents couldn't be easier. There are 2 new API methods to know about inside your component class. Both of these methods will cause your component to re-render its template, and replace itself in-place on the frontend for all users are listening. If a user is viewing a page with a Motion component and they are listening, their component will be updated.

- `map_action` - Handle frontend events in the specified method inside your component class.
- `stream_from` - Listen to an ActionCable channel for updates. Can apply frontend changes for any number of users.

```ruby
class IncrementComponent < ViewComponent::Base
  include Motion::Component

  def initialize(total: 0)
    @total = 0
  end

  map_action :add

  def add
    @total += 1
  end

  stream_from "counter:cleared", :clear

  def clear
    @total = 0
  end
end
```

To hook up your mapped actions in your view, you use `data-motion`:

```erb
<div>
  <span><%= @total %></span>
  <%= button_to "Increment", data: { motion: "add" } %>
</div>
```

You can trigger action cable broadcasts to channels in the way that you're used to, and wheels will be set in motion:

```ruby
# rails console, controller, model callback, background job, rake task, etc
ActionCable.server.broadcast("counter:cleared")
```

Methods that are mapped using `map_action` or `stream_from` accept an event parameter which is a `Motion::Event`. This object can be used to extract data attribute, values, selected, checked, form state, and more from the frontend state.

```ruby
  map_action :add_amount

  def add_amount(event)
    @total += event.dig("target", "value").to_i
  end
```


## Limitations

* Due to the way that your components are replaced on the page, Motion ViewComponents are limited to a single top-level DOM element. If you have multiple DOM elements in your template at the top level, you must wrap them in a single element.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/motion.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
