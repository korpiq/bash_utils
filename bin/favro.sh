#!/bin/bash

favro_fail () {
    echo "Favro failed: $*" >&2
    return 1
}

favro_org_id () {
    curl -su "$TOKEN" -X GET "https://favro.com/api/v1/organizations" | jq -r '.entities[0].organizationId'
}

favro_get () {
    curl -su "$TOKEN" -H "organizationId: $ORG" -X GET "https://favro.com/api/v1/$1"
}

favro_query () {
    URI="$1"
    shift
    favro_get "$URI" | jq "$@"
}

favro_id_of_widget () { # give widget name
    favro_query widgets -r '.entities[] | select(.name == "'"$1"'") | .widgetCommonId'
}

favro_id_of_widget_column () { # give widget name and column name
    WIDGET_ID=${WIDGET_ID:-$(favro_id_of_widget "$1")}
    favro_query "columns?widgetCommonId=$WIDGET_ID" -r '.entities[] | select(.name == "'"$2"'") | .columnId'
}

favro_query_cards_of_widget_column () {
    COLUMN_ID=${COLUMN_ID:-$(favro_id_of_widget_column "$1" "$2")}
    FILTER="$3"
    shift; shift; shift
    favro_query "cards?columnId=$COLUMN_ID&$FILTER" "$@"
}

favro_do () {
    export ORG=${ORG:-$(favro_org_id)}
    if [ -n "$ORG" ]
    then
        favro_"$@"
    else
        favro_fail "Missing favro organizationID (ORG)."
    fi
}

if [ "$BASH_SOURCE" = "$0" -a -n "$*" ]
then
    if [ -n "$TOKEN" ]
    then
        favro_do "$@"
    else
        favro_fail "Missing TOKEN (favro email:token)"
    fi
fi

