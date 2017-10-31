class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:show]
  require 'base64'
  require 'json'
  # GET /users
  # GET /users.json

  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    # Redtail given API key
    @apikey = '1424B19F-5111-4B39-97A9-953EEEC81A18'
    # Passes API key to JS file
    gon.apikey = @apikey
    # Redtail username and password entered from Show View
    @reduser = params[:reduser] 
    @redpass = params[:redpass]
    # Makes Auth API call if Redtail username and password was entered
    if @reduser && @redpass != nil
       headers = { 
         "Authorization"  => "Basic "+ Base64.strict_encode64(@apikey+":"+@reduser+":"+@redpass),
         "Content-Type" => "application/json"
         } 
       @auth = HTTParty.get(
          "http://dev.api2.redtailtechnology.com/crm/v1/rest/authentication", 
          :headers => headers)
          # Message that will show in View if API auth failed
        if @auth['Message'] != 'Success'
          flash.now[:error] = "Invalid Redtail login, try again"
          render 'show'
        end
        
        # Saves RedtailID and UserKey to Database
        @user.redtailid = @auth['UserID']
        @user.userkey = @auth['UserKey'].to_s
        @user.save!
    end
  # Passes RedtailID to JS file
  gon.redtailid = @user.redtailid
  gon.userkey = @user.userkey
  @dataValue = params[:data_value]
    if @user.timeslot != nil
        @timeslot_parsed = JSON.parse(@user.timeslot)
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.link = "schedule.bronsky.life/#{@user.username}" 
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
    @userName = User.find_by(username: params[:username])
    @apikey = '1424B19F-5111-4B39-97A9-953EEEC81A18'
    gon.apikey = @apikey
    gon.userID = @userName.redtailid
    gon.userkey = @userName.userkey
    #Creates Variables for 3 week date range activities API call
    @currentDate = Time.now.strftime("%m-%d-%Y")
    headers = { 
      "Authorization"  => "Userkeyauth "+ Base64.strict_encode64(@apikey+":"+@userName.userkey),
      "Content-Type" => "application/json", "Accept" => "application/json"
          } 
    # API call to gather all Redtail Activities in the next 3 weeks
    @calData = HTTParty.post(
      "http://dev.api2.redtailtechnology.com/crm/v1/rest/calendar/search", 
      :headers => headers,
      :body => [
        {  
           Field: 21, Operand: 0, Value: @userName.redtailid
        },
        {
           Field: 4, Operand: 1, Value: @currentDate
        }
      ].to_json
      )
    # Passes Redtail Calendar Data variable to Javascript
    gon.calData = @calData
    # Passes Database object to Javascript
    @timeslot_parsed = JSON.parse(@userName.timeslot)
    gon.timeslotObject = @timeslot_parsed
    # Method to show what Timeslots get viewed on Datepicker
    def slot(parsed)
      html = String.new
      idArray = Array.new
      i = 0
      parsed['value'].each do |array|
        butVal = array['data']['start']
        butVal = butVal.to_s
        butVal.insert(-3,':')
        idArray.push(i)
       html << '<tr>
        <td colspan="8">
        <div> <button value=' + butVal + ' class="timeSlot" data-day='  + array['day'] + ' data-length='+ array['length'].to_s + ' id=' + idArray[i].to_s + '>' +  array['show'] +  ' </button> 
        </div>
        </td>
        </tr>'
        i = i + 1
      end
     return html.html_safe
    end
  #Javascript variable of method
  gon.slot = slot(@timeslot_parsed)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :email, :password, :timeslot, :redtailid, :userkey)
    end

    def logged_in_user
      unless logged_in?
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end
end
