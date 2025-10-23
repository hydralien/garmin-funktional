using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Activity;
using Toybox.ActivityMonitor;

class FunktionalView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
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
        
        // Check if we should use 24-hour or 12-hour format
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            } else if (hours == 0) {
                hours = 12;
            }
        }
        
        var hoursString = hours.format("%02u");
        var minutesString = clockTime.min.format("%02u");
        var timeString = Lang.format(timeFormat, [hoursString, minutesString]);

        // Get the current date
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var infoLong = Gregorian.info(now, Time.FORMAT_LONG);
        
        // Day of week
        var dayOfWeek = infoLong.day_of_week;
        
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

        // Draw time in the center
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 20, Graphics.FONT_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw day of week above time
        dc.drawText(centerX, centerY - 70, Graphics.FONT_MEDIUM, dayOfWeek, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw date below time
        dc.drawText(centerX, centerY + 30, Graphics.FONT_SMALL, dateString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw seconds dot
        drawSecondsDot(dc, clockTime.sec, centerX, centerY);

        // Draw indicators
        drawIndicators(dc, heartRate, steps, activeMinutes, battery, width, height);
    }

    // Draw the seconds as a rotating dot
    function drawSecondsDot(dc, seconds, centerX, centerY) {
        // Calculate angle (0 seconds = top, 15 seconds = right, 30 seconds = bottom, 45 seconds = left)
        // Angle in radians: 0 is at 3 o'clock position, so we need to adjust
        var angle = (seconds * 6 - 90) * Math.PI / 180.0; // 6 degrees per second, -90 to start at top
        
        // Calculate position on circle
        var radius = centerX * 0.85; // 85% of screen radius
        var dotX = centerX + radius * Math.cos(angle);
        var dotY = centerY + radius * Math.sin(angle);
        
        // Draw the dot
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(dotX, dotY, 5);
    }

    // Draw indicators for heart rate, steps, active minutes, and battery
    function drawIndicators(dc, heartRate, steps, activeMinutes, battery, width, height) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var leftX = 30;
        var rightX = width - 30;
        
        // Heart rate (top left)
        if (heartRate != null) {
            dc.drawText(leftX, height * 0.25, Graphics.FONT_XTINY, "HR", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(leftX, height * 0.25 + 20, Graphics.FONT_SMALL, heartRate.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(leftX, height * 0.25, Graphics.FONT_XTINY, "HR", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(leftX, height * 0.25 + 20, Graphics.FONT_SMALL, "--", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Steps (top right)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, height * 0.25, Graphics.FONT_XTINY, "STEPS", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, height * 0.25 + 20, Graphics.FONT_SMALL, steps.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Active minutes (bottom left)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(leftX, height * 0.75 - 20, Graphics.FONT_XTINY, "ACTIVE", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(leftX, height * 0.75, Graphics.FONT_SMALL, activeMinutes.toString() + "m", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Battery (bottom right)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, height * 0.75 - 20, Graphics.FONT_XTINY, "BAT", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, height * 0.75, Graphics.FONT_SMALL, battery.toString() + "%", Graphics.TEXT_JUSTIFY_CENTER);
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

