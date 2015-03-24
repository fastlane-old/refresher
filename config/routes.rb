Rails.application.routes.draw do
  resources :update_checks

  root to: 'update_checks#stats'

  get ':tool_name' => 'update_checks#check_update'
end
