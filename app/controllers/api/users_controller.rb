module API
  class UsersController < ApplicationController

    def index
      users = User.all
      if name = params[:name]
        users = users.where(name: name)
      end
      respond_to do |format|
        format.json {render json: users, status: 200}
        format.xml {render xml: users, status: 200}
      end
    end

    def show
      user = User.find(params[:id])
      render json: user, status: 200
    end

    def create
      user = User.new(user_params)
      if user.save
        # render json: user, status: 201, location: user
        render nothing: true, status: 204, location: user
      end
    end

    def new
    end

    def edit
    end

    def update
    end

    def destroy
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
