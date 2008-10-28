class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users" do |t|
      t.string   "first_name",:null=>false
      t.string   "last_name",:null=>false
      t.string   "email",:null=>false
      t.string   "crypted_password" ,:null=>false,         :limit => 40
      t.string   "salt",:null=>false,                      :limit => 40
      t.string   "remember_token"
      t.datetime "remember_token_expires_at"
      t.boolean  "is_admin",:null=>false,                                :default => false
      t.boolean  "mail_verified",                           :default => false
      t.string   "uid"
      t.string   "proposed_email"
      t.string   "time_zone"
      t.boolean  "reset_password",                          :default => false
      t.boolean  "being_invited"
      t.timestamps
    end
  end
  
  def self.down
    drop_table "users"
  end
  
end