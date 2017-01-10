Rails.application.routes.draw do
  resources :update_checks

  root to: 'update_checks#stats'

  get 'rockets' => 'update_checks#rockets' # rockets API
  get 'unique' => 'update_checks#unique'
  get 'graphs' => 'update_checks#graphs'
  get 'graph' => 'update_checks#graphs'
  get 'weekly' => 'update_checks#weekly'
  get 'speed' => 'update_checks#current_speed'

  get 'duration' => 'update_checks#get_durations'
  get 'geo' => 'application#geo'

  # Update information
  get ':tool_name' => 'update_checks#check_update'
  post ':tool_name' => 'update_checks#check_update'
  post 'time/:tool_name' => 'update_checks#store_time'
end
