module VCAP::CloudController
  class SpaceQuotaDefinitionAccess < BaseAccess
    def create?(space_quota_definition, params=nil)
      return true if admin_user?
      return false if space_quota_definition.organization.suspended?

      authz.can_do?("urn:space-quota:/#{space_quota_definition.organization.guid}/*", 'create', context.user_id)
    end

    def read_for_update?(space_quota_definition, params=nil)
      return true if admin_user?
      return false if space_quota_definition.organization.suspended?

      authz.can_do?("urn:space-quota:/#{space_quota_definition.organization.guid}/*", 'read_for_update', context.user_id)
    end

    def update?(space_quota_definition, params=nil)
      return true if admin_user?
      return false if space_quota_definition.organization.suspended?

      authz.can_do?("urn:space-quota:/#{space_quota_definition.organization.guid}/*", 'update', context.user_id)
    end

    def delete?(space_quota_definition, params=nil)
      return true if admin_user?
      return false if space_quota_definition.organization.suspended?

      authz.can_do?("urn:space-quota:/#{space_quota_definition.organization.guid}/*", 'delete', context.user_id)
    end

    def read?(space_quota_definition, *_)
      return true if context.admin_override

      authz.can_do?("urn:space-quota:/#{space_quota_definition.organization.guid}/*", 'read', context.user_id)
    end

    private

    def acl_client
      @acl_client ||= VCAP::CloudController::AclServiceClient.new
    end

    def authz
      @authz ||= VCAP::CloudController::Authz.new(acl_client)
    end
  end
end
