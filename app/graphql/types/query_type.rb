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

    # RESOLVER: Get users by age
    field :users_by_age, [Types::UserType], null: false, description: "Get users by specific age" do
      argument :age, Int, required: true, description: "Age to filter by"
    end
    def users_by_age(age:)
      User.where(age: age)
    end

    # RESOLVER: Get adult users (age >= 18)
    field :adult_users, [Types::UserType], null: false, description: "Get all adult users (age >= 18)"
    def adult_users
      User.where("age >= ?", 18)
    end

    # RESOLVER: Count total users
    field :users_count, Int, null: false, description: "Get total number of users"
    def users_count
      User.count
    end
  end
end