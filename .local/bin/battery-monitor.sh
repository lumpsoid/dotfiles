#!/bin/bash

# Battery Monitor Script
# Usage: ./battery_monitor.sh [--watch]

BATTERY_PATH="/sys/class/power_supply/BAT1"
AC_PATH="/sys/class/power_supply/A*"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display battery info
show_battery_info() {
    clear
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}           🔋 BATTERY MONITOR           ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo
    
    # Check if battery exists
    if [[ ! -d "$BATTERY_PATH" ]]; then
        echo -e "${RED}❌ Battery BAT1 not found!${NC}"
        exit 1
    fi
    
    # Read battery values
    local capacity=$(cat "$BATTERY_PATH/capacity" 2>/dev/null || echo "N/A")
    local status=$(cat "$BATTERY_PATH/status" 2>/dev/null || echo "Unknown")
    local current_now=$(cat "$BATTERY_PATH/current_now" 2>/dev/null || echo "0")
    local voltage_now=$(cat "$BATTERY_PATH/voltage_now" 2>/dev/null || echo "0")
    local charge_now=$(cat "$BATTERY_PATH/charge_now" 2>/dev/null || echo "0")
    local charge_full=$(cat "$BATTERY_PATH/charge_full" 2>/dev/null || echo "1")
    
    # Check AC adapter status
    local ac_online="0"
    for ac in $AC_PATH; do
        if [[ -f "$ac/online" ]]; then
            ac_online=$(cat "$ac/online")
            break
        fi
    done
    
    # Calculate values
    local current_amps=$(echo "scale=3; $current_now / 1000000" | bc 2>/dev/null || echo "0")
    local voltage_volts=$(echo "scale=2; $voltage_now / 1000000" | bc 2>/dev/null || echo "0")
    local power_watts=$(echo "scale=2; $current_amps * $voltage_volts" | bc 2>/dev/null || echo "0")
    local charge_ah=$(echo "scale=3; $charge_now / 1000000" | bc 2>/dev/null || echo "0")
    local capacity_ah=$(echo "scale=3; $charge_full / 1000000" | bc 2>/dev/null || echo "0")
    
    # Determine status color and icon
    local status_color="$NC"
    local status_icon=""
    case "$status" in
        "Charging")
            status_color="$GREEN"
            status_icon="🔌"
            ;;
        "Discharging")
            status_color="$YELLOW"
            status_icon="⚡"
            ;;
        "Full")
            status_color="$GREEN"
            status_icon="✅"
            ;;
        *)
            status_color="$NC"
            status_icon="❓"
            ;;
    esac
    
    # Battery level color
    local capacity_color="$GREEN"
    if [[ "$capacity" -lt 20 ]]; then
        capacity_color="$RED"
    elif [[ "$capacity" -lt 50 ]]; then
        capacity_color="$YELLOW"
    fi
    
    # Create battery bar
    local bar_length=20
    local filled=$((capacity * bar_length / 100))
    local empty=$((bar_length - filled))
    local battery_bar=""
    for ((i=0; i<filled; i++)); do battery_bar+="█"; done
    for ((i=0; i<empty; i++)); do battery_bar+="░"; done
    
    # Display information
    echo -e "📊 ${BLUE}Battery Status${NC}"
    echo -e "   Status: ${status_color}${status_icon} ${status}${NC}"
    echo -e "   AC Power: $([[ $ac_online == "1" ]] && echo -e "${GREEN}🔌 Connected${NC}" || echo -e "${RED}🔋 On Battery${NC}")"
    echo
    
    echo -e "🔋 ${BLUE}Charge Level${NC}"
    echo -e "   ${capacity_color}${capacity}%${NC} [${capacity_color}${battery_bar}${NC}]"
    echo -e "   ${charge_ah} Ah / ${capacity_ah} Ah"
    echo
    
    echo -e "⚡ ${BLUE}Power Information${NC}"
    echo -e "   Current: ${current_amps} A"
    echo -e "   Voltage: ${voltage_volts} V"
    echo -e "   Power: ${power_watts} W"
    echo
    
    # Time estimation
    if [[ "$status" == "Charging" && $(echo "$current_amps > 0" | bc) == "1" ]]; then
        local remaining_ah=$(echo "scale=3; $capacity_ah - $charge_ah" | bc)
        local time_hours=$(echo "scale=1; $remaining_ah / $current_amps" | bc)
        echo -e "⏱️  ${BLUE}Estimated Time to Full${NC}: ${GREEN}~${time_hours} hours${NC}"
    elif [[ "$status" == "Discharging" && $(echo "$current_amps > 0" | bc) == "1" ]]; then
        local time_hours=$(echo "scale=1; $charge_ah / $current_amps" | bc)
        echo -e "⏱️  ${BLUE}Estimated Time Remaining${NC}: ${YELLOW}~${time_hours} hours${NC}"
    fi
    
    echo
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "Last updated: $(date '+%H:%M:%S')"
    
    if [[ "$1" != "--watch" ]]; then
        echo -e "\nRun with ${GREEN}--watch${NC} for continuous monitoring"
    fi
}

# Check if bc is available
if ! command -v bc &> /dev/null; then
    echo "Warning: 'bc' not found. Install it for better calculations."
    echo "On Ubuntu/Debian: sudo apt install bc"
    echo "On RHEL/CentOS: sudo yum install bc"
    echo
fi

# Main execution
if [[ "$1" == "--watch" ]]; then
    echo "Press Ctrl+C to exit..."
    while true; do
        show_battery_info --watch
        sleep 2
    done
else
    show_battery_info
fi
