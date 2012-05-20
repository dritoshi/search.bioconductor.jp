class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.string :package
      t.string :version
      t.string :file_path
      t.string :file
      t.string :language
      t.text :code
    end
  end
end
