require 'digest/sha1'
require 'uuidtools'
class User < ActiveRecord::Base
  ProfileWhiteListAttributes=['first_name','last_name', 'time_zone']
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  has_many :task_list_user_shares
  has_many :task_lists, :through=>:task_list_user_shares
  before_validation_on_create {|r| r.generate_new_uid }
  before_validation :before_validate
  validates_presence_of     :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email, :with=>/[\w\d]([\w\d\.\-]{0,1}[\w\d]+)*@[\w\d]+([\w\d\-]*\.)+[\w]+/,  :message=>'is not a valid email address.'
  validates_uniqueness_of   :uid, :case_sensitive=>false
  validates_presence_of     :first_name
  validates_format_of       :proposed_email, :with=>/[\w\d]([\w\d\.\-]{0,1}[\w\d]+)*@[\w\d]+([\w\d\-]*\.)+[\w]+/, :allow_nil=>true, :message=>'is not a valid email address.'

  before_save :encrypt_password

  # Creates normal user from web, used for signup procedure, default not verified email and not admin
  def self.new_web_user(user_hash)
    user_hash ||= {}
    User.new(user_hash.merge(:is_admin=>false, :mail_verified=>false))
  end
  
  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(password) ? u : nil

  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
  
  def self.find_by_email(email)
    
    find(:first,:conditions=>{:email=>email.downcase}) unless email.nil?
  
  end
  
  
  def generate_new_uid
    self.uid=UUID.random_create.to_s 
  end
  
  def commit_proposed_email
    self.email=self.proposed_email
    self.proposed_email=nil
  end
  
  # modify a list of white listed attributes
  def modify_profile(attributes)
    update_attributes(attributes.reject{|key,value| !ProfileWhiteListAttributes.include?(key)})
  end
  
  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  
  def has_proposed_email?
    !self.proposed_email.nil?
  end
  
  def get_time_zone
    TimeZone.new(self.time_zone)
  end
  
  def accepted_invite?
    !self.being_invited?
  end
  
  def force_password=(value)
    
    @force_password=value
  end
  
  def force_password
    @force_password
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank? || force_password
    end
    
  private
    def before_validate
      self.email.downcase! unless self.email.nil?
      self.proposed_email.downcase! unless self.proposed_email.nil?
    end
    
    def validate
      # TODO: There is a corner case when somebody taken the email as unverified, then a new user register the new account with the unverified email, should reject the new user or let the verification fail on uniqueness rule?
      if has_proposed_email? 
        if self.proposed_email == self.email 
          errors.add(:proposed_email, 'is the same as current email.')
        else
          errors.add(:proposed_email, 'address already taken by another user.') if User.find_by_email(self.proposed_email)
        end
      end
    end
    
end
