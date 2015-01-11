class FriendshipGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  desc "Create a model and migration for friendship. NAME is the model you wish to have a friendship relationship."

  def generate_migration
    migration_template "friendship_migration.rb.erb", "db/migrate/#{migration_file_name}"
  end

  def generate_class
    template "friendship_model.rb.erb", "app/models/#{model_filename}"
  end



  def migration_name
    "create_#{name.underscore}_friendship"
  end

  def migration_file_name
    "#{migration_name}.rb"
  end

  def migration_class_name
    migration_name.camelize
  end

  def orig_class_name_und
    "#{name.underscore.downcase}"
  end
  def orig_class_name_cam
    "#{name.camelize}"
  end

  def table_name
   ":#{orig_class_name_und}_friendships"
  end

  def class_name
    "#{orig_class_name_cam}Friendship"
  end

  def model_filename
    "#{orig_class_name_und}_friendship.rb"
  end


  def self.next_migration_number(path)
    require  'rails/generators/active_record'
    ActiveRecord::Generators::Base.next_migration_number path
  end
end
