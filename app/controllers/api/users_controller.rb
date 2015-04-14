module API
  class UsersController < ApplicationController

    before_action :authenticate

    def index
      # users = User.all
      users = User.where(archived: false)
      if name = params[:name]
        users = users.where(name: name)
      end
      # respond_to do |format|
      # format.json {render json: users, status: 200}
      # format.xml {render xml: users, status: 200}
      # end
      render json: users, status: 200
    end

    def show
      # user = User.find(params[:id])
      user = User.find_unarchived(params[:id])
      render json: user, status: 200
    end

    def create
      user = User.new(user_params)
      if user.save
        render json: user, status: 201, location: api_users_url(user.id)
        # render nothing: true, status: 204, location: user
      else
        render json: user.errors, status: 422
      end
    end

    def update
      user = User.find(params[:id])
      if user.update(user_params)
        render json: user, status: 200
      else
        render json: user.errors, status: 422
      end
    end

    def destroy
      # # destroy
      # user = User.find(params[:id])
      # user.destroy
      # head 204

      # archive
      user = User.find_unarchived(params[:id])
      user.archive
      head 204
    end

    protected

    def authenticate
      authenticate_basic_auth || render_unauthorised
    end


    def authenticate_basic_auth
      authenticate_with_http_basic do |name, password|
        User.authenticate(name, password)
      end
    end

    def render_unauthorised
      self.headers['WWW-Authenticate'] = 'Basic Realm="Episodes"'

      respond_to do |format| 
        format.json {render json: 'Bad Credentials', status: 401}
        format.xml {render json: 'Bad Credentials', status: 401}
      end
    end


    private
    def user_params
      params.require(:user).permit(
        :name,
        :email,
        :phone
      )
    end
  end
end
