class AccountController < ApplicationController
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :login_required, :only=>['profile']

  # say something nice, you goof!  something sweet.
  def index
    if !logged_in? || User.count > 0
      redirect_to(:action => 'signup') 
    else
      render :nothing
    end
  end
  
  def profile
    @user=current_user if request.get?
    return unless request.put?
    @user=User.find(params[:id])
    # we only allow a white list attributes to be modified
    @user.modify_profile(params[:user])
    flash[:notice]="Profile updated successfully." if @user.save 
    
    
  end
  
  def change_password
    
    redirect_to :action=>:profile
    return unless request.post?
    
    if params[:new_password].empty? 
      flash[:notice]="Password cannot be empty."
      return
    end
    
    @user=User.find(params[:id])
    unless @user.authenticated?(params[:old_password])
      flash[:notice]="Incorrect old password."
    else
      
      @user.password=params[:new_password]
      @user.password_confirmation=params[:new_password_confirmation]

      if !@user.save
        flash.now[:notice]="Unable to change password. Make sure your new password and confirmation matches and password length should be between 4 and 40 characters."
      else
        flash.now[:notice]="Password changed successfully."
      end
      
    end

  end
  
  def login
    return unless request.post?
    login_with_credential(params[:email], params[:password])
    
    if logged_in?
      redirect_back_or_default(:controller => 'home') 
      flash[:notice] = "Logged in successfully"
    else
      flash.now[:notice]="Incorrect username or password. Please try again."
    end
  end
  
  def verify_email
    # force logout
    logout_user
    if params[:id].nil?
      flash[:notice]="Incorrect URL. Please make sure you have copied the entire URL from your email client to complete the mail verification process."
    else
      @user=User.find_by_uid(params[:id])
    
      if @user.nil?
        flash[:notice]="Unable to find user with the provided verification link. Please contact technical support."
      else
        if @user.mail_verified? && !@user.has_proposed_email?
          flash.now[:notice]="Verification already completed in the past."
          render :action=>:complete_verify_email
        end
 
      end
    end
    
  end
  
  def change_email
    return if params[:id].nil?
    @user=User.find(params[:id])
    
    
    @user.generate_new_uid
    @user.proposed_email=params[:new_email]
    if @user.save
    
      email= UserMailer.deliver_verify_email(@user)
    
      flash[:notice]="Email changed successfully. Please complete the email verification process by checking your email and follow the instructions enclosed. Your new email would only be activated after verification has completed."
    
    end
    
    render :action=>:profile 
  
    
  end
  
  
  def complete_verify_email

    @user=User.find(params[:id])
    if @user.authenticated?(params[:password])
      if !@user.mail_verified? 
        @user.mail_verified=true
      elsif @user.has_proposed_email?
        @user.commit_proposed_email
      end
      # verification completed, auto login

      @user.save
      
      login_as @user
    
    else
      flash[:notice]="Wrong password. Please try again."
      redirect_to :action=>:verify_email, :id=>@user.uid
    end
  end
  
  def no_mail_verify
    
  end
  
  def accept_invite
    @invited_user = User.find_by_uid(params[:id])
    if @invited_user.nil? 
      render_invite_deny_template("Unable to find user. Make sure you have copied the entire url from your email to your browser and try again.")
      
      return
    elsif !@invited_user.being_invited 
      render_invite_deny_template("Account has no pending invitation.")
      return      
      
    end
    return unless request.post?


    if @invited_user.update_attributes(params[:invited_user].merge(:being_invited=>false, :mail_verified=>true, :force_password=>true))
      flash.now[:notice]="Congratulations your account is activated. Login now to start using #{AppConfig.app_name}."
    end
      
    
    
    

  end
  

  def signup
    @user = User.new_web_user(params[:user])
    return unless request.post?
    if @user.save
      # generate confirmation email
      UserMailer.deliver_verify_email(@user)
      redirect_back_or_default(:controller => '/account', :action => 'signup_complete')
    else

      current_user=User.find_by_email(@user.email)
      if !current_user.nil? && !current_user.mail_verified?
        UserMailer.deliver_verify_email(current_user)
        flash.now[:notice]="Email has already registered, but verification is not completed yet. Verification email has been send, please follow the procedures in email to complete email verification."
      end
    end

  end
  
  def signup_complete
    
  end
  
  
  def logout
    logout_user
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/root', :action => 'index')
  end

  
  
  private
    def logout_user
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
    end
  
    def login_as(user)
      
      if !user.mail_verified && !user.is_admin 
        redirect_to :action=>:no_mail_verify
      else
        self.current_user=user

        if params[:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end

      end
    end
    
    def login_with_credential(email, password)
      user = User.authenticate(email, password)
      login_as user unless user.nil?
    end
    
    def render_invite_deny_template(message)
      flash.now[:notice]=message
      render :action=>:accept_invite_denied
    end

    
    
end
