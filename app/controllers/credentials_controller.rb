# Credential controller
class CredentialsController < ApplicationController
  respond_to :html, :xml, :json, :js, :datatable
  before_action :set_credentials, if: :user_signed_in?
  before_action :set_credential, only: [:index, :show, :new, :edit, :update, :destroy]
  after_action :delete_key_cache_for, only: [:create, :update, :destroy]
  responders :flash, :http_cache

  # GET /credentials.format
  def index
    respond_with @credentials do |format|
      format.datatable { render json: CredentialsDatatable.new(view_context, collection: @credentials) }
    end
  end

  # GET /credentials/1.format
  def show
    respond_with @credential
  end

  # GET /credentials/new.format
  def new
    respond_with @credential
  end

  # GET /credentials/1/edit.format
  def edit
  end

  # POST /credentials/edit_multiple.format
  def edit_multiple
    if params[:delete]
      delete_key_cache_for @credentials.map(&:destroy)
      flash[:notice] = "Successfully destroyed #{t :credential_with_count, count: @credentials.count}"
      render :destroy_multiple
    else
      @credential = @credentials.first
    end
  end

  # POST /credentials.format
  def create
    @credential = @credentials.create credential_params
    respond_with @credential, location: -> { credential_path(@credential) }
  end

  # PATCH/PUT /credentials/1.format
  def update
    @credential.update credential_params
    respond_with @credential
  end

  # PATCH/PUT /credentials/update_multiple.format
  def update_multiple
    update_params = credential_params.reject { |_k, v| v.blank? }
    errors = @credentials.reject { |credential| credential.update(update_params) }
    @credential = errors.empty? ? @credentials.first : errors.first
    delete_key_cache_for @credentials
    respond_with @credential,
                 location: credentials_url,
                 action: :edit_multiple,
                 notice: "Successfully updated #{t :credential_with_count, count: @credentials.count}"
  end

  # DELETE /credentials/1.format
  def destroy
    @credential.destroy
    respond_with @credential
  end

  # GET /credentials/key_info/:key
  def key_info
    @key_info = Credential.key_info? params[:key]
    respond_with @key_info
  end

  private

  # Get collection
  def set_credentials
    @credentials = current_user.credentials
    @default_new_credential = @credentials.all.new username: current_user.username
    @credentials = @credentials.find(params[:ids]) if params.key?(:ids)
  end

  # Get current object from collection
  def set_credential
    @credential = params.key?(:id) ? @credentials.find(params[:id]) : @default_new_credential
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def credential_params
    # merge in the current_user object so that user's can't inject other user's IDs
    params.require(:credential).permit(:public_key, :host, :username, :tag_list).merge(user: current_user)
  end

  def delete_key_cache_for(cache = nil)
    cache ||= [@credential]
    cache.each do |credential|
      Rails.cache.delete [credential.username, credential.host]
    end
  end
end
