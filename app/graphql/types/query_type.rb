module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Get all users
    field :users, [Types::UserType], null: false, description: "Get all users"
    def users
      User.all
    end

    # Get a specific user by ID
    field :user, Types::UserType, null: true, description: "Get a user by ID" do
      argument :id, ID, required: true, description: "ID of the user to fetch"
    end
    def user(id:)
      User.find_by(id: id)
    end

    # Search users by name
    field :users_by_name, [Types::UserType], null: false, description: "Search users by name" do
      argument :name, String, required: true, description: "Name to search for"
    end
    def users_by_name(name:)
      User.where("name ILIKE ?", "%#{name}%")
    end
  end
end