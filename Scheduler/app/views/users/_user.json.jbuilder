json.extract! user, :id, :username, :email, :password, :timeslot, :redtailid, :link, :created_at, :updated_at
json.url user_url(user, format: :json)
