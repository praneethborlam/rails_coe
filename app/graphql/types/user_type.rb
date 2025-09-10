module Types
  class UserType < Types::BaseObject
    description "A user in the system"

    field :id, ID, null: false, description: "user's unique id"
    field :name, String, null: true, description: "user's full name"
    field :email, String, null: true, description: "user's email"
    field :age, Int, null: true, description: "user's age"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the user was created"
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the user was last updated"
  end
end