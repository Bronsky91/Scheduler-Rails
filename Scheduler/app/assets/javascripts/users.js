$(document).ready(function () {
  // Copy to clipboard logic for Requester Link
  var clipboard = new Clipboard('[copy-to-clipboard-button]');
  clipboard.on('success', function () {
  });
  clipboard.on('error', function () {
    alert('Unable to copy');
  });

  // API call to get Redtail Calendar preferences
  $.ajax
    ({
      type: "GET",
      url: "http://dev.api2.redtailtechnology.com/crm/v1/rest/settings/calendar",
      contentType: "application/json",
      headers: {
        "Authorization": "Userkeyauth " + btoa(gon.apikey + ":" + gon.userkey)
      },
      success: function (calPref) {
        // Enables Timepicker plugin
        $('.timepicker').timepicker({
          timeFormat: 'h:mm p',
          interval: 15,
          minTime: calPref.StartOfDay.toString(),
          maxTime: calPref.EndOfDay.toString(),
          dropdown: true,
          dynamic: false,
          defaultTime: calPref.StartOfDay.toString(),
          scrollbar: true
        });
      }, error: function (XMLHttpRequest, textStatus, errorThrown)
      { alert(errorThrown); }
    });

  // Function that cleans data for selected Timeslots divs that accepts the timepicker value and the timeslot length 
  function selectedSlot(timepickerVal, slotLength) {
    slotArray = timepickerVal.split(/[:\s]/g);
    for (i = 0; i < 2; i++) {
      slotArray[i] = Number(slotArray[i]);
    }
    if (slotArray[2] == 'PM' && slotArray[0] != 12) {
      slotArray[0] = slotArray[0] + 12;
    }
    msum = slotArray[1] + slotLength;
    mmod = msum % 60;
    hsum = slotArray[0];
    mshow = mmod;
    hshow = hsum;
    if (msum >= 60) {
      hsum += 1;
      hshow = hsum
    }
    meridiem = 'AM';
    if (hsum >= 12) {
      meridiem = 'PM'
    }
    if (mmod == 0) {
      mshow = '00';
    }
    if (hsum > 12) {
      hshow = hsum - 12;
    }
    hCutOff = slotArray[0];
    mCutOff = slotArray[1] - 30;
    if (mCutOff < 0) {
      if (slotArray[0] == 0) {
        mCutOff += 30
      } else {
        mCutOff = 60 + mCutOff
        hCutOff -= 1
      }
    }
    start = slotArray[0] * 100;
    start = start + slotArray[1];
    end = hsum * 100;
    end = end + mmod;
    cutOff = hCutOff * 100;
    cutOff = cutOff + mCutOff;

    selectedData = {
      show: timepickerVal.replace(/\s/g, '') + "-" + hshow + ':' + mshow + meridiem,
      data: {      
        start: start,
        end: end,
        cutOff: cutOff
      }
    }
    return selectedData
  }

  $(".add").click(function () {
    timepickerVal = $('.timepicker').val();
    slotData = JSON.stringify(selectedSlot(timepickerVal, gon.slotLength));
    $(".slottable").append("<div class=\"slotbox\" data-value=" + slotData + ">" + selectedSlot(timepickerVal, gon.slotLength).show + "<button class=\"remove\">x</button></div>")
    return false;
  });

  $('.slottable').on('click', '.remove', function () {
    $(this).closest('.slotbox').remove();
    return false;
  });

$(".apply").click(function () {
  dataValue = []
  $('.slotbox').each(function () {
    dataValue.push($(this).data('value'));
  })
  dataObject = {
    value: dataValue
  }
  dataObject = JSON.stringify(dataObject);
  $('.hiddenValue').val(dataObject);
});

  // Creates variable for dates array
  var datesArray = [];
  var timesEnd = [];
  var timesStart = [];
  var allDay = [];
  for (i = 0; i < gon.calData.Activities.length; i++) {
    datesArray.push(gon.calData.Activities[i].EndDate);
    timesEnd.push(gon.calData.Activities[i].EndDate);
    timesStart.push(gon.calData.Activities[i].StartDate);
    allDay.push(gon.calData.Activities[i].AllDayEvent);
  }
  // Extracts the date value from the API data
  for (i = 0; i < datesArray.length; i++) {
    datesArray[i] = datesArray[i].slice(6, 19);
    timesEnd[i] = timesEnd[i].slice(6, 19);
    timesStart[i] = timesStart[i].slice(6, 19);
  }
  // Makes dates in array into a readable format
  for (i = 0; i < datesArray.length; i++) {
    var d = new Date(0);
    var e = new Date(0);
    var s = new Date(0);
    d.setUTCMilliseconds(datesArray[i]);
    e.setUTCMilliseconds(timesEnd[i]);
    s.setUTCMilliseconds(timesStart[i]);
    var month = d.getMonth() + 1;
    datesArray[i] = d.getDate() + '-' + month + '-' + d.getFullYear();
    timesEnd[i] = e.getHours() + ':' + e.getMinutes();
    timesStart[i] = s.getHours() + ':' + s.getMinutes();
  }
  // Creates an array of all dates that have all day events.
  var allDayDates = [];
  for (i = 0; i < datesArray.length; i++) {
    if (allDay[i] == true) {
      allDayDates.push(datesArray[i]);
    }
  }
  // Converts Timeslots to integers
  var intTimeStart = [];
  var intTimeEnd = [];
  for (i = 0; i < timesStart.length; i++) {
    timesStart[i] = timesStart[i].replace(/:/g, '.');
    timesEnd[i] = timesEnd[i].replace(/:/g, '.');
    timesStart[i] = parseFloat(timesStart[i]);
    intTimeStart.push(Math.round(timesStart[i] * 100));
    timesEnd[i] = (parseFloat(timesEnd[i]));
    intTimeEnd.push(Math.round(timesEnd[i] * 100));
  }
  // Creates Array of Objects of Each Date, Start and End Time
  var calActObj = {}
  var act = "Activities";
  var activities = []
  for (i = 0; i < gon.calData.Activities.length; i++) {
    activities.push({
      0: datesArray[i],
      1: intTimeStart[i],
      2: intTimeEnd[i]
    })
  }
  var fullTimeSlots = [];
  // Creates Object of Array of Date/Time Objects
  calActObj[act] = activities;
  // Loop to push full dates to fullTimesSlots array
  for (j = 0; j < gon.timeSlotStart.length; j++) {
    for (i = 0; i < calActObj.Activities.length; i++) {
      if (calActObj.Activities[i][2] <= gon.timeSlotStart[j] || calActObj.Activities[i][1] >= gon.timeSlotEnd[j]) {
      } else {
        fullTimeSlots.push(calActObj.Activities[i][0])
      }
    }
  }
  // Creates 2 correlating arrays that counts the number of times that slots are available each day
  function count(arr) {
    var a = [], b = [], prev;
    arr.sort();
    for (var i = 0; i < arr.length; i++) {
      if (arr[i] !== prev) {
        a.push(arr[i]);
        b.push(1);
      } else {
        b[b.length - 1]++;
      }
      prev = arr[i];
    }
    return [a, b];
  }
  var fullTimeSlots = count(fullTimeSlots);
  // Loop that checks the fullTimeSlots correlating arrays if 3 timeslots have conflicts for the day, key is pushed into allDayDates array
  for (i = 0; i < fullTimeSlots[0].length; i++) {
    if (fullTimeSlots[1][i] == gon.numOfSlots) {
      allDayDates.push(fullTimeSlots[0][i])
    }
  }
  console.log(fullTimeSlots);
  // Unavailable date function
  function unavailable(date) {
    dmy = date.getDate() + "-" + (date.getMonth() + 1) + "-" + date.getFullYear();
    if ($.inArray(dmy, allDayDates) == -1) {
      return [true, ""];
    } else {
      return [false, "", "Unavailable"];
    }
  }
  // Date picker
  var $datePicker = $("div#datepicker");
  var $datePicker = $("div");
  $(function () {
    $("#datepicker").datepicker({
      controlType: 'select',
      minDate: 0,
      dateFormat: "d-m-yy",
      altField: "#datep",
      beforeShowDay: unavailable,
    }).change(function () {
      setTimeout(function (e) {
        // Timeslots
        $datePicker.find('.ui-datepicker-current-day')
          .parent()
          .after(gon.slot);
        // Creates Current date and time
        date = new Date();
        var todayDate = date.getDate();
        var todayMonth = date.getMonth() + 1;
        var todayYear = date.getFullYear();
        var today = todayDate + '-' + todayMonth + '-' + todayYear;
        var todayTime = date.getTime();
        var todayHours = date.getHours(todayTime);
        var todayMinutes = date.getMinutes(todayTime);
        var todayT = (todayHours + ':' + todayMinutes)
        todayT = todayT.replace(/:/g, '.');
        todayT = parseFloat(todayT);
        todayT = Math.round(todayT * 100);
        // Hides timeslots if current time as already past and conflicts with timeslot
        var timeSlotButton = [];
        for (i = 0; i < gon.numOfSlots; i++){
          timeSlotButton.push('#'+i);
        }
        for (j = 0; j < gon.timeSlotStartCurrent.length; j++) {
          if ($('#datepicker').val() == today) {
            if (todayT >= gon.timeSlotStartCurrent[j]) {
              $(timeSlotButton[j]).addClass('disabled');
            }
          }
        }
        console.log(timeSlotButton);
        // Hides timeslots if conflicts in Redtail occurs
        for (j = 0; j < gon.timeSlotStart.length; j++) {
          for (i = 0; i < calActObj.Activities.length; i++) {
            if ($('#datepicker').val() == calActObj.Activities[i][0]) {
              if (calActObj.Activities[i][2] <= gon.timeSlotStart[j] || calActObj.Activities[i][1] >= gon.timeSlotEnd[j]) {
              } else {
                $(timeSlotButton[j]).addClass('disabled');
              }
            }
          }
        }
        // Shows user that timeslot was chosen
        $('.timeSlot').on("click", function () {
          $(this).toggleClass('active');
          // Creates variables from chosen date/time
          var selectedTime = $(this).val();
          var selectedDate = moment($('#datepicker').val() + ' ' + selectedTime, "D-M-YYYY HH mm");
          if (gon.slotLength == 60) {
            var selectedDateFuture = moment(selectedDate).add(1, 'h');
          } else {
            var selectedDateFuture = moment(selectedDate).add(gon.slotLength, 'm');
          }
          document.getElementById("scheduleAct").onclick = function () {
            var emailField = $("#email").val();
            var subjectData = $("#subject").val();
            var detailsData = $("#details").val();
            var unixTime = selectedDate.valueOf();
            var unixTimeHour = selectedDateFuture.valueOf();
            $.ajax
              ({
                type: "POST",
                url: "http://dev.api2.redtailtechnology.com/crm/v1/rest/contacts/search",
                contentType: "application/json",
                headers: {
                  "Authorization": "Userkeyauth " + btoa(gon.apikey + ":" + gon.userkey)
                },
                data: JSON.stringify([{ "Field": 16, "Operand": 0, "Value": emailField }]),
                success: function (clientData) {
                  if (clientData.Contacts == null) {
                    c = confirm("Schedule Appointment?");
                    if (c == true) {
                      // PUT call to create activity in Redtail
                      $.ajax
                        ({
                          type: "PUT",
                          url: "http://dev.api2.redtailtechnology.com/crm/v1/rest/calendar/activities/0",
                          contentType: "application/json",
                          headers: {
                            "Authorization": "Userkeyauth " + btoa(gon.apikey + ":" + gon.userkey)
                          },
                          data: JSON.stringify({ "ActivityOwnerID": gon.userID, "StartDate": "\/Date(" + unixTime + ")\/", "EndDate": "\/Date(" + unixTimeHour + ")\/", "TypeID": 2, "AllDayEvent": false, "Subject": subjectData, "Note": detailsData }),
                          success: function (actData) {
                            console.log(actData);
                            alert("Appointment Scheduled!");
                            // Clears Subject and Details boxess
                            $("#subject").val('');
                            $("#details").val('');
                            $("#email").val('');
                            location.reload();
                          }, error: function (XMLHttpRequest, textStatus, errorThrown)
                          { alert(errorThrown); }
                        });
                    } else {
                      alert("Nothing scheduled yet");
                    }
                  } else {
                    var clientID = clientData.Contacts[0].ClientID;
                    var cf = confirm("Schedule appointment?");
                    if (cf == true) {
                      // PUT call to create activity in Redtail
                      $.ajax
                        ({
                          type: "PUT",
                          url: "http://dev.api2.redtailtechnology.com/crm/v1/rest/calendar/activities/0",
                          contentType: "application/json",
                          headers: {
                            "Authorization": "Userkeyauth " + btoa(gon.apikey + ":" + gon.userkey)
                          },
                          data: JSON.stringify({ "ActivityOwnerID": gon.userID, "StartDate": "\/Date(" + unixTime + ")\/", "EndDate": "\/Date(" + unixTimeHour + ")\/", "TypeID": 2, "AllDayEvent": false, "Subject": subjectData, "Note": detailsData, "ClientID": clientID }),
                          success: function (actData) {
                            console.log(actData);
                            alert("Appointment Scheduled!");
                            // Clears Subject and Details boxess
                            $("#subject").val('');
                            $("#details").val('');
                            $("#email").val('');
                            location.reload();
                          }, error: function (XMLHttpRequest, textStatus, errorThrown)
                          { alert(errorThrown); }
                        });
                    }
                  }
                }, error: function (XMLHttpRequest, textStatus, errorThrown)
                { alert(errorThrown); }
              });
          }
        })
      });
    });
  });
})