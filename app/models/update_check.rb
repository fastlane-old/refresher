class UpdateCheck < ActiveRecord::Base
  serialize :data, JSON
end
