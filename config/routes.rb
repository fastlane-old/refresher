Rails.application.routes.draw do
  resources :update_checks

  root to: 'update_checks#stats'

  get 'unique' => 'update_checks#unique'
  get 'graphs' => 'update_checks#graphs'
  get 'graph' => 'update_checks#graphs'
  get 'weekly' => 'update_checks#weekly'

  get 'duration' => 'update_checks#get_durations'

  # Update information
  get ':tool_name' => 'update_checks#check_update'
  post ':tool_name' => 'update_checks#check_update'
  post 'time/:tool_name' => 'update_checks#store_time'
end
