class UserSessionsController < ApplicationController
  before_filter :login_required, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Logged in successfully"
      redirect_back_or_default settings_url # TODO send to dashboard instead
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logged out successfully"
    redirect_back_or_default login_session_url
  end
end
