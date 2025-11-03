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

    var lowPowerMode = false;

    public function dayofWeekName(dow) {
        switch (dow) {
            case 1:
                return "Sunday";
            case 2:
                return "Monday";
            case 3:
                return "Tuesday";
            case 4:
                return "Wednesday";
            case 5:
                return "Thursday";
            case 6:
                return "Friday";
            case 7:
                return "Saturday";
            default:
                return "Monday";
        }
    }

    public function heightPctCoord(dc, pct) {
        return Math.round(dc.getHeight() * (pct/100.0));
    }

    public function widthPctCoord(dc, pct) {
        return Math.round(dc.getWidth() * (pct/100.0));
    }

    function initialize() {
        WatchFace.initialize();
    }

    function onEnterSleep() as Void {
        lowPowerMode = true;
    }

    function onExitSleep() as Void {
        lowPowerMode = false;
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
        var centerX = widthPctCoord(dc, 50);
        var centerY = heightPctCoord(dc, 50);
        
        // Draw seconds dot
        drawSecondsDot(dc, clockTime.sec, centerX, centerY);

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
            var horizontalShiftDaypart = widthPctCoord(dc, 85
            );
            // if (timeFormatAppend == "AM") {
                // dc.drawText(horizontalShiftDaypart, centerY - 40, Graphics.FONT_SYSTEM_MEDIUM, timeFormatAppend, Graphics.TEXT_JUSTIFY_LEFT);
            // } else {
                dc.drawText(horizontalShiftDaypart, centerY - 15, Graphics.FONT_SMALL, timeFormatAppend, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            // }
        }

        var hoursString = hours.format("%02u");
        var minutesString = clockTime.min.format("%02u");
        var timeString = Lang.format(timeFormat, [hoursString, minutesString]);

        // Draw time in the center
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 20, Graphics.FONT_SYSTEM_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw day of week above time
        dc.setColor(Graphics.COLOR_GREEN | Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, heightPctCoord(dc, 25), Graphics.FONT_MEDIUM, dayOfWeek, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw date below time
        dc.drawText(centerX, heightPctCoord(dc, 63), Graphics.FONT_MEDIUM, dateString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        
        // Draw indicators
        drawIndicators(dc, heartRate, steps, activeMinutes, battery);
    }

    // Draw the seconds as a rotating dot
    function drawSecondsDot(dc, seconds, centerX, centerY) {
        if (lowPowerMode) {
            return;
        }

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
    function drawIndicators(dc, heartRate, steps, activeMinutes, battery) {
        var centerX = widthPctCoord(dc, 50);

        // Battery (top) - Icon: B
        var batteryPos = heightPctCoord(dc, 8);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, batteryPos, iconFont, "B", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, batteryPos, Graphics.FONT_SMALL, battery.toString() + "%", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        var indicatorVerticalCoord = heightPctCoord(dc, 78);
        // Active minutes (left) - Icon: A
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - 5, indicatorVerticalCoord, iconFont, "A", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - 37, indicatorVerticalCoord, Graphics.FONT_SMALL, activeMinutes.toString() + "m", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Steps (right) - Icon: S
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 5, indicatorVerticalCoord, iconFont, "S", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 37, indicatorVerticalCoord, Graphics.FONT_SMALL, steps.toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        if (lowPowerMode) {
            return;
        }

        // Heart rate (bottom) - Icon: H
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        var verticalShiftHr = heightPctCoord(dc, 90);
        dc.drawText(centerX, verticalShiftHr, iconFont, "H", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        if (heartRate != null) {
            dc.drawText(centerX, verticalShiftHr, Graphics.FONT_SMALL, heartRate.toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, verticalShiftHr, Graphics.FONT_SMALL, "--", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
}

