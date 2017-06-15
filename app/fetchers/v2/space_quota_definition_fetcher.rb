module VCAP::CloudController
  class SpaceQuotaDefinitonFetcher
    def fetch(user_id, admin_override)
      if admin_override
        fetch_full_dataset
      elsif user_id
        fetch_user_visible_dataset(user_id)
      else
        fetch_unauthenticated_dataset
      end
    end

    private

    def fetch_full_dataset
      SpaceQuotaDefinition.dataset
    end

    def fetch_user_visible_dataset(user_id)
      dataset = SpaceQuotaDefinition.dataset
      filters = []
      urns = authz.get_acl('space-quota', 'read', user_id)
      urns.each do |urn|
        _, _, path = urn.split(':')
        _, org_guid, space_quota_guid = path.split('/')

        if space_quota_guid && space_quota_guid != '*'
          filters << [:guid, space_quota_guid]
        else
          if org_guid && org_guid != '*'
            filters << [:organization, VCAP::CloudController::Organization.where(guid: org_guid)]
          end
        end
      end
      filters.empty? ? dataset : dataset.where(Sequel.or(filters))
    end

    def fetch_unauthenticated_dataset
      SpaceQuotaDefinition.dataset.nullify
    end

    def acl_client
      @acl_client ||= VCAP::CloudController::AclServiceClient.new
    end

    def authz
      @authz ||= VCAP::CloudController::Authz.new(acl_client)
    end
  end
end
