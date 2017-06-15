require 'spec_helper'
require 'fetchers/v2/space_quota_definition_fetcher'

module VCAP::CloudController
  RSpec.describe SpaceQuotaDefinitonFetcher do
    subject(:fetcher) { SpaceQuotaDefinitonFetcher.new }
    describe '#fetch' do
      let!(:organization_a) { VCAP::CloudController::Organization.make }

      context 'when given a user' do
        let!(:organization_b) { VCAP::CloudController::Organization.make }

        let(:user_id) { 'test-user-id' }
        let(:acl_data) { { 'accessControlEntries' => acl_statements } }
        let(:acl_statements) do
          [
            {
              'subject': user_id,
              'action': 'read',
              'resource': "urn:space-quota:/#{organization_a.guid}/*"
            }
          ]
        end

        before do
          stub_request(:get, 'http://acl-service.capi.land/acl').to_return(body: acl_data.to_json)
        end

        it 'only shows space quotas in org A' do
          SpaceQuotaDefinition.make(name: 'space-quota-1', organization: organization_a)
          SpaceQuotaDefinition.make(name: 'space-quota-2', organization: organization_b)

          dataset = fetcher.fetch(user_id, false)
          expect(dataset.all.map(&:name)).to match_array(['space-quota-1'])
        end

        context 'with a single ACE providing access to all orgs' do
          let(:acl_statements) do
            [
              {
                'subject': user_id,
                'action': 'read',
                'resource': 'urn:space-quota:/*'
              }
            ]
          end

          it 'shows all space quotas' do
            SpaceQuotaDefinition.make(name: 'space-quota-1', organization: organization_a)
            SpaceQuotaDefinition.make(name: 'space-quota-2', organization: organization_b)

            dataset = fetcher.fetch(user_id, false)
            expect(dataset.all.map(&:name)).to match_array(['space-quota-1', 'space-quota-2'])
          end
        end

        context 'with multiple ACEs providing access to all orgs' do
          let(:acl_statements) do
            [
              {
                'subject': user_id,
                'action': 'read',
                'resource': "urn:space-quota:/#{organization_a.guid}/*"
              },
              {
                'subject': user_id,
                'action': 'read',
                'resource': "urn:space-quota:/#{organization_b.guid}/*"
              },
            ]
          end

          it 'shows all space quotas' do
            SpaceQuotaDefinition.make(name: 'space-quota-1', organization: organization_a)
            SpaceQuotaDefinition.make(name: 'space-quota-2', organization: organization_b)

            dataset = fetcher.fetch(user_id, false)
            expect(dataset.all.map(&:name)).to match_array(['space-quota-1', 'space-quota-2'])
          end
        end
      end
    end
  end
end
