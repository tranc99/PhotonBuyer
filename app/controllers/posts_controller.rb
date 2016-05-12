class PostsController < ApplicationController

  include PayPal::SDK::AdaptivePayments

  def index
    puts "$$$$$$nagas and orcs"
    @posts = Post.all
  end

  def ipnnotification
    puts "$$$$$$$$IPN Notification, params:"
    puts params

    #callback = AdaptivePay::Callback.new params
    # if callback.completed?

    if PayPal::SDK::Core::API::IPN.valid?(request.raw_post)
      puts "$$$$$$$$$$$$$ VERIFICATION COMPLETION"
      first_post = Post.first
      first_post.caption = "VERIFICATION COMPLETION RECORDED"
      first_post.save

      # payment has been processed, now mark order as paid etc
    else
      first_post = Post.first
      first_post.caption = "POST VERIFICATION FAILURE RECORDED"
      first_post.save
      # payment failed
    end
    render json: Post.first
    #if we receive a hook notification
    #check if completed
    #then verify the token with paypal
    #if valid, we mark the purchase as successfully
    #and we flash the user and redirect the user's session
    # https://developer.paypal.com/docs/classic/ipn/integration-guide/IPNSimulator/
    # http://stackoverflow.com/questions/27081578/paypal-adaptive-payments-rails-app-configuration
    # https://github.com/paypal/adaptivepayments-sdk-ruby/blob/master/samples/app/controllers/adaptive_payments_samples/adaptive_payments_controller.rb
    # https://github.com/paypal/adaptivepayments-sdk-ruby
    # https://github.com/paypal/adaptivepayments-sdk-ruby/blob/master/samples/app/views/adaptive_payments_samples/adaptive_payments/pay.html.haml
    # https://paypal-sdk-samples.herokuapp.com/adaptive_payments/pay
    # http://www.thecrowned.org/tutorial-paypal-adaptive-payments-api-embedded
    # https://github.com/paypal/ipn-code-samples/blob/master/paypal_ipn.php
    # => http://www.perfectline.co/blog/2010/07/correct-paypal-ipn-handling-with-rails/
    #
    #
    #
    #puts "$$$$$$$$$$$$$$ Received a notification"
    #puts params
    #redirect_to "/posts/2"
  end

  def buyit
    #@post = Post.find(params[:id])
    @api = PayPal::SDK::AdaptivePayments.new
    #initiate payment for that order

    @pay = @api.build_pay({
      :actionType => "PAY",
      #:cancelUrl => "http://localhost:3000/posts/1",
      :cancelUrl => "https://young-depths-76182.herokuapp.com/posts/1",
      #https://young-depths-76182.herokuapp.com
      :currencyCode => "USD",
      :feesPayer => "SENDER",
      #:ipnNotificationUrl => "http://localhost:3000/posts/ipnnotification",
      :ipnNotificationUrl => "https://young-depths-76182.herokuapp.com/posts/ipnnotification",
      :receiverList => {
        :receiver => [{
          :amount => 1.0,
          :email => "tmutunhire-facilitator@gmail.com" }] },
      :returnUrl => "https://young-depths-76182.herokuapp.com/posts" })

    # Make API call & get response
    @response = @api.pay(@pay)
    puts "####$$$$$$$$$$Response:"
    puts @response

    # Access response
    if @response.success? && @response.payment_exec_status != "ERROR"
      puts "PAYKEY"
      puts @response.payKey
      @response.payKey
      @api.payment_url(@response)  # Url to complete payment
      puts "should redirect to:"
      puts @api.payment_url(@response)
      redirect_to @api.payment_url(@response)
    else
      @response.error[0].message
      redirect_to 'http://hackishword.com'
    end

    #if successful, send user to payment page

    #send user to index page
    #flash the details of the payment, and say the payment will be confirmed in a few moments

  end

  def new
    @post = Post.new
  end

  def create
    @post  = Post.create post_params
    redirect_to posts_path
  end

  def show
    @post = Post.find(params[:id])
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    @post.update(post_params)
    redirect_to post_path @post
  end

  def destroy
    @post = Post.find(params[:id])
    @post.delete
    flash[:notice] = "Post successfully deleted"
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:caption, :image)
  end

end
