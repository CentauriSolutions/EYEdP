# frozen_string_literal: true

class Admin::SettingsController < AdminController
  skip_before_action :set_model
  # GET /admin/settings
  # GET /admin/settings.json
  def index; end

  # PATCH/PUT /admin/settings/1
  # PATCH/PUT /admin/settings/1.json
  def update # rubocop:disable Metrics/MethodLength
    opts = setting_params
    opts[:registration_enabled] = if opts[:registration_enabled].nil?
                                    false
                                  else
                                    true
                                  end
    opts[:expire_after] = opts[:expire_after].to_i.days if opts[:expire_after]
    opts.each do |setting, value|
      Setting.send("#{setting}=", value)
    end
    redirect_to admin_settings_url, notice: 'Settings were successfully updated.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_setting
    @setting = Setting.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def setting_params
    params.fetch(:setting, {}).permit(
      :idp_base,
      :saml_certificate, :saml_key,
      :oidc_signing_key,
      :registration_enabled,
      :logo, :logo_height, :logo_width,
      :home_template, :registered_home_template,
      :expire_after
    )
  end
end
