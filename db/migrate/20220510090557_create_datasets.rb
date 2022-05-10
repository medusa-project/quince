class CreateDatasets < ActiveRecord::Migration[7.0]
  def change
    create_table :datasets do |t|
      t.string :key
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
