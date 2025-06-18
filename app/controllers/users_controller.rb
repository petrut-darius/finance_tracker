class UsersController < ApplicationController
  def my_portfolio
    @tracked_stocks = current_user.stocks
    @user = current_user
  end

  def my_friends
    @tracked_friends = current_user.friends
  end

  def search
    if params[:friend].present?
      @friends = User.search(params[:friend])
      @friends = current_user.except_current_user(@friends)
      if @friends
        render turbo_stream: turbo_stream.replace(
          "search_friend_results",
          partial: "users/friend_result",
          locals: { friend: @friends }
        )
      else
        flash.now[:alert] = "Could not find user"
        render turbo_stream: turbo_stream.replace(
          "search_friend_results",
          partial: "users/friend_result",
          locals: { friend: nil }
        )
      end
    else
      flash.now[:alert] = "Please enter a friend name or email to search"
        render turbo_stream: turbo_stream.replace(
          "search_friend_results",
          partial: "users/friend_result",
          locals: { friend: nil }
        )
    end
  end

  def show
    @user = User.find(params[:id])
    @tracked_stocks = @user.stocks
  end
end
