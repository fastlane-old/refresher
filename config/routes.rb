Rails.application.routes.draw do
  resources :update_checks

  get 'check_update/:tool_name' => 'update_checks#check_update'
end
