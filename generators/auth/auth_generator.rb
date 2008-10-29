class AuthGenerator < Rails::Generator::Base
  
  def initialize(runtime_args, runtime_options={})
    super(runtime_args, runtime_options)
  end
  
  
  def manifest
    record do |m|
      # verify directories existence
      
      m.directory('app/models')
      m.directory('app/controllers')
      m.directory('lib')
      m.directory('app/views/account')
      m.directory('config/initializers')
      
      # verify class collisions
      m.class_collisions "User", "AccountController"
      
      m.template("controllers/account_controller.rb", 
        "app/controllers/account_controller.rb")
      
      %w{accept_invite accept_invite_denied complete_verify_email login no_mail_verify profile signup signup_complete verify_email}.each do |action_name|
        m.template("views/account/#{action_name}.html.erb",
          "app/views/account/#{action_name}.html.erb")
      end
      
      m.template("initializers/004_auth_system_hook.rb", 
        "config/initializers/004_auth_system_hook.rb")      
      
      m.template("models/user.rb",
        "app/models/user.rb")
        
      m.template("lib/authenticated_system.rb", 
        "lib/authenticated_system.rb")
      
      m.template("lib/authenticated_test_helper.rb", 
          "lib/authenticated_test_helper.rb")
          
      m.migration_template("migrate/create_user.rb",
        "db/migrate",:migration_file_name=>"create_users") unless options[:skip_migration]
      
      
    end
  end
  
end