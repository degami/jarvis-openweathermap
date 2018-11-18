#!/bin/bash
# Here you can create functions which will be available from the commands file
# You can also use here user variables defined in your config file
# To avoid conflicts, name your function like this
# pg_XX_myfunction () { }
# pg for PluGin
# XX is a short code for your plugin, ex: ww for Weather Wunderground
# You can use translations provided in the language folders functions.sh

jw_pg_ow_ceil() {
    NUMBER=$1
    out=$(python -c "from math import ceil; print int(ceil($NUMBER))")
    echo $out;
    return 0
}

jv_pg_ow_get_data_from_json() {
    local jsondata=$1
    
    local today=false;
    if [[ -n "$2" ]] && [[ "$2" -eq "today" ]]; then today=true; fi

    local description=$( echo $jsondata | jq .weather[0].description )
    local temp=$(jw_pg_ow_ceil $(bc <<< "$( echo $jsondata | jq .main.temp ) - 273.15"))
    local max_temp=$(jw_pg_ow_ceil $(bc <<< "$( echo $jsondata | jq .main.temp_max ) - 273.15"))
    local min_temp=$(jw_pg_ow_ceil $(bc <<< "$( echo $jsondata | jq .main.temp_min ) - 273.15"))
    local wind=$(bc <<< "$( echo $jsondata | jq .wind.speed ) * 3.6")

    out="$description in $jv_pg_ow_city."
    if [[ $today == true ]]; then
        out=$out" $(pg_ow_lang now_temp_is) $temp $(pg_ow_lang celsius)"
    fi
    if [[ "${out: -1}" == "." ]]; then out=$out" "; else out=$out", "; fi
    out=$out"$(pg_ow_lang max_temp_is) $max_temp $(pg_ow_lang celsius)"
    out=$out", $(pg_ow_lang min_temp_is) $min_temp $(pg_ow_lang celsius)"

    if [[ $(bc <<< "$wind > 28") > 0 ]]; then
        out=$out". $(pg_ow_lang strong_wind_alert)"
    fi
    echo $out
    return 0
}

jv_pg_ow_query_weather() {
    lang=${language:0:2}
    local jsonresp=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=$jv_pg_ow_city,$jv_pg_ow_country&lang=$lang&appid=$jv_pg_ow_appid")
    local cod=$( echo $jsonresp | jq .cod )
    if [[ "$cod" == "200" ]]; then 
        jv_pg_ow_get_data_from_json "$jsonresp" "today"
    else 
        echo $jsonresp
    fi
    return 0
}

jv_pg_ow_query_forecast() {
    numday=$(bc <<< "$1 - 1")
    if [[ $numday > $(bc <<< "$jv_pg_ow_max_days_to_forecast - 1") ]]; then
        echo "$(pg_ow_lang too_far_in_the_future)" 
        return
    fi

    tomorrow_ts=$(date --date "$(date --date tomorrow +"%d %h %Y")" +%s)
    lang=${language:0:2}
    local cnt=$(bc <<< "$jv_pg_ow_max_days_to_forecast * 8")
    local jsonresp=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?q=$jv_pg_ow_city,$jv_pg_ow_country&lang=$lang&cnt=$cnt&appid=$jv_pg_ow_appid")
    local cod=$( echo $jsonresp | jq .cod )
    cod=${cod:1:3}
    if [[ "$cod" == "200" ]]; then 
        local dt=$( echo $jsonresp | jq .list[$numday].dt )
        local STARTFROM=0
        while [ $STARTFROM -lt $cnt ] && [ $(($dt)) -lt $(($tomorrow_ts)) ]; do
            dt=$( echo $jsonresp | jq ".list[$STARTFROM].dt" )
            let STARTFROM=STARTFROM+1 
        done

        STARTFROM=$(bc <<< "$STARTFROM + ($numday * 8)")
        local dayinfo=$( echo $jsonresp | jq .list[$STARTFROM] )
        dt=$( echo $jsonresp | jq ".list[$STARTFROM].dt" )
        local day=$(date -d "@$dt" +"%d %h %Y")
        echo "$(pg_ow_lang the_day) $day " $(jv_pg_ow_get_data_from_json "$dayinfo")
    else 
        echo $jsonresp
    fi
    return 0
}