require 'spec_helper'

module VCAP::CloudController
  RSpec.describe SpaceQuotaDefinitionAccess, type: :access do
    subject(:access) { SpaceQuotaDefinitionAccess.new(Security::AccessContext.new) }
    let(:user) { VCAP::CloudController::User.make }
    let(:org) { Organization.make }
    let(:scopes) { nil }
    let(:space) { Space.make(organization: org) }
    let(:object) { VCAP::CloudController::SpaceQuotaDefinition.make(organization: org) }
    let(:acl_data) { { 'accessControlEntries' => acl_statements } }
    let(:acl_statements) { [] }

    before do
      set_current_user(user, scopes: scopes, user_id: 'test-user-id')
      stub_request(:get, "http://acl-service.capi.land/acl?resource=urn:space-quota:/#{org.guid}/*").to_return(body: acl_data.to_json)
    end

    it_behaves_like :admin_full_access
    it_behaves_like :admin_read_only_access
    it_behaves_like :global_auditor_access

    context 'organization manager' do
      let(:acl_statements) do
        [
          {
            'subject': 'test-user-id',
            'action': 'create',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'read',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'update',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'delete',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'read_for_update',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
        ]
      end

      it_behaves_like :full_access

      context 'when the organization is suspended' do
        let(:org) { Organization.make(status: 'suspended') }

        it_behaves_like :read_only_access
      end
    end

    context 'when you have no access' do
      let(:acl_statements) { [] }

      it_behaves_like :no_access
    end

    context 'a user that isnt logged in (defensive)' do
      let(:user) { nil }

      it_behaves_like :no_access
    end

    context 'any user using client without cloud_controller.write' do
      let(:scopes) { ['cloud_controller.read'] }
      let(:acl_statements) do
        [
          {
            'subject': 'test-user-id',
            'action': 'create',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'read',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'update',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'delete',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'read_for_update',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
        ]
      end

      it_behaves_like :read_only_access
    end

    context 'any user using client without cloud_controller.read' do
      let(:scopes) { [] }
      let(:acl_statements) do
        [
          {
            'subject': 'test-user-id',
            'action': 'create',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'read',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'update',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'delete',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
          {
            'subject': 'test-user-id',
            'action': 'read_for_update',
            'resource': "urn:space-quota:/#{org.guid}/*"
          },
        ]
      end

      it_behaves_like :no_access
    end
  end
end
