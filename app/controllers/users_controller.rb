class UsersController < ApplicationController
  before_filter :login_required, :only => [ :show, :edit, :update ]
  before_filter :get_user, :except => [ :new, :create ]

  def index
    @companies = params[:company_id] ? [ current_company ] : current_account.companies.all(:include => :users)
  end

  def new
    @user = current_account.users.build(:company_id => current_company.id)
  end

  def create
    @user = current_account.users.build(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default person_path(@user)
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
      redirect_to(params[:id] ? person_path(@user) : settings_path)
    else
      render :action => :edit
    end
  end
  
protected
  def get_user
    @user = params[:id] ? User.find_by_login(params[:id]) : current_user
    raise ActiveRecord::RecordNotFound unless @user
  end
end
