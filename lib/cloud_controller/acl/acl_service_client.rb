module VCAP::CloudController
  class AclServiceClient
    def get_acl_for_resource(resource_urn)
      response = http_client.get("https://acl-service.cfapps.io/acl?resource=#{resource_urn}")
      JSON.parse(response.body).deep_symbolize_keys.fetch(:accessControlEntries, [])
    end

    def get_all_acls
      response = http_client.get("https://acl-service.cfapps.io/acl")
      JSON.parse(response.body).deep_symbolize_keys.fetch(:accessControlEntries, [])
    end

    private

    def http_client
      @http_client ||= HTTPClient.new
    end
  end
end
