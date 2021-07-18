class CreateCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :companies do |t|
      enable_extension :citext
      t.citext :name, null: false, index: {unique: true}
      t.timestamps
    end
  end
end
