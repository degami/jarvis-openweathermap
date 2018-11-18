#!/bin/bash
# Here you can define translations to be used in the plugin functions file
# the below code is an sample to be reused:
# 1) uncomment to function below
# 2) replace XXX by your plugin name (short)
# 3) remove and add your own translations
# 4) you can the arguments $2, $3 passed to this function
# 5) in your plugin functions.sh file, use it like this:
#      say "$(pv_myplugin_lang the_answer_is "oui")"
#      => Jarvis: La réponse est oui

pg_ow_lang () {
    case "$1" in
        now_temp_is) echo "temperature is";;
        max_temp_is) echo "maximum temperature is";;
        min_temp_is) echo "minimum temperature is";;
        celsius) echo "celsius";;
        the_day) echo "the day";;
        strong_wind_alert) echo "Beware the strong wind";;
        too_far_in_the_future) echo "Too far in the future";;
    esac
} 
