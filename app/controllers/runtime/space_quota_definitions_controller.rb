require 'fetchers/v2/space_quota_definition_fetcher'

module VCAP::CloudController
  class SpaceQuotaDefinitionsController < RestController::ModelController
    define_attributes do
      attribute :name,                       String
      attribute :non_basic_services_allowed, Message::Boolean
      attribute :total_services,             Integer
      attribute :total_service_keys,         Integer, default: -1
      attribute :total_routes,               Integer
      attribute :memory_limit,               Integer
      attribute :instance_memory_limit,      Integer, default: nil
      attribute :app_instance_limit,         Integer, default: nil
      attribute :app_task_limit,             Integer, default: 5
      attribute :total_reserved_route_ports, Integer, default: -1

      to_one :organization
      to_many :spaces, exclude_in: [:create, :update]
    end

    def self.translate_validation_exception(e, attributes)
      name_errors = e.errors.on([:organization_id, :name])
      if name_errors && name_errors.include?(:unique)
        CloudController::Errors::ApiError.new_from_details('SpaceQuotaDefinitionNameTaken', attributes['name'])
      else
        CloudController::Errors::ApiError.new_from_details('SpaceQuotaDefinitionInvalid', e.errors.full_messages)
      end
    end

    def delete(guid)
      do_delete(find_guid_and_validate_access(:delete, guid))
    end

    define_messages
    define_routes

    private

    def enumerate_dataset
      qp = self.class.query_parameters
      visible_objects = SpaceQuotaDefinitonFetcher.new.fetch(@access_context.user_id, @access_context.admin_override)
      filtered_objects = filter_dataset(visible_objects)
      get_filtered_dataset_for_enumeration(model, filtered_objects, qp, @opts)
    end
  end
end
