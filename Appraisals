appraise "rails-5-2" do
  gem "rails", "~> 5.2"

  # Rails 5 does not have built-in support for ActionCable tests.
  gem "action-cable-testing"

  # Support for Ruby 2.4 was removed in 3.33
  gem "capybara", "< 3.33"
end

appraise "rails-6-0" do
  gem "rails", "~> 6.0"
end

appraise "rails-master" do
  gem "rails", git: "https://github.com/rails/rails.git", ref: "master"
end
