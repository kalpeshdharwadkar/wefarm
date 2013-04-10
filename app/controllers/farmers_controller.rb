class FarmersController < ApplicationController
  # GET /farmers
  # GET /farmers.json
  def index    
  end

  # GET /farmers/1
  def show
    @farmer = Farmer.find(params[:id])
    @is_admin = current_user && current_user.id == @farmer.id
  end

  # GET /farmers/new
  def new
    if current_user
      redirect_to root_path, :notice => "You are already registered" 
    end
    @farmer = Farmer.new
  end

  # GET /farmers/1/edit
  def edit
    @farmer = Farmer.find(params[:id])
    if current_user.id != @farmer.id
      redirect_to @farmer
    end
  end

  # POST /farmers
  def create    
    @farmer = Farmer.new(params[:farmer])

    if @farmer.save
      session[:farmer_id] = @farmer.id
      redirect_to @farmer, notice: 'Farmer was successfully created.'      
    else
      render action: "new"
    end
  end
  
  # GET /farmers/oauth/1
  def oauth
		if !params[:code]
			return redirect_to('/')
		end 
		@farmer = Farmer.find(params[:farmer_id])
		if @farmer.request_wepay_access_token(params[:code])
		  redirect_to @farmer, notice: 'We have successfully connected you to WePay!'
		else
		  redirect_to @farmer, alert: 'There was an error connecting to WePay'
		end
	end
	
	# GET /farmers/buy/1
  def buy
    @farmer = Farmer.find(params[:farmer_id])
    @checkout = @farmer.create_checkout
    if(@checkout && @checkout["error"])
      redirect_to @farmer, alert: "Error - #{@checkout['error_description']}"
    end
  end
  
  # GET /farmers/payment_success/1
  def payment_success
    @farmer = Farmer.find(params[:farmer_id])
		if !params[:checkout_id]
			return redirect_to @farmer, alert: "Error - Checkout ID is expected"
		end
		if (params['error'] && params['error_description'])
			return redirect_to @farmer, alert: "Error - #{params['error_description']}"
		end
		redirect_to @farmer, notice: "Thanks for the payment! You should receive a confirmation email shortly."
	end

end
