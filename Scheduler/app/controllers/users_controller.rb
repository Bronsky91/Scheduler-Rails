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
    # Sets timeslot to Database after submission
    @timeslot = User.find(set_user).timeslot
    # Switch for timeslot selection logic, integers in database represent timeslots below
    case @timeslot
      when 1 
         then @slot = {start: "8:00am, 11:00am, and 2:00pm", end: "9:00am, 12:00pm, and 3:00pm"}
      when 2
         then @slot = {start: "9:00am, 12:00pm, and 3:00pm", end: "10:00am, 1:00pm, and 4:00pm"}
      when 3
         then @slot = {start: "10:00am, 1:00pm, and 4:00pm", end: "11:00am, 2:00pm, and 5:00pm"}
    end
    # Redtail given API key
    @apikey = '1424B19F-5111-4B39-97A9-953EEEC81A18'
    gon.apikey = @apikey
    # Redtail username and password entered from Show View
    @reduser = params[:reduser] 
    @redpass = params[:redpass]
    # Logic to make Auth API call if Redtail username and password was entered
    if @reduser && @redpass != nil
       headers = { 
         "Authorization"  => "Basic "+ Base64.strict_encode64(@apikey+":"+@reduser+":"+@redpass),
         "Content-Type" => "application/json"
         } 
       @response = HTTParty.get(
          "http://dev.api2.redtailtechnology.com/crm/v1/rest/authentication", 
          :headers => headers)
          # Message that will show in View if API auth failed
        if @response['Message'] != 'Success'
          flash.now[:error] = "Invalid Redtail login, try again"
          render 'show' 
        end
        # Saves RedtailID and UserKey to Database
        @user.redtailid = @response['UserID']
        @user.userkey = @response['UserKey'].to_s
        @user.save!
    end

  gon.redtailid = @user.redtailid

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
    @userName = User.find_by_username(params[:username])
    @apikey = '1424B19F-5111-4B39-97A9-953EEEC81A18'
    gon.apikey = @apikey
    gon.userID = @userName.redtailid
    gon.userkey = @userName.userkey
    #Creates Variables for 3 week date range activities API call
    @currentDate = Time.now.strftime("%m-%d-%Y")
    threeWeeks = Date.parse(Time.now.strftime("%d-%m-&Y")) 
    threeWeeks += 21
    @threeWeeks = threeWeeks.strftime("%m-%d-%Y")
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
        },
        {
           Field: 5, Operand: 2, Value: @threeWeeks
        }
      ].to_json
      )
    # Gives variable to Javascript
    gon.calData = @calData

    @timeslot = @userName.timeslot
    # Switch to select when Timeslot get viewed on Datepicker
    case @timeslot
      when 1 
        then gon.slot = '<tr>
          <td colspan="8">
            <div> 
                <button id="first" value="08:00 am" class="timeSlot">8:00 am – 9:00 am </button>
            </div>
                <button id="middle" value="11:00" class="timeSlot">11:00 am – 12:00 pm</button>
            </div>
                <button id="last" value="14:00" class="timeSlot">2:00 pm – 3:00 pm</button>
            </div>
            </td>
             </tr>'
      when 2
        then gon.slot = '<tr>
         <td colspan="8">
            <div> 
                <button id="first" value="09:00 am" class="timeSlot">9:00 am – 10:00 am </button>
            </div>
                <button id="middle" value="12:00" class="timeSlot">12:00 pm – 1:00 pm</button>
            </div>
                <button id="last" value="15:00" class="timeSlot">3:00 pm – 4:00 pm</button>
            </div>
          </td>
          </tr>'
      when 3
        then gon.slot = '<tr>
        <td colspan="8">
            <div> 
                <button id="first" value="10:00 am" class="timeSlot">10:00 am – 11:00 am </button>
            </div>
                <button id="middle" value="13:00" class="timeSlot">1:00 pm – 2:00 pm</button>
            </div>
                <button id="last" value="16:00" class="timeSlot">4:00 pm – 5:00 pm</button>
            </div>
          </td>
        </tr>'
    end
    # Switch to select which timeslot gets selected to block out conflicts
    case @timeslot
      when 1
        then gon.timeSlotStart = [800, 1100, 1400]
             gon.timeSlotEnd = [900, 1200, 1500]
      when 2
        then gon.timeSlotStart = [900, 1200, 1500]
             gon.timeSlotEnd = [1000, 1300, 1600]
      when 3
        then gon.timeSlotStart = [1000, 1300, 1600]
             gon.timeSlotEnd = [1100, 1400, 1700]
    end

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
