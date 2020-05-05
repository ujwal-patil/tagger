class CreateTaggerUsers < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :taggger_users do |t|
      t.string :email, null: false

      t.timestamps
    end

    add_index :taggger_users, :email, unique: true
  end
end
