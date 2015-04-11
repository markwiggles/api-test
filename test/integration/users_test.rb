require 'test_helper'



class ListingUsersTest < ActionDispatch::IntegrationTest

  setup { host! 'api.example.com'}

  test 'return list of users' do

    get '/users'
    assert_equal 200,response.status
    refute_empty response.body
  end
end
