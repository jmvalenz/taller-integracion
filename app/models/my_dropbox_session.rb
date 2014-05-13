require "dropbox_sdk"
 
class MyDropboxSession < ActiveRecord::Base
  
  # This can obviously live anywhere you store your credentials or settings.
  APP_KEY = "nhb497zdwexpgim"
  APP_SECRET = "o9yt06xvb0dpplt"
  
  scope :authorized, where(authorized: true)
 
  attr_accessible :serialized_session, :app_key, :app_secret, :account_email
  attr_accessor :session
 
  after_initialize :create_or_recover_session
 
  def create_or_recover_session
    if self.serialized_session.present?
      recover_session
    else
      create_new_session
    end
  end
 
  def create_new_session
    self.authorized = false
    @session = DropboxSession.new(self.app_key, self.app_secret)
  end
 
  def authorization_url
    return @request_url if @get_request_url
    if @session.get_request_token
      @request_url = @session.get_authorize_url
    else
      @request_url = nil
    end
  end
 
  def complete_authorization
    @access_token = @session.get_access_token
    if @access_token
      self.authorized = true
      self.save_session
      self
    else
      self.authorized = false
      clear
      nil
    end
  end
 
  def save_session
    self.serialized_session = @session.serialize
    save
  end
 
  def recover_session
    @session = DropboxSession.deserialize(self.serialized_session)
  end
 
  def clear
    self.serialized_session = nil
    save
  end
 
  def client
    @client ||= DropboxClient.new(@session, :dropbox)
  end
 
end