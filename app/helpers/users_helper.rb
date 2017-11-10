module UsersHelper
    # Creates timepicker html element
    def timepicker
        content_tag(:input, nil, class: "timepicker", size: '10')
    end

    # Adds slotbox html elements to view per day
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

    # Shows what Timeslots get viewed on Datepicker
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

      #icalendar creation method
      def make_ical(timeslot_data)
        cal = Icalendar::Calendar.new
        cal.event do |e|
          e.dtstart     = DateTime.parse(timeslot_data['startTime'])
          e.dtend       = DateTime.parse(timeslot_data['endTime'])
          e.summary     = timeslot_data['subject']
          e.description = timeslot_data['details']
          e.organizer = "Your Advisor Financial Advisor"
        end
        cal.publish
        file = File.new("tmp/ics_files/invite.ics", "w+")
        file.write(cal.to_ical)
        file.close
       end

end
