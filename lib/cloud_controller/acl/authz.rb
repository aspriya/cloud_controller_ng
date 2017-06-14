module VCAP::CloudController
  class Authz
    def initialize(acl_service_client)
      @acl_service_client = acl_service_client
    end

    def can_do?(resource_urn, action, subject)
      @acl_service_client.get_acl_for_resource(resource_urn).any? do |ace|
        ace[:subject] == subject && ace[:action] == action
      end
    end

    def get_app_filter_messages(resource_type, action, subject)
      urns = @acl_service_client.get_all_acls
               .select { |ace| ace[:subject] == subject && ace[:action] == action && ace[:resource].starts_with?("urn:#{resource_type}") }
               .map { |rule| rule[:resource] }

      urns.map {|urn| TranslateURNtoCCResource.new.from_urn(urn) }
    end

    class TranslateURNtoCCResource
      class TaskFilterMessage < OpenStruct
        def requested?(key)
          self[key].present?
        end
      end

      def from_urn(urn)
        _, _, path = urn.split(':', 3)

        _, org_guid, space_guid, app_guid = path.split('/')
        filter_message = TaskFilterMessage.new
        if app_guid && app_guid != '*'
          filter_message.app_guids = app_guid
        else
          if space_guid && space_guid != '*'
            filter_message.space_guids = space_guid
          else
            if org_guid != '*'
              filter_message.organization_guids = org_guid
            end
          end
        end
        filter_message
      end
    end
  end
end
