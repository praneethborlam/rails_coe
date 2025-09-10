module Mutations
  class UpdateUser < BaseMutation
    description "Update an existing user"

    argument :id, ID, required: true, description: "ID of the user to update"
    argument :name, String, required: false, description: "user's  full name"
    argument :email, String, required: false, description: "user's email"
    argument :age, Int, required: false, description: "user's age"

    # Return type
    field :user, Types::UserType, null: true, description: "updated user"
    field :errors, [String], null: false, description: "validation errors"

    def resolve(id:, **attributes)
      user = User.find_by(id: id)
      
      return { user: nil, errors: ["User not found"] } unless user

      if user.update(attributes.compact)
        {
          user: user,
          errors: []
        }
      else
        {
          user: nil,
          errors: user.errors.full_messages
        }
      end
    end
  end
end