class MementoMigration < ActiveRecord::Migration

  def change
    create_table :memento_sessions do |t|
      t.references :user
      t.timestamps null: false
    end

    create_table :memento_states do |t|
      t.string :action_type
      t.binary :record_data, :limit => 16777215
      t.references :record, :polymorphic => true
      t.references :session
      t.timestamps null: false
    end
  end

end
