require 'rails_helper'

RSpec.describe 'User Queries', type: :graphql do
  describe 'users query' do
    let(:query) do
      <<~GQL
        query {
          users {
            id
            name
            email
            age
          }
        }
      GQL
    end

    context 'when users exist' do
      let!(:users) { create_list(:user, 3) }

      it 'returns all users' do
        result = execute_graphql(query)
        users_data = graphql_data(result)['users']

        expect(users_data).to have_attributes(size: 3)
      end

      it 'returns user attributes correctly' do
        result = execute_graphql(query)
        users_data = graphql_data(result)['users']
        first_user = users_data.first
        db_user = users.find { |u| u.id.to_s == first_user['id'] }

        expect(first_user['name']).to eq(db_user.name)
        expect(first_user['email']).to eq(db_user.email)
        expect(first_user['age']).to eq(db_user.age)
      end
    end

    context 'when no users exist' do
      it 'returns empty array' do
        result = execute_graphql(query)
        users_data = graphql_data(result)['users']

        expect(users_data).to eq([])
      end
    end
  end

  describe 'user query' do
    let(:user) { create(:user) }
    let(:query) do
      <<~GQL
        query($id: ID!) {
          user(id: $id) {
            id
            name
            email
            age
          }
        }
      GQL
    end

    context 'when user exists' do
      it 'returns the specific user' do
        result = execute_graphql(query, variables: { id: user.id })
        user_data = graphql_data(result)['user']

        expect(user_data['id']).to eq(user.id.to_s)
        expect(user_data['name']).to eq(user.name)
        expect(user_data['email']).to eq(user.email)
        expect(user_data['age']).to eq(user.age)
      end
    end

    context 'when user does not exist' do
      it 'returns null' do
        result = execute_graphql(query, variables: { id: 99999 })
        user_data = graphql_data(result)['user']

        expect(user_data).to be_nil
      end
    end
  end

  describe 'usersByName query' do
    let!(:john) { create(:user, name: "John Doe") }
    let!(:jane) { create(:user, name: "Jane Smith") }
    let!(:johnny) { create(:user, name: "Johnny Cash") }

    let(:query) do
      <<~GQL
        query($name: String!) {
          usersByName(name: $name) {
            id
            name
            email
          }
        }
      GQL
    end

    it 'returns users matching the name search' do
      result = execute_graphql(query, variables: { name: "John" })
      users_data = graphql_data(result)['usersByName']

      expect(users_data).to have_attributes(size: 2)
      names = users_data.map { |u| u['name'] }
      expect(names).to include("John Doe", "Johnny Cash")
      expect(names).not_to include("Jane Smith")
    end

    it 'returns empty array when no matches found' do
      result = execute_graphql(query, variables: { name: "Bob" })
      users_data = graphql_data(result)['usersByName']

      expect(users_data).to eq([])
    end
  end
end