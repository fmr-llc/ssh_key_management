require 'application_responder'

# Methods visible to all controllers
class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException, with: :show_ldap_error
  rescue_from Net::LDAP::LdapError, with: :show_ldap_error
  self.responder = ApplicationResponder
  respond_to :html
  layout false, only: :authorized_keys

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!, except: [:f5_health_check, :authorized_keys]

  def f5_health_check
    render html: 'THE SERVER IS UP'.html_safe
  end

  # GET /authorized_keys/?username=:username&host=:host
  def authorized_keys
    @start_time = Time.zone.now
    @cached = Rails.cache.exist? [params[:username], params[:host]]
    @authorized_keys = fetch_authorized_keys_from_cache params[:username], params[:host]
    respond_to :text, :json, :html
  end

  protected

  def show_ldap_error(exception)
    render text: exception, status: 500
  end

  def fetch_authorized_keys_from_cache(username, host)
    Rails.cache.fetch [username, host],  expires_in: 10.seconds do
      Credential.public_keys_for(username, host).to_a
    end
  end

  def append_info_to_payload(payload)
    super
    payload[:user_id] = current_user.try :username
    payload[:session_id] = session.id
  end
end
