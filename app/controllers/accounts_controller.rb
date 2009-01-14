class AccountsController < ApplicationController
  skip_before_filter :check_account_status, :only => "index"
  skip_before_filter :login_required, :only => "index"

  def index
  end
end
