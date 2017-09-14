module UsersHelper

    def get_start_end_time_slots(slot)
        string = String.new
            slot.each do |key, value|
                string << "Your #{key} times are #{value}. "
            end 
        return string
    end 

end
