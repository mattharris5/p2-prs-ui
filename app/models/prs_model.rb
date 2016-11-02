class PrsModel < ActiveRestClient::Base
  extend ActiveModel::Naming

  base_url Rails.application.secrets.prs_url
  # get :all, "/districts;zoneId=#{ENV["PRS_ZONE_ID"]};contextId=#{ENV["PRS_CONTEXT_ID"]}"
  # get :all, "/districts/:district_id/services/:service_id/students"
  # get :find, "/districts/:district_id/services/:service_id/students/:id" #, :has_one => { :consent => District::StudentConsent }
  # put :save, "/districts/:district_id/services/:service_id/students/:id"
  # post :create, "/districts/:district_id/services/:service_id/students/"
  # delete :destroy, "/districts/:district_id/services/:service_id/students/:id"
  # get :filters, "/filters;zoneId=:zoneid;contextId=DEFAULT"

  before_request :add_authentication_details
  request_body_type :json

  SessionToken = Rails.application.secrets.prs_session_token
  SharedSecret = Rails.application.secrets.prs_shared_secret

  attr_accessor :new_record

  def to_param
    id.to_s
  end

  def to_model
    self
  end

  def new_record?
     !@attributes.any? || new_record
  end
  def destroyed?()  false end
  def persisted?
    !new_record?
  end

  # Override the model name to remove the inherited namespace. This helps in appropriate form_for generation.
  def self.model_name
    ActiveModel::Name.new(self, nil, self.to_s.split("::").last)
  end

  def errors
    # obj = Object.new
    # def obj.[](key)         [] end
    # def obj.full_messages() [] end
    # obj
    @errors ||= ActiveModel::Errors.new(self)
  end

  # Override the #update method to manually set each attribute and call #save.
  # TODO: Figure out how to do this a better way with ActiveRestClient.
  def update(updated_attributes = {})
    for key, value in updated_attributes
      self[key] = value
    end
    save
  end

  protected

  def add_authentication_details(name, request)
    raise Exception.new("Missing authentication credentials") if SessionToken.nil? || SharedSecret.nil?
    timestamp = Time.now.utc.iso8601(3)
    token_and_time = "#{SessionToken}:#{timestamp}"
    auth_hash = Base64.strict_encode64 OpenSSL::HMAC.digest('sha256', SharedSecret, token_and_time)
    auth_token = Base64.strict_encode64 "#{SessionToken}:#{auth_hash}"
    request.headers["Authorization"] = "SIF_HMACSHA256 #{auth_token}"
    request.headers["Timestamp"] = timestamp
    request.headers["GeneratorId"] = "prs-ui"
    request.headers["Content-Type"] = "xml"
  end

end
