module UsersHelper
    
    def show_timeslots_selected(timeslot)
        timeslot = JSON.parse(timeslot)
        html = String.new
        timeslot['value'].each do |index|
           html <<  content_tag(:div, class: 'slotbox', data: {value: index, order: index['data']['start']} ) do
                    content_tag(:span, index['show']) +  
                    content_tag(:button, 'x', class:'remove')
            end
        end
        html.html_safe
     end

    def timepicker
        content_tag(:input, nil, class: "timepicker", size: '10')
    end

    def timeslotLength
        [['15 Min', 15], ['30 Min', 30], ['45 Min', 45], ['1 Hour', 60]]
    end

end
