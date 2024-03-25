#!/bin/bash

power_full=$(cat '/sys/class/power_supply/BAT0/energy_full')
power_now=$(cat '/sys/class/power_supply/BAT0/energy_now')
power_status=$(cat '/sys/class/power_supply/BAT0/status')
#power_percent=$(printf "%.2f\n" $((10**2 * $power_now/$power_full*100))e-2)
power_percent=$(awk "BEGIN {print $power_now/$power_full*100}")
#power_percent=$(printf %.0f $power_percent)
power_percent=$(echo "($power_percent+0.5)/1" | bc)
while [[ $power_percent -le 65 && "$power_status" == 'Discharging' ]]; do
    notify-send "Battery low" "Battery level is ${power_percent}%!"
    echo -ne '\007'
    sleep 1
    power_status=$(cat '/sys/class/power_supply/BAT0/status')
done

while [[ $power_percent -gt 75 && "$power_status" != 'Discharging' ]]; do
    notify-send "Battery high" "Battery level is ${power_percent}%!"
    #https://unix.stackexchange.com/questions/1974/how-do-i-make-my-pc-speaker-beep
    echo -ne '\007'
    sleep 1
    power_status=$(cat '/sys/class/power_supply/BAT0/status')
done

unset power_full & unset power_now & unset power_status & unset power_percent
