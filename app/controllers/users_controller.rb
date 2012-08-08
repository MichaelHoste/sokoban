class UsersController < ApplicationController  
  def popular_friends
    @user = User.find(params[:id])
    @popular_friends = @user.popular_friends(5)
    render 'popular_friends', :layout => false
  end
end
