require 'spec_helper'

module VCAP::CloudController
  RSpec.describe Authz do
    subject(:authz) { Authz.new(acl_client) }

    let(:acl_client) { instance_double(AclServiceClient) }

    describe '#can_do?' do
      let(:app_model) { VCAP::CloudController::AppModel.make }
      let(:app_guid) { app_model.guid }
      let(:space_guid) { app_model.space.guid }
      let(:org_guid) { app_model.space.organization.guid }
      let(:requested_urn) { "urn:task:#{org_guid}/#{space_guid}/#{app_guid}" }

      let(:acl_response) do
        [
          { subject: 'user-guid', action: 'action1' },
          { subject: 'other-user-guid', action: 'action2' },
        ]
      end

      before do
        allow(acl_client).to receive(:get_acl_for_resource).with(requested_urn).and_return(acl_response)
      end

      it 'can check for wildcard rule' do
        expect(authz.can_do?(requested_urn, 'action1', 'user-guid')).to eq(true)
        expect(authz.can_do?(requested_urn, 'action2', 'other-user-guid')).to eq(true)
        expect(authz.can_do?(requested_urn, 'action3', 'user-guid')).to eq(false)
        expect(authz.can_do?(requested_urn, 'action1', 'fake-user-guid')).to eq(false)
      end
    end

    describe '#get_app_filter_messages' do
      let!(:org1) { VCAP::CloudController::Organization.make }
      let!(:space1) { VCAP::CloudController::Space.make(organization: org1) }
      let!(:app1) { VCAP::CloudController::AppModel.make(space: space1) }
      let!(:app2) { VCAP::CloudController::AppModel.make(space: space1) }

      let!(:space2) { VCAP::CloudController::Space.make(organization: org1) }
      let!(:app3) { VCAP::CloudController::AppModel.make(space: space2) }

      let!(:org2) { VCAP::CloudController::Organization.make }
      let!(:space3) { VCAP::CloudController::Space.make(organization: org2) }
      let!(:app4) { VCAP::CloudController::AppModel.make(space: space3) }

      before do
        allow(acl_client).to receive(:get_all_acls).and_return(acl_response)
      end

      context 'when fetching all apps' do
        let(:acl_response) do
          [
            { subject: 'user-guid', action: 'action1', resource: 'urn:app:/*' },
          ]
        end

        it 'fetches the right app models' do
          expect(authz.get_app_filter_messages(:app, 'action1', 'user-guid')).to match_array([
            Authz::TranslateURNtoCCResource::TaskFilterMessage.new
          ])
        end
      end

      context 'when fetching all apps in an org' do
        let(:acl_response) do
          [
            { subject: 'user-guid', action: 'action1', resource: "urn:app:/#{org1.guid}/*" },
            { subject: 'user-guid', action: 'action2', resource: "urn:app:/#{org2.guid}/*" },
          ]
        end

        it 'fetches the right app models' do
          expect(authz.get_app_filter_messages(:app, 'action1', 'user-guid')).to match_array([
            Authz::TranslateURNtoCCResource::TaskFilterMessage.new(organization_guids: org1.guid)
          ])
        end
      end

      context 'when fetching all apps in a space' do
        let(:acl_response) do
          [
            { subject: 'user-guid', resource: "urn:app:/#{org1.guid}/#{space1.guid}/*", action: 'action1' },
            { subject: 'user-guid', resource: "urn:app:/#{org1.guid}/#{space2.guid}/*", action: 'action2' },
          ]
        end

        it 'fetches the right app models' do
          expect(authz.get_app_filter_messages(:app, 'action1', 'user-guid')).to match_array([
            Authz::TranslateURNtoCCResource::TaskFilterMessage.new(
              space_guids: space1.guid,
            )
          ])
        end
      end

      context 'when fetching a specific app' do
        let(:acl_response) do
          [
            { subject: 'user-guid', resource: "urn:app:/#{org1.guid}/#{space1.guid}/#{app1.guid}", action: 'action1' },
            { subject: 'user-guid', resource: "urn:app:/#{org1.guid}/#{space1.guid}/#{app2.guid}", action: 'action2' },
          ]
        end

        it 'fetches the right app models' do
          expect(authz.get_app_filter_messages(:app, 'action1', 'user-guid')).to match_array([
            Authz::TranslateURNtoCCResource::TaskFilterMessage.new(
              app_guids: app1.guid,
            )
          ])
        end
      end

      context 'when given overlapping ACEs' do
        let(:acl_response) do
          [
            { subject: 'user-guid', resource: 'urn:app:/*', action: 'action1' },
            { subject: 'user-guid', resource: "urn:app:/#{org1.guid}/*", action: 'action1' },
          ]
        end

        it 'generates the correct AppFilterMessages' do
          expect(authz.get_app_filter_messages(:app, 'action1', 'user-guid')).to match_array([
            Authz::TranslateURNtoCCResource::TaskFilterMessage.new,
            Authz::TranslateURNtoCCResource::TaskFilterMessage.new(organization_guids: org1.guid),
          ])
        end
      end

      context 'when no ACEs match the resource_type' do
        let(:acl_response) do
          [
            { subject: 'user-guid', resource: 'urn:foobar:/*', action: 'action1' },
          ]
        end

        it 'does not generate AppFilterMessages for those ACEs' do
          expect(authz.get_app_filter_messages(:app, 'action1', 'user-guid')).to match_array([])
        end
      end

      context 'when no ACEs match the subject' do
        let(:acl_response) do
          [
            { subject: 'other-user-guid', resource: 'urn:app:/*', action: 'action1' },
          ]
        end

        it 'does not generate AppFilterMessages for those ACEs' do
          expect(authz.get_app_filter_messages(:app, 'action1', 'user-guid')).to match_array([])
        end
      end

      context 'when no ACEs match the action' do
        let(:acl_response) do
          [
            { subject: 'user-guid', resource: 'urn:app:/*', action: 'action2' },
          ]
        end

        it 'does not generate AppFilterMessages for those ACEs' do
          expect(authz.get_app_filter_messages(:app, 'action1', 'user-guid')).to match_array([])
        end
      end
    end
  end
end
