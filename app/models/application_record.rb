class ApplicationRecord < ActiveRecord::Base
  default_scope -> { order('created_at ASC') }

  self.abstract_class = true
end
