appraise "rails-5-1" do
  gem "rails", "~> 5.1.7"

  # Rails 5 does not have built-in support for ActionCable tests.
  gem "action-cable-testing"

  # mimemagic releases < 0.3.8 have been yanked from rubygems.org
  # because of a license violation problem
  gem "mimemagic", "~> 0.3.10"
end

appraise "rails-5-2" do
  gem "rails", "~> 5.2.0"

  # Rails 5 does not have built-in support for ActionCable tests.
  gem "action-cable-testing"

  # mimemagic releases < 0.3.8 have been yanked from rubygems.org
  # because of a license violation problem
  gem "mimemagic", "~> 0.3.10"
end

appraise "rails-6-0" do
  gem "rails", "~> 6.0.0"

  # mimemagic releases < 0.3.8 have been yanked from rubygems.org
  # because of a license violation problem
  gem "mimemagic", "~> 0.3.10"
end

appraise "rails-6-1" do
  gem "rails", "~> 6.1.0"

  # mimemagic releases < 0.3.8 have been yanked from rubygems.org
  # because of a license violation problem
  gem "mimemagic", "~> 0.3.10"
end

appraise "rails-main" do
  gem "rails", git: "https://github.com/rails/rails.git", ref: "main"
end
