json.extract! appointment, :id, :ownerid, :datetime, :allday, :subject, :body, :created_at, :updated_at
json.url appointment_url(appointment, format: :json)
