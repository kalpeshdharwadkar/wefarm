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
  
  # PUT /farmers/1/update
  def update
    @farmer = Farmer.find(params[:id])
    if @farmer.update_attributes(params[:farmer])
      redirect_to @farmer, notice: 'Farmer was successfully updated.'
    else
      render :action => 'edit'
    end
  end
  
  # GET /farmers/oauth/1
  def oauth
		if !params[:code]
			return redirect_to('/')
		end 
		redirect_uri = url_for(:controller => 'farmers', :action => 'oauth', :farmer_id => params[:farmer_id], :host => request.host_with_port)
		@farmer = Farmer.find(params[:farmer_id])
		begin
		  @farmer.request_wepay_access_token(params[:code], redirect_uri)
		rescue Exception => e
		  error = e.message
		end
		
		if error
		  redirect_to @farmer, alert: error
		else
		  redirect_to @farmer, notice: 'We successfully connected you to WePay!'
		end
	end
	
	# GET /farmers/buy/1
  def buy
    redirect_uri = url_for(:controller => 'farmers', :action => 'payment_success', :farmer_id => params[:farmer_id], :host => request.host_with_port)
    @farmer = Farmer.find(params[:farmer_id])
    begin
		  @checkout = @farmer.create_checkout(redirect_uri)
		rescue Exception => e
		  redirect_to @farmer, alert: e.message
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
