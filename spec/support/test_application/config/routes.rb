# frozen_string_literal: true

Rails.application.routes.draw do
  resource :test_component, only: :show
end
