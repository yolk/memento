class MementoMigration < ActiveRecord::Migration

  def self.up
    create_table :memento_sessions do |t|
      t.references :user
      t.timestamps
    end

    create_table :memento_states do |t|
      t.string :action_type
      t.binary :record_data, :limit => 16777215
      t.references :record, :polymorphic => true
      t.references :session
      t.timestamps
    end
  end

  def self.down
    drop_table :memento_states
    drop_table :memento_sessions
  end

end