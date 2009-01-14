class AccountsController < ApplicationController
  skip_before_filter :check_account_status, :only => "index"

  def index
  end
end
