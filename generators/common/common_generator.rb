class CommonGenerator < Rails::Generator::Base
  
  def initialize(runtime_args, runtime_options={})
    super(runtime_args, runtime_options)
  end
  
  
  def manifest
    record do |m|
      # verify directories existence
      
      m.directory('config')
      m.directory('config/initializers')
      m.directory('app/views/common')
            
      m.template('config/app_config.yml', 'config/app_config.yml')
      m.template('initializers/001_app_config.rb', 'config/initializers/001_app_config.rb')
      m.template('initializers/002_mailer_config.rb', 'config/initializers/002_mailer_config.rb')
      m.template('initializers/003_jquery.rb', 'config/initializers/003_jquery.rb')
      m.template('views/common/_error_messages.html.erb', 'app/views/common/_error_messages.html.erb')
    end
  end
  
end