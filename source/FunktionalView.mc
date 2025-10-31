using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Application;

class FunktionalView extends WatchUi.WatchFace {
    
    var iconFont;

    public function dayofWeekName(dow) {
        switch (dow) {
            case 0:
                return "Sunday";
            case 1:
                return "Monday";
            case 2:
                return "Tuesday";
            case 3:
                return "Wednesday";
            case 4:
                return "Thursday";
            case 5:
                return "Friday";
            case 6:
                return "Saturday";
            default:
                return "Monday";
        }
    }

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        iconFont = WatchUi.loadResource(Rez.Fonts.IconFont);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Get the current time and format it correctly
        var clockTime = System.getClockTime();
        var timeFormat = "$1$:$2$";
        var hours = clockTime.hour;

        // Get the current date
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var infoLong = Gregorian.info(now, Time.FORMAT_SHORT);
        
        // Day of week
        var dayOfWeek = dayofWeekName(infoLong.day_of_week);
        
        var year = info.year.format("%04u");
        var month = info.month.format("%02u");
        var day = info.day.format("%02u");

        // Date in YYYY-MM-DD format
        var dateString = Lang.format("$1$-$2$-$3$", [
            year, month, day
        ]);

        // Get activity info
        var activityInfo = ActivityMonitor.getInfo();
        var heartRate = Activity.getActivityInfo().currentHeartRate;
        var steps = activityInfo.steps;
        var activeMinutes = activityInfo.activeMinutesDay.total;
        
        // Get battery percentage
        var battery = System.getSystemStats().battery.toNumber();

        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Get screen dimensions
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;


        // Check if we should use 24-hour or 12-hour format
        if (!System.getDeviceSettings().is24Hour) {
            var timeFormatAppend = "AM";
            
            if (hours > 12) {
                hours = hours - 12;
                timeFormatAppend = "PM";
            } else if (hours == 0) {
                hours = 12;
            }

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            var horizontalShiftDaypart = centerX + 85;
            // if (timeFormatAppend == "AM") {
                // dc.drawText(horizontalShiftDaypart, centerY - 40, Graphics.FONT_SYSTEM_MEDIUM, timeFormatAppend, Graphics.TEXT_JUSTIFY_LEFT);
            // } else {
                dc.drawText(horizontalShiftDaypart, centerY - 20, Graphics.FONT_SYSTEM_MEDIUM, timeFormatAppend, Graphics.TEXT_JUSTIFY_LEFT  | Graphics.TEXT_JUSTIFY_VCENTER);
            // }
        }
        
        var hoursString = hours.format("%02u");
        var minutesString = clockTime.min.format("%02u");
        var timeString = Lang.format(timeFormat, [hoursString, minutesString]);

        // Draw seconds dot
        drawSecondsDot(dc, clockTime.sec, centerX, centerY);

        // Draw time in the center
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 20, Graphics.FONT_SYSTEM_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw day of week above time
        dc.setColor(Graphics.COLOR_GREEN | Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 70, Graphics.FONT_MEDIUM, dayOfWeek, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw date below time
        dc.drawText(centerX, centerY + 30, Graphics.FONT_SMALL, dateString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        
        // Draw indicators
        drawIndicators(dc, heartRate, steps, activeMinutes, battery, width, height);
    }

    // Draw the seconds as a rotating dot
    function drawSecondsDot(dc, seconds, centerX, centerY) {
        // Calculate angle (0 seconds = top, 15 seconds = right, 30 seconds = bottom, 45 seconds = left)
        // Angle in radians: 0 is at 3 o'clock position, so we need to adjust
        var angle = (seconds * 6 - 90) * Math.PI / 180.0; // 6 degrees per second, -90 to start at top
        
        // Calculate position on circle
        var radius = centerX;
        var dotX = centerX + radius * Math.cos(angle);
        var dotY = centerY + radius * Math.sin(angle);
        
        // Draw the dot
        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(dotX, dotY, 7);
    }

    // Draw indicators for heart rate, steps, active minutes, and battery
    function drawIndicators(dc, heartRate, steps, activeMinutes, battery, width, height) {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;

        // Battery (top) - Icon: B
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 122, iconFont, "B", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 120, Graphics.FONT_SMALL, battery.toString() + "%", Graphics.TEXT_JUSTIFY_LEFT);
        
        // Active minutes (left) - Icon: A
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - 5, centerY + 50, iconFont, "A", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - 37, centerY + 50, Graphics.FONT_SMALL, activeMinutes.toString() + "m", Graphics.TEXT_JUSTIFY_RIGHT);
        
        // Steps (right) - Icon: S
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 5, centerY + 50, iconFont, "S", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 37, centerY + 50, Graphics.FONT_SMALL, steps.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        

        // Heart rate (bottom) - Icon: H
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        var verticalShiftHr = centerY + 90;
        dc.drawText(centerX, verticalShiftHr, iconFont, "H", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        if (heartRate != null) {
            dc.drawText(centerX, verticalShiftHr, Graphics.FONT_SMALL, heartRate.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, verticalShiftHr, Graphics.FONT_SMALL, "--", Graphics.TEXT_JUSTIFY_LEFT);
        }
        
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}

