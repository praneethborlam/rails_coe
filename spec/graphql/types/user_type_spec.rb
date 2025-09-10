require 'rails_helper'

RSpec.describe Types::UserType, type: :graphql do
  let(:user) { create(:user) }
  let(:fields) { Types::UserType.fields }

  describe 'fields' do
    it 'has the expected fields' do
      expected_fields = %w[id name email age createdAt updatedAt]
      expect(fields.keys).to match_array(expected_fields)
    end
  end

  describe 'field resolvers' do
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

    it 'resolves all fields correctly' do
      result = execute_graphql(query, variables: { id: user.id })
      user_data = graphql_data(result)['user']

      expect(user_data['id']).to eq(user.id.to_s)
      expect(user_data['name']).to eq(user.name)
      expect(user_data['email']).to eq(user.email)
      expect(user_data['age']).to eq(user.age)
    end
  end
end