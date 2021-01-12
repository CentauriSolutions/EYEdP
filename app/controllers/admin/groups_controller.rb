# frozen_string_literal: true

class Admin::GroupsController < AdminController
  def email
    @group = Group.find(params[:group_id])
    render :email, layout: nil
  end

  def update_custom_attributes # rubocop:disable Metrics/MethodLength
    @model = Group.find(params[:group_id])
    custom_groupdata_params.each do |name, value|
      custom_type = CustomGroupDataType.where(name: name).first
      custom_datum = CustomGroupdatum.where(
        group_id: @model.id,
        custom_group_data_type: custom_type
      ).first_or_initialize
      begin
        custom_datum.value = value
        custom_datum.save
      rescue RuntimeError
        flash[:error] = 'Failed to update group data, invalid value'
      end
    end
    redirect_to [:edit, :admin, @model]
  end

  private

  def whitelist_attributes
    %w[name parent requires_2fa permissions]
  end

  def new_fields
    %w[name description requires_2fa]
  end

  def show_whitelist_attributes
    %w[name description parent requires_2fa permissions]
  end

  def form_relations
    {
      parent: {
        type: :select,
        options: { prompt: 'No Parent' },
        finder: lambda {
                  helpers.options_from_collection_for_select(Group.all, :id, :name, @model.parent.try(:id))
                }
      }
    }
  end

  def includes
    %i[parent permissions]
  end

  def model
    Group
  end

  def model_params
    p = params.require(:group).permit(
      :name, :description, :parent, :welcome_email, :requires_2fa,
      permission_ids: []
    )
    p[:permission_ids] ||= []
    p[:parent_id] = p.delete(:parent) if p[:parent]
    p
  end

  def sort_whitelist
    %w[created_at name]
  end

  def custom_groupdata_params
    params.require(:custom_data).permit!
  end
end
