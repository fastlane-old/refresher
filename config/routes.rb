Rails.application.routes.draw do
  resources :update_checks

  get ':tool_name' => 'update_checks#check_update'
end
