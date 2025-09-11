class UserProfileService
  include HTTParty
  
  base_uri 'https://jsonplaceholder.typicode.com'
  
  def initialize(user_id = nil)
    @user_id = user_id
  end
  
  def fetch_profile
    response = self.class.get("/users/#{@user_id}")
    
    if response.success?
      {
        success: true,
        data: parse_user_data(response.parsed_response)
      }
    else
      {
        success: false,
        error: "Failed to fetch user profile: #{response.code} #{response.message}",
        data: nil
      }
    end
  rescue StandardError => e
    {
      success: false,
      error: "Network error: #{e.message}",
      data: nil
    }
  end
  
  # Get all posts by user
  def fetch_user_posts
    response = self.class.get("/users/#{@user_id}/posts")
    
    if response.success?
      {
        success: true,
        data: response.parsed_response.map { |post| parse_post_data(post) }
      }
    else
      {
        success: false,
        error: "Failed to fetch user posts: #{response.code} #{response.message}",
        data: []
      }
    end
  rescue StandardError => e
    {
      success: false,
      error: "Network error: #{e.message}",
      data: []
    }
  end
  
  def fetch_post_with_comments(post_id)
    post_response = self.class.get("/posts/#{post_id}")
    comments_response = self.class.get("/posts/#{post_id}/comments")
    
    if post_response.success? && comments_response.success?
      {
        success: true,
        data: {
          post: parse_post_data(post_response.parsed_response),
          comments: comments_response.parsed_response.map { |comment| parse_comment_data(comment) }
        }
      }
    else
      {
        success: false,
        error: "Failed to fetch post or comments",
        data: nil
      }
    end
  rescue StandardError => e
    {
      success: false,
      error: "Network error: #{e.message}",
      data: nil
    }
  end
  
  def self.get_user_profile(user_id)
    new(user_id).fetch_profile
  end
  
  private
  
  def parse_user_data(user_data)
    {
      id: user_data['id'],
      name: user_data['name'],
      username: user_data['username'],
      email: user_data['email'],
      phone: user_data['phone'],
      website: user_data['website'],
      company: user_data.dig('company', 'name'),
      address: format_address(user_data['address'])
    }
  end
  
  def parse_post_data(post_data)
    {
      id: post_data['id'],
      title: post_data['title'],
      body: post_data['body'],
      user_id: post_data['userId']
    }
  end
  
  def parse_comment_data(comment_data)
    {
      id: comment_data['id'],
      name: comment_data['name'],
      email: comment_data['email'],
      body: comment_data['body'],
      post_id: comment_data['postId']
    }
  end
  
  def format_address(address_data)
    return nil unless address_data
    
    "#{address_data['street']}, #{address_data['city']}, #{address_data['zipcode']}"
  end
end