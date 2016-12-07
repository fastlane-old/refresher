class AddInstallationMethodToBacons < ActiveRecord::Migration
  def change
    add_column :bacons, :install_method_rubygems, :integer, default: 0
    add_column :bacons, :install_method_bundler, :integer, default: 0
    add_column :bacons, :install_method_mac_app, :integer, default: 0
    add_column :bacons, :install_method_standalone, :integer, default: 0
    add_column :bacons, :install_method_homebrew, :integer, default: 0
  end
end
