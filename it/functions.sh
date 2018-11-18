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
        now_temp_is) echo "la temperatura è";;
        max_temp_is) echo "la massima è";;
        min_temp_is) echo "la minima è";;
        celsius) echo "gradi";;
        the_day) echo "il giorno";;
        strong_wind_alert) echo "Fai attenzione al forte vento";;
        too_far_in_the_future) echo "Troppi giorni avanti nel tempo";;
    esac
} 
