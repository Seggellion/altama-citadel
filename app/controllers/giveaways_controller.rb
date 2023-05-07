class GiveawaysController < ApplicationController
  def signup
    twitch_username = params[:email]
    user = User.where(email: params[:email])

    if user.giveaway_send?
      render json: { message: 'You have already signed up for the giveaway' }, status: :unprocessable_entity
    else
      user.update(giveaway_send: true)
      render json: { message: 'You have successfully signed up for the giveaway' }, status: :created
    end
  end
end
