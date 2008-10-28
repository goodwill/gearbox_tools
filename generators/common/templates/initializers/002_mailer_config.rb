require "smtp_tls"

ActionMailer::Base.delivery_method = AppConfig.mail_delivery_method.intern unless AppConfig.mail_delivery_method.nil?

unless AppConfig.smtp.nil?

  smtp_settings = {
    :address => AppConfig.smtp['address'],
    :port=>AppConfig.smtp['port'] || 25,
  } 
  smtp_settings[:authentication]=AppConfig.smtp['authentication'].intern unless AppConfig.smtp['authentication'].nil?
  unless AppConfig.smtp['username'].nil?
    smtp_settings[:user_name]=AppConfig.smtp['username'] 
    smtp_settings[:password]=AppConfig.smtp['password'] 
  end

  ActionMailer::Base.smtp_settings= smtp_settings
  unless AppConfig.raise_delivery_errors.nil?
    ActionMailer::Base.raise_delivery_errors=AppConfig.raise_delivery_errors
  end
  
end

