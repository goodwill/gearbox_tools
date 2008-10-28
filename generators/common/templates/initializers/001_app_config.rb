require 'ostruct'
require 'yaml'

app_config_path="#{RAILS_ROOT}/config/app_config.yml"

if File.exist?(app_config_path)

  config=OpenStruct.new(YAML.load_file(app_config_path))
  env_config=config.send(RAILS_ENV =~ /test/ ? 'test_env' : RAILS_ENV)
  config.common.update(env_config) unless env_config.nil?
  ::AppConfig = OpenStruct.new(config.common)
else
  puts "Configuration not exist. Skipped configuration loading"
end
