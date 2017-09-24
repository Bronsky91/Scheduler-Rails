module UsersHelper
    
    def get_start_end_time_slots(timeslot)
       times = case timeslot
            when 1 
                then {start: "8:00am, 11:00am, and 2:00pm", end: "9:00am, 12:00pm, and 3:00pm"}
            when 2
                then {start: "9:00am, 12:00pm, and 3:00pm", end: "10:00am, 1:00pm, and 4:00pm"}
            when 3
                then {start: "10:00am, 1:00pm, and 4:00pm", end: "11:00am, 2:00pm, and 5:00pm"}
            end
        "Your start times are #{times[:start]}. Your end times are #{times[:end]}."
    end 
end
