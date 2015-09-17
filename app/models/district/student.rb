class District::Student < PrsModel
  
  verbose true if Rails.env.development?
  
  get :all, "/districts/:district_id/services/:service_id/students"
  get :find, "/districts/:district_id/services/:service_id/students/:id" #, :has_one => { :consent => District::StudentConsent }
  put :save, "/districts/:district_id/services/:service_id/students/:id"
  post :create, "/districts/:district_id/services/:service_id/students/"
  delete :destroy, "/districts/:district_id/services/:service_id/students/:id"
  get :filters, "/filters;zoneId=:zoneid;contextId=DEFAULT"
  
  before_request do |name, request|
    if name == :filters
      request.headers["Accept"] = "application/xml"
      request.headers["Content-Type"] = "application/xml"
      
      # Convert get params to headers because that's the way PRS likes them.
      for param in %w[districtId authorizedEntityId externalServiceId districtStudentId objectType personnelId]
        request.headers[param] = request.get_params.delete(param.to_sym).to_s if request.get_params[param.to_sym]
      end
    end
  end

  ConsentTypes = [
    "Parent Consent",
    "Institutional Designation",
    "Research Exemption"
  ]

  # def consentEndDate
  #   Date.parse(self.consent.try(:consentEndDate)) rescue nil
  # end
  #
  # def expired?
  #   consentEndDate.today? || consentEndDate.past? if consentEndDate.is_a?(Date)
  # end

end
