class AssignmentsController < ApplicationController
  def update
    @assignment = Assignment.find params[:id]
    @assignment.update_attributes params[:assignment]
    respond_to do |format|
      format.js
    end
  end
end
