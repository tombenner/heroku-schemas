class CreateDummyRecords < ActiveRecord::Migration
  def change
    create_table :dummy_records do |t|
      t.string :name

      t.timestamps
    end
  end
end
