class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user
  
  private
  def current_user
    @current_user ||= Farmer.find(session[:farmer_id]) if session[:farmer_id]
  rescue ActiveRecord::RecordNotFound
      session[:farmer_id] = nil
  end
end
