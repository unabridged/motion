# frozen_string_literal: true

Rails.application.routes.draw do
  resource :counter_component, only: :show
  resource :timer_component, only: :show
  resource :test_component, only: :show
  resource :callback_component, only: :show

  resources :dogs, only: [:new, :create]
end
