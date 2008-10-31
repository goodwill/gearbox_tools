class UserMailer < ActionMailer::Base
  

  def verify_email(user, sent_at = Time.now)
    subject    "#{AppConfig.app_name} mail verification for #{user.full_name}"
    if user.has_proposed_email? 
      recipients "#{user.full_name} <#{user.proposed_email}>"
    else
      recipients "#{user.full_name} <#{user.email}>"
    end 
    from       "#{AppConfig.email_from_name} <#{AppConfig.email_from_address}>"
    sent_on    sent_at
    
    body    :user=>user,
            :host=>AppConfig.host
  end
  
  def forgot_password(user, sent_at=Time.now)
    subject "#{AppConfig.app_name} password reset request"
    recipients "#{user.full_name} <#{user.email}>"
    from "#{AppConfig.email_from_name} <#{AppConfig.email_from_address}>"
    sent_on sent_at
    body :user=>user, :host=>AppConfig.host
  end
  

end
