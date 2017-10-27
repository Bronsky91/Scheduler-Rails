module UsersHelper

    def timepicker
        content_tag(:input, nil, class: "timepicker", size: '10')
    end
      
    def available_time_slots_for(time_hash, day)
        if time_hash == nil
            return
        else 
            time_hash = JSON.parse(time_hash)
            html = String.new
            time_hash['value'] = time_hash['value'].select {|time_slot| time_slot['day'].include?(day) }
            time_hash['value'].each do |index|
                html <<  content_tag(:div, class: 'slotbox', data: {value: index, order: index['data']['start'], day: index['day']} ) do
                    content_tag(:span, index['show'], class: 'timespan') +  
                    content_tag(:button, 'x', class:'remove')
                    end
             end
        html.html_safe
        end
    end
end