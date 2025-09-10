module Mutations
  class DeleteUser < BaseMutation
    description "Delete a user"

    argument :id, ID, required: true, description: "ID of the user to delete"

    # Return type
    field :success, Boolean, null: false, description: "deletion was successful"
    field :errors, [String], null: false, description: "validation errors"

    def resolve(id:)
      user = User.find_by(id: id)
      
      return { success: false, errors: ["User not found"] } unless user

      if user.destroy
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
          errors: user.errors.full_messages
        }
      end
    end
  end
end