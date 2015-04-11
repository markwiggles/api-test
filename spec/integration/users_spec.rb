require 'spec_helper'


describe 'test GET tests' do

  before :each do
    # request.env["HTTP_ACCEPT"] = 'application/json'
    host! 'api.example.com'
  end

  context 'test get response' do
    it 'should return success' do
      get '/users', {}, {'Accept' => Mime::JSON}
      response.should be_ok
    end
    it 'should return users from db' do
      get '/users', {}, {'Accept' => Mime::JSON}
      users = json(response.body)
      names = users.collect{ |u| u[:name]}
      names.should include('james') && include('fred')
    end
  end

  context 'test factory users' do

    let!(:john) {User.create(name: 'john', email:'john@live.com')}
    let!(:tim) {User.create(name:'tim', email:'tim@live.com')}

    it 'should return specific users' do
      get '/users?name=john', {}, {'Accept' => Mime::JSON}
      users = json(response.body)
      names = users.collect{ |u| u[:name]}
      names.should include('john')
      refute_includes names, 'tim'
    end

    it 'should return user by id' do
      get "/users/#{tim.id}"
      response.should be_ok
      user_response = json(response.body)
      tim.name.should eq user_response[:name]
    end

    it 'should return user in json' do
      get '/users', {}, {'Accept' => Mime::JSON}
      response.should be_ok
      response.content_type.should eq Mime::JSON
    end
  end

  context 'test POST requests' do

    context 'create user' do

      it 'should create a new user' do
        post '/users',
          {user:
           {name:'zac', email: 'zac@live.com', phone: '99999'}
           }.to_json,
          {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s}

        # puts "LOCATION: #{response.location}"
        # puts "BODY: #{response.body}"
        # puts "STATUS: #{response.status}"
        response.status.should eq 204
        response.content_type.should eq Mime::JSON
        user = json(response.body)
        api_users_url(user[:id]).should eq response.location
      end
    end

  end




end
