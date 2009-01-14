class UsersController < ApplicationController
  before_filter :login_required, :only => [ :show, :edit, :update ]
  before_filter :get_user, :except => [ :new, :create ]

  def new
    @user = current_account.users.new
  end

  def create
    @user = current_account.users.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default settings_path
    else
      render :action => :new
    end
  end

  def show
    render :action => "edit"
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated"
      redirect_to(params[:id] ? @user : settings_path)
    else
      render :action => :edit
    end
  end
  
protected
  def get_user
    @user = params[:id] ? User.find(params[:id]) : current_user
  end
end
