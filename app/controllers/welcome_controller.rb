class WelcomeController < ApplicationController
  def index
    @farmers = Farmer.all
  end
end
