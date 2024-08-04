# frozen_string_literal: true

ModelExplorer::Engine.routes.draw do
  root to: "models#index"

  resources :models, only: [:index, :show]
  resource :exports, only: [:show]
end
