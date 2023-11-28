class Tagger::User < ActiveRecord::Base
  self.table_name = "taggger_users"

  validates :email, uniqueness: true
end