(function() {
    $(function() {
        var firstHour, selectedBooking, selectedDate, selectedLocation;
        selectedLocation = $('#salon_location').val();
        selectedDate = new Date(getTodayDate());
        firstHour = 7;
        selectedBooking = null;
        return loadCalendar('resourceDay', null, selectedLocation, selectedDate, firstHour, selectedBooking);
    });
}).call(this);

function getTodayDate() {
    var d = new Date(),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();
    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;
    return [year, month, day].join('-');
}

var $booking_calendar = $('#booking_calendar'),
    checkUpdatesInterval = 30000, // millisecondi
    calendarResourceView,
    calendarCurrentDate,
    calendarDay,
    calendarMonth,
    calendarYear;

function check_updates() {
    // aggiorno la timeline
    setTimeline();

    // recupero la resourceView del calendar (vista giornaliera o settimanale)
    calendarResourceView = $booking_calendar.fullCalendar("getView").name;
    // recupero data corrente del calendar
    calendarCurrentDate = $booking_calendar.fullCalendar("getDate");
    calendarDay = '' + calendarCurrentDate.getDate();
    calendarMonth = '' + (calendarCurrentDate.getMonth() + 1);
    calendarYear = calendarCurrentDate.getFullYear();
    if (calendarDay < 10) calendarDay = '0' + calendarDay;
    if (calendarMonth < 10) calendarMonth = '0' + calendarMonth;

    // scarico i nuovi eventi creati (se ci sono)
    $.ajax({
        method: "POST",
        dataType: "script",
        url: "/backend/stecms_appointment/bookings/get_updates",
        data:{
            "interval": (checkUpdatesInterval/1000),
            "resource_view": calendarResourceView,
            "calendar_date": calendarYear+'-'+calendarMonth+'-'+calendarDay,
            "employee_id": $('#staffList').val()
        }
    });

}

$(function() {
    $(document).on('click', '#staffList', function(){
        $('.popover').hide();
    });

    // controllo se ci sono nuovi eventi periodicamente
    setInterval(check_updates, checkUpdatesInterval);

    $('#print-calendar').on('click',function(){
        calendarCurrentDate = $booking_calendar.fullCalendar("getDate");
        calendarDay = '' + calendarCurrentDate.getDate();
        calendarMonth = '' + (calendarCurrentDate.getMonth() + 1);
        calendarYear = calendarCurrentDate.getFullYear();
        if (calendarDay < 10) calendarDay = '0' + calendarDay;
        if (calendarMonth < 10) calendarMonth = '0' + calendarMonth;
        $(this).attr('href','/print_calendar.php?start='+calendarYear+'-'+calendarMonth+'-'+calendarDay);
        return true;
    });
});