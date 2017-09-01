class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:show]
  require 'base64'
  # GET /users
  # GET /users.json

  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @timeslot = User.find(set_user).timeslot
    @apikey = '1424B19F-5111-4B39-97A9-953EEEC81A18'
    @reduser = params[:reduser] 
    @redpass = params[:redpass]

    if @reduser && @redpass != nil
       headers = { 
         "Authorization"  => "Basic "+ Base64.strict_encode64(@apikey+":"+@reduser+":"+@redpass),
         "Content-Type" => "application/json"
         } 
       @response = HTTParty.get(
          "http://dev.api2.redtailtechnology.com/crm/v1/rest/authentication", 
          :headers => headers)
        if @response['Message'] != 'Success'
          flash.now[:error] = "Invalid Redtail login, try again"
          render 'show' 
        end
        @user.redtailid = @response['UserID'] # I need these two variables to save
        @user.userkey = @response['UserKey'].to_s # into my database
        @user.save!
        keyheaders = { 
          "Authorization"  => "Userkeyauth "+Base64.strict_encode64(@apikey+":"+@user.userkey),
          "Content-Type" => "application/json"
          } 
        @sso = HTTParty.get(
          "http://dev.api2.redtailtechnology.com/crm/v1/rest/sso?ep=calendar", 
          :headers => keyheaders)
        @user.sso = @sso['ReturnURL']
        @user.save!
    end

    case @timeslot
      when 1 
         then @slot = {start: "8:00am, 11:00am, and 2:00pm", end: "9:00am, 12:00pm, and 3:00pm"}
      when 2
        then @slot = {start: "9:00am, 12:00pm, and 3:00pm", end: "10:00am, 1:00pm, and 4:00pm"}
      when 3
        then @slot = {start: "10:00am, 1:00pm, and 4:00pm", end: "11:00am, 2:00pm, and 5:00pm"}
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def api

  end
  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.link = "localhost:3000/#{@user.username}"
    respond_to do |format|
      if @user.save
        log_in @user
        flash[:success] = "Logged in as #{@user.username}"
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def datepicker
    #for requester to browse to datepicker
  end

  def submit
    #for requester to submit time

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :email, :password, :timeslot, :redtailid, :link, :userkey)
    end

    def logged_in_user
      unless logged_in?
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end
end
