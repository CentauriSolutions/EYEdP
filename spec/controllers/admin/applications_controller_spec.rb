# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ApplicationsController, type: :controller do
  let(:user) { User.create!(username: 'user', email: 'user@localhost', password: 'test1234') }
  let(:group) { Group.create!(name: 'administrators', admin: true) }
  let(:admin) do
    user = User.create!(username: 'admin', email: 'admin@localhost', password: 'test1234')
    user.groups << group
    user
  end
  let(:app) do
    Application.create!(
      name: 'https://test.example.com', redirect_uri: 'https://test.example.com'
    )
  end

  describe 'Application' do
    context 'signed in manager' do
      let(:manager_group) { Group.create!(name: 'managers', manager: true) }
      let(:manager) do
        user = User.create!(username: 'manager', email: 'manager@localhost', password: 'test1234')
        user.groups << manager_group
        user
      end

      before do
        sign_in(manager)
      end

      it 'Shows the index page' do
        expect { get :index }.to raise_error(ActionController::RoutingError)
      end
    end

    context 'signed in operator' do
      let(:operator_group) { Group.create!(name: 'operators', operator: true) }
      let(:operator) do
        user = User.create!(username: 'operator', email: 'operator@localhost', password: 'test1234')
        user.groups << operator_group
        user
      end

      before do
        sign_in(operator)
      end

      it 'Shows the index page' do
        get :index
        expect(response.status).to eq(200)
      end
    end

    context 'signed in admin' do
      before do
        sign_in(admin)
      end

      it 'Shows the index page' do
        get :index
        expect(response.status).to eq(200)
      end

      context 'Edit' do
        it 'can update the display_url' do
          expect(app.display_url).to be nil
          post(:update, params: { id: app.id, application: { display_url: 'test.com' } })
          app.reload
          expect(app.display_url).to eq('test.com')
        end
      end
    end

    context 'signed in user' do
      before do
        sign_in(user)
      end
      it 'returns 404 code' do
        expect { get :index }.to raise_error(ActionController::RoutingError)
      end
    end

    context 'signed out user' do
      it 'returns 404 code' do
        expect { get :index }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
