module GraphqlHelper
  def execute_graphql(query, variables: {}, context: {})
    RailsCoeSchema.execute(query, variables: variables, context: context)
  end

  # Helper to get data from GraphQL response
  def graphql_data(result)
    result['data']
  end

  # Helper to get errors from GraphQL response
  def graphql_errors(result)
    result['errors']
  end

  # Helper to check if GraphQL query was successful
  def graphql_success?(result)
    result['errors'].nil? || result['errors'].empty?
  end
end

RSpec.configure do |config|
  # Include helper in all specs, not just :graphql type
  config.include GraphqlHelper
end