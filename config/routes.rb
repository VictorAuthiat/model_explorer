# frozen_string_literal: true

ModelExplorer::Engine.routes.draw do
  resources :models, only: [:index, :show]
  resources :exports, only: [:create]
end
