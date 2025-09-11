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

  describe 'usersByAge query' do
    let!(:user_25_1) { create(:user, age: 25, name: "Alice") }
    let!(:user_25_2) { create(:user, age: 25, name: "Bob") }
    let!(:user_30) { create(:user, age: 30, name: "Charlie") }
    let!(:user_no_age) { create(:user, age: nil, name: "David") }

    let(:query) do
      <<~GQL
        query($age: Int!) {
          usersByAge(age: $age) {
            id
            name
            age
          }
        }
      GQL
    end

    it 'returns users with the specified age' do
      result = execute_graphql(query, variables: { age: 25 })
      users_data = graphql_data(result)['usersByAge']

      expect(users_data).to have_attributes(size: 2)
      names = users_data.map { |u| u['name'] }
      expect(names).to contain_exactly("Alice", "Bob")
      users_data.each do |user|
        expect(user['age']).to eq(25)
      end
    end

    it 'returns empty array when no users have the specified age' do
      result = execute_graphql(query, variables: { age: 99 })
      users_data = graphql_data(result)['usersByAge']

      expect(users_data).to eq([])
    end
  end

  describe 'adultUsers query' do
    let!(:child) { create(:user, age: 16, name: "Child User") }
    let!(:teen) { create(:user, age: 17, name: "Teen User") }
    let!(:adult_18) { create(:user, age: 18, name: "Young Adult") }
    let!(:adult_25) { create(:user, age: 25, name: "Adult User") }
    let!(:adult_no_age) { create(:user, age: nil, name: "No Age User") }

    let(:query) do
      <<~GQL
        query {
          adultUsers {
            id
            name
            age
          }
        }
      GQL
    end

    it 'returns only users aged 18 and above' do
      result = execute_graphql(query)
      users_data = graphql_data(result)['adultUsers']

      expect(users_data).to have_attributes(size: 2)
      names = users_data.map { |u| u['name'] }
      expect(names).to contain_exactly("Young Adult", "Adult User")
      
      users_data.each do |user|
        expect(user['age']).to be >= 18
      end
    end

    it 'does not return users under 18' do
      result = execute_graphql(query)
      users_data = graphql_data(result)['adultUsers']
      
      names = users_data.map { |u| u['name'] }
      expect(names).not_to include("Child User", "Teen User")
    end

    it 'does not return users with nil age' do
      result = execute_graphql(query)
      users_data = graphql_data(result)['adultUsers']
      
      names = users_data.map { |u| u['name'] }
      expect(names).not_to include("No Age User")
    end

    context 'when no adult users exist' do
      before do
        User.destroy_all
        create(:user, age: 16)
        create(:user, age: 17)
      end

      it 'returns empty array' do
        result = execute_graphql(query)
        users_data = graphql_data(result)['adultUsers']

        expect(users_data).to eq([])
      end
    end
  end

  describe 'usersCount query' do
    let(:query) do
      <<~GQL
        query {
          usersCount
        }
      GQL
    end

    context 'when users exist' do
      let!(:users) { create_list(:user, 5) }

      it 'returns the correct count' do
        result = execute_graphql(query)
        count = graphql_data(result)['usersCount']

        expect(count).to eq(5)
      end
    end

    context 'when no users exist' do
      it 'returns zero' do
        result = execute_graphql(query)
        count = graphql_data(result)['usersCount']

        expect(count).to eq(0)
      end
    end
  end

  describe 'multiple queries in one request' do
    let!(:adult_user) { create(:user, age: 25, name: "Adult") }
    let!(:child_user) { create(:user, age: 16, name: "Child") }
    let!(:target_age_user) { create(:user, age: 30, name: "Thirty") }

    let(:query) do
      <<~GQL
        query {
          totalUsers: usersCount
          adults: adultUsers {
            name
            age
          }
          thirtyYearOlds: usersByAge(age: 30) {
            name
            age
          }
        }
      GQL
    end

    it 'handles multiple queries correctly' do
      result = execute_graphql(query)
      data = graphql_data(result)

      expect(data['totalUsers']).to eq(3)
      expect(data['adults']).to have_attributes(size: 2)
      expect(data['thirtyYearOlds']).to have_attributes(size: 1)
      expect(data['thirtyYearOlds'].first['name']).to eq("Thirty")
    end
  end
end