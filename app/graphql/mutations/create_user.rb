module Mutations
  class CreateUser < BaseMutation
    description "Create a new user"

    argument :name, String, required: true, description: "user's full name"
    argument :email, String, required: true, description: "user's email"
    argument :age, Int, required: false, description: "user's age"

    # Return type
    field :user, Types::UserType, null: true, description: "new user"
    field :errors, [String], null: false, description: "validation errors"

    def resolve(name:, email:, age: nil)
      user = User.new(name: name, email: email, age: age)
      
      if user.save
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