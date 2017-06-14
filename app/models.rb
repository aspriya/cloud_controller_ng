require 'models/runtime/space'

require 'models/v3/persistence/app_model'
require 'models/v3/persistence/build_model'
require 'models/v3/persistence/route_mapping_model'
require 'models/v3/persistence/package_model'
require 'models/v3/persistence/droplet_model'
require 'models/v3/persistence/buildpack_lifecycle_data_model'
require 'models/v3/persistence/docker_lifecycle_data_model'
require 'models/v3/persistence/task_model'
require 'models/v3/persistence/isolation_segment_model'
require 'models/v3/persistence/job_model'

require 'models/runtime/security_group'
require 'models/runtime/security_groups_space'
require 'models/runtime/staging_security_groups_space'
require 'models/runtime/app_usage_event'
require 'models/runtime/auto_detection_buildpack'
require 'models/runtime/app_event'
require 'models/runtime/process_model'
require 'models/runtime/buildpack'
require 'models/runtime/buildpack_bits_delete'
require 'models/runtime/domain'
require 'models/runtime/shared_domain'
require 'models/runtime/space_reserved_route_ports'
require 'models/runtime/private_domain'
require 'models/runtime/event'
require 'models/runtime/feature_flag'
require 'models/runtime/environment_variable_group'
require 'models/runtime/custom_buildpack'
require 'models/runtime/organization'
require 'models/runtime/organization_routes'
require 'models/runtime/organization_reserved_route_ports'
require 'models/runtime/quota_definition'
require 'models/runtime/quota_constraints/max_private_domains_policy'
require 'models/runtime/quota_constraints/max_routes_policy'
require 'models/runtime/quota_constraints/max_reserved_route_ports_policy'
require 'models/runtime/quota_constraints/max_service_instance_policy'
require 'models/runtime/quota_constraints/paid_service_instance_policy'
require 'models/runtime/quota_constraints/max_service_keys_policy'
require 'models/runtime/constraints/max_disk_quota_policy'
require 'models/runtime/constraints/min_disk_quota_policy'
require 'models/runtime/constraints/metadata_policy'
require 'models/runtime/constraints/max_memory_policy'
require 'models/runtime/constraints/max_instance_memory_policy'
require 'models/runtime/constraints/min_memory_policy'
require 'models/runtime/constraints/ports_policy'
require 'models/runtime/constraints/instances_policy'
require 'models/runtime/constraints/max_app_instances_policy'
require 'models/runtime/constraints/max_app_tasks_policy'
require 'models/runtime/constraints/health_check_policy'
require 'models/runtime/constraints/docker_policy'
require 'models/runtime/constraints/diego_to_dea_policy'
require 'models/runtime/route'
require 'models/runtime/space_routes'
require 'models/runtime/space_quota_definition'
require 'models/runtime/stack'
require 'models/runtime/user'
require 'models/runtime/locking'
require 'models/runtime/clock_job'
require 'models/runtime/system_audit_user'

require 'models/services/service'
require 'models/services/service_binding'
require 'models/services/route_binding'
require 'models/services/service_dashboard_client'
require 'models/services/service_instance'
require 'models/services/managed_service_instance'
require 'models/services/service_instance_operation'
require 'models/services/user_provided_service_instance'
require 'models/services/service_broker'
require 'models/services/service_plan'
require 'models/services/service_plan_visibility'
require 'models/services/service_usage_event'
require 'models/services/service_key'
require 'models/services/route_binding'

require 'models/request_count'
require 'models/orphaned_blob'
