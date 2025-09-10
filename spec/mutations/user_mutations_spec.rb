require 'rails_helper'

RSpec.describe 'User Mutations', type: :graphql do
  describe 'createUser mutation' do
    let(:mutation) do
      <<~GQL
        mutation($name: String!, $email: String!, $age: Int) {
          createUser(input: {
            name: $name
            email: $email
            age: $age
          }) {
            user {
              id
              name
              email
              age
            }
            errors
          }
        }
      GQL
    end

    context 'with valid parameters' do
      let(:variables) do
        {
          name: "Test",
          email: "user@test.com",
          age: 25
        }
      end

      it 'creates a new user' do
        expect {
          execute_graphql(mutation, variables: variables)
        }.to change(User, :count).by(1)
      end

      it 'returns the created user' do
        result = execute_graphql(mutation, variables: variables)
        user_data = graphql_data(result)['createUser']['user']

        expect(user_data['name']).to eq("Test")
        expect(user_data['email']).to eq("user@test.com")
        expect(user_data['age']).to eq(25)
        expect(user_data['id']).to be_present
      end
    end

    context 'with invalid parameters' do
      let(:variables) do
        {
          name: "",
          email: "invalid-email",
          age: 30
        }
      end

      it 'does not create a user' do
        expect {
          execute_graphql(mutation, variables: variables)
        }.not_to change(User, :count)
      end

      it 'returns validation errors' do
        result = execute_graphql(mutation, variables: variables)
        mutation_result = graphql_data(result)['createUser']

        expect(mutation_result['user']).to be_nil
        expect(mutation_result['errors']).to include(/Name can't be blank/)
        expect(mutation_result['errors']).to include(/Email is invalid/)
      end
    end

    context 'without age' do
      let(:variables) do
        {
          name: "Jane Doe",
          email: "jane@example.com"
        }
      end

      it 'creates user without age' do
        result = execute_graphql(mutation, variables: variables)
        user_data = graphql_data(result)['createUser']['user']

        expect(user_data['name']).to eq("Jane Doe")
        expect(user_data['email']).to eq("jane@example.com")
        expect(user_data['age']).to be_nil
      end
    end
  end

  describe 'updateUser mutation' do
    let!(:user) { create(:user, name: "Test Name", email: "test@test.com", age: 25) }
    let(:mutation) do
      <<~GQL
        mutation($id: ID!, $name: String, $email: String, $age: Int) {
          updateUser(input: {
            id: $id
            name: $name
            email: $email
            age: $age
          }) {
            user {
              id
              name
              email
              age
            }
            errors
          }
        }
      GQL
    end
  end

  describe 'deleteUser mutation' do
    let!(:user) { create(:user) }
    let(:mutation) do
      <<~GQL
        mutation($id: ID!) {
          deleteUser(input: { id: $id }) {
            success
            errors
          }
        }
      GQL
    end

    context 'when user exists' do
      it 'deletes the user' do
        expect {
          execute_graphql(mutation, variables: { id: user.id })
        }.to change(User, :count).by(-1)
      end

      it 'returns success true' do
        result = execute_graphql(mutation, variables: { id: user.id })
        delete_result = graphql_data(result)['deleteUser']

        expect(delete_result['success']).to be true
        expect(delete_result['errors']).to eq([])
      end
    end

    context 'when user does not exist' do
      it 'returns user not found error' do
        result = execute_graphql(mutation, variables: { id: 99999 })
        delete_result = graphql_data(result)['deleteUser']

        expect(delete_result['success']).to be false
        expect(delete_result['errors']).to include("User not found")
      end

      it 'does not change user count' do
        expect {
          execute_graphql(mutation, variables: { id: 99999 })
        }.not_to change(User, :count)
      end
    end
  end
end