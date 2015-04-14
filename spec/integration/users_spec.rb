require 'spec_helper'


describe 'test http requests' do

  before :each do
    # request.env["HTTP_ACCEPT"] = 'application/json'
    host! 'api.example.com'
  end

  context 'GET responses' do
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


  context 'POST requests' do

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

    it 'should create a new user' do
      post '/users',
        {user:
         {name:'zac', email: 'zac@live.com', phone: '99999'}
         }.to_json,
        {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s}

      response.status.should eq 201
      response.content_type.should eq Mime::JSON
      user = json(response.body)
      api_users_url(user[:id]).should eq response.location
    end

    it 'should not create user with no name' do
      post '/users',
        {user: {name: ''}}.to_json,
        {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s}

      response.status.should eq 422
    end
  end


  context 'PATCH requests' do

    let(:user) {User.create(name:'test', email:'test@test.com')}

    it 'should update user name' do
      patch "/users/#{user.id}",
        {user:{name:'test2'}}.to_json,
        {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s}

      response.status.should eq 200
      user.reload.name.should eq 'test2'
    end

    it 'should be unsuccessful update' do
      patch "/users/#{user.id}",
        {user:{name:''}}.to_json,
        {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s}

      response.status.should eq 422
    end
  end

  context 'DESTROY request' do

    let(:user) {User.create(name: 'test')}

    it 'should delete user' do
      delete "/users/#{user.id}"
      response.status.should eq 204
    end
  end

  context 'basic AUTH', :focus do

    let(:user){User.create!(name:'foo', password: 'secret')}

    it 'should validate username and password' do
      get '/users', {},
        {'Authorization' => encode_credentials(user.name, user.password),'Accept' => Mime::JSON}
      response.status.should eq 200
    end

    it 'should not validate' do
      get '/users', {}, {'Accept' => Mime::JSON}
      response.status.should eq 401
    end

  end
end

