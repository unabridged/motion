appraise "rails-5-2" do
  gem "rails", "~> 5.2.0"

  # Rails 5 does not have built-in support for ActionCable tests.
  gem "action-cable-testing"
end

appraise "rails-6-0" do
  gem "rails", "~> 6.0.0"
end

appraise "rails-6-1" do
  gem "rails", "~> 6.1.0"
end

appraise "rails-7-0" do
  gem "rails", "~> 7.0.0"

  # Rails 7 and beyond do not include Sprokets by default
  gem "sprockets-rails"
end

appraise "rails-main" do
  gem "rails", git: "https://github.com/rails/rails.git", branch: "main"

  # Rails 7 and beyond do not include Sprokets by default
  gem "sprockets-rails"
end
