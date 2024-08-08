#!/bin/bash

# Define user and user ID for the X session
X_USER="qq"
X_USERID=$(id -u $X_USER)

# Find the DBUS_SESSION_BUS_ADDRESS
DBUS_ADDRESS=$(sudo -u $X_USER echo "$DBUS_SESSION_BUS_ADDRESS")
echo "DBUS_ADDRESS: $DBUS_ADDRESS" >> "$LOGFILE"

LOGFILE="/home/qq/crontab.log"

# Check battery percentage
BATTERY_PERCENT=$(cat /sys/class/power_supply/BAT0/capacity)

# Battery status
BATTERY_STATUS=$(cat /sys/class/power_supply/BAT0/status)

# Define the threshold for suspension (e.g., 20%)
THRESHOLD_NOTIFY=40
THRESHOLD_SUSPEND=30

echo "$(date): Battery at $BATTERY_PERCENT%, status: $BATTERY_STATUS" >> "$LOGFILE"

if [ "$BATTERY_PERCENT" -le "$THRESHOLD_NOTIFY" ] && [ "$BATTERY_STATUS" != "Charging" ]; then
  sudo -u $X_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDRESS" /usr/bin/notify-send "Battery at $BATTERY_PERCENT%" | sudo tee -a "$LOGFILE" 2>&1
fi

# Check if battery percentage is less than or equal to threshold
if [ "$BATTERY_PERCENT" -le "$THRESHOLD_SUSPEND" ] && [ "$BATTERY_STATUS" != "Charging" ]; then
  echo "$(date): Suspending system" >> "$LOGFILE"
  # Suspend the system
  sudo /bin/systemctl suspend | sudo tee -a "$LOGFILE" 2>&1
else
  echo "$(date): Not suspending system" >> "$LOGFILE"
fi

