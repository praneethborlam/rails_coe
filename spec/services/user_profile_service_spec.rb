require 'rails_helper'

RSpec.describe UserProfileService do
  let(:user_id) { 1 }
  let(:service) { described_class.new(user_id) }

  describe '#fetch_profile', :vcr do
    context 'when user exists' do
      it 'returns user profile data successfully' do
        result = service.fetch_profile
        
        expect(result[:success]).to be true
        expect(result[:data]).to be_a(Hash)
        expect(result[:data][:id]).to eq(1)
        expect(result[:data][:name]).to be_present
        expect(result[:data][:email]).to be_present
        expect(result[:data][:username]).to be_present
      end
      
      it 'parses user data correctly' do
        result = service.fetch_profile
        user_data = result[:data]
        
        expect(user_data[:name]).to eq("Leanne Graham")
        expect(user_data[:username]).to eq("Bret")
        expect(user_data[:email]).to eq("Sincere@april.biz")
        expect(user_data[:phone]).to eq("1-770-736-8031 x56442")
        expect(user_data[:company]).to eq("Romaguera-Crona")
        expect(user_data[:address]).to include("Kulas Light")
      end
      
      it 'includes all expected fields' do
        result = service.fetch_profile
        user_data = result[:data]
        
        expected_fields = [:id, :name, :username, :email, :phone, :website, :company, :address]
        expect(user_data.keys).to include(*expected_fields)
      end
    end
    
    context 'when user does not exist' do
      let(:user_id) { 999 }
      
      it 'returns error for non-existent user', :vcr do
        result = service.fetch_profile
        
        expect(result[:success]).to be false
        expect(result[:error]).to include("Failed to fetch user profile")
        expect(result[:data]).to be_nil
      end
    end
  end

  describe '#fetch_user_posts', :vcr do
    context 'when user has posts' do
      it 'returns user posts successfully' do
        result = service.fetch_user_posts
        
        expect(result[:success]).to be true
        expect(result[:data]).to be_an(Array)
        expect(result[:data]).not_to be_empty
      end
      
      it 'parses post data correctly' do
        result = service.fetch_user_posts
        first_post = result[:data].first
        
        expect(first_post[:id]).to be_present
        expect(first_post[:title]).to be_present
        expect(first_post[:body]).to be_present
        expect(first_post[:user_id]).to eq(user_id)
      end
      
      it 'returns multiple posts' do
        result = service.fetch_user_posts
        
        expect(result[:data].length).to be > 1
        result[:data].each do |post|
          expect(post[:user_id]).to eq(user_id)
        end
      end
    end
  end

  describe '#fetch_post_with_comments', :vcr do
    let(:post_id) { 1 }
    
    context 'when post exists' do
      it 'returns post with comments successfully' do
        result = service.fetch_post_with_comments(post_id)
        
        expect(result[:success]).to be true
        expect(result[:data]).to be_a(Hash)
        expect(result[:data][:post]).to be_present
        expect(result[:data][:comments]).to be_an(Array)
      end
      
      it 'parses post data correctly' do
        result = service.fetch_post_with_comments(post_id)
        post_data = result[:data][:post]
        
        expect(post_data[:id]).to eq(1)
        expect(post_data[:title]).to be_present
        expect(post_data[:body]).to be_present
        expect(post_data[:user_id]).to be_present
      end
      
      it 'parses comments data correctly' do
        result = service.fetch_post_with_comments(post_id)
        comments = result[:data][:comments]
        
        expect(comments).not_to be_empty
        first_comment = comments.first
        expect(first_comment[:id]).to be_present
        expect(first_comment[:name]).to be_present
        expect(first_comment[:email]).to be_present
        expect(first_comment[:body]).to be_present
        expect(first_comment[:post_id]).to eq(post_id)
      end
    end
    
    context 'when post does not exist' do
      let(:post_id) { 999 }
      
      it 'returns error for non-existent post', :vcr do
        result = service.fetch_post_with_comments(post_id)
        
        expect(result[:success]).to be false
        expect(result[:error]).to include("Failed to fetch post or comments")
        expect(result[:data]).to be_nil
      end
    end
  end

  describe '.get_user_profile', :vcr do
    it 'works as a class method' do
      result = described_class.get_user_profile(user_id)
      
      expect(result[:success]).to be true
      expect(result[:data][:id]).to eq(user_id)
    end
  end

  describe 'error handling' do
    before do
      # Stub network failure
      allow(described_class).to receive(:get).and_raise(SocketError.new("Connection failed"))
    end
    
    it 'handles network errors gracefully in fetch_profile' do
      result = service.fetch_profile
      
      expect(result[:success]).to be false
      expect(result[:error]).to include("Network error: Connection failed")
      expect(result[:data]).to be_nil
    end
    
    it 'handles network errors gracefully in fetch_user_posts' do
      result = service.fetch_user_posts
      
      expect(result[:success]).to be false
      expect(result[:error]).to include("Network error: Connection failed")
      expect(result[:data]).to eq([])
    end
    
    it 'handles network errors gracefully in fetch_post_with_comments' do
      result = service.fetch_post_with_comments(1)
      
      expect(result[:success]).to be false
      expect(result[:error]).to include("Network error: Connection failed")
      expect(result[:data]).to be_nil
    end
  end
end