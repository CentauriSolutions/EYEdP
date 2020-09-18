# frozen_string_literal: true

class Admin::SamlServiceProvidersController < AdminController
  # def new
  #   binding.pry
  #   super
  # end

  private

  def model_attributes
    %w[name display_url issuer_or_entity_id metadata_url fingerprint response_hosts]
  end

  def new_fields
    %w[name display_url issuer_or_entity_id metadata_url fingerprint response_hosts]
  end

  def model
    SamlServiceProvider
  end

  def model_params
    p = params
        .require(:saml_service_provider)
        .permit(
          :name, :display_url,
          :issuer_or_entity_id, :metadata_url,
          :fingerprint, :response_hosts
        )
    p[:response_hosts] = p[:response_hosts].split(/ +/) if p[:response_hosts]
    p
  end
end
