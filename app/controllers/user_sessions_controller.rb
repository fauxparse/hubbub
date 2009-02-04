class UserSessionsController < ApplicationController
  skip_before_filter :login_required, :except => :destroy
  
  def new
    @user_session = UserSession.new
    render :layout => "login"
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Logged in successfully"
      redirect_back_or_default root_path
    else
      flash.now[:error] = "Invalid username or password. Please try again."
      render :action => :new, :layout => "login"
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to login_url
  end
end
