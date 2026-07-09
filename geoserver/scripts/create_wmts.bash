#!/bin/bash

# ==========================================
# ASETUKSET
# ==========================================
# GeoServerin osoite ja asetukset
GEOSERVER_URL="http://localhost:8083/geoserver"
WORKSPACE_NAME="maanmittauslaitos"
STORE_NAME="MML_wmts"
#WMTS_CAPABILITIES_URL="https://esimerkki.fi/geoserver/gwc/service/wmts?REQUEST=GetCapabilities"
#WMTS_CAPABILITIES_URL="https://avoin-karttakuva.maanmittauslaitos.fi/avoin/wmts/1.0.0/WMTSCapabilities.xml"
WMTS_CAPABILITIES_URL="https://avoin-karttakuva.maanmittauslaitos.fi/avoin/wmts?REQUEST=GetCapabilities"
#WMTS_CAPABILITIES_URL="https://avoin-karttakuva.maanmittauslaitos.fi/avoin/wmts?REQUEST=GetCapabilitiesapi-key=19e2bb1d-1ecb-44a7-b401-d3e9f64db8d7"
#WMTS_CAPABILITIES_URL="https://avoin-karttakuva.maanmittauslaitos.fi/avoin/wmts?&api-key=19e2bb1d-1ecb-44a7-b401-d3e9f64db8d7&service=WMTS&request=GetCapabilities"

# Salasanatiedoston polku
CREDENTIALS_FILE=".env_geoserver"

# ==========================================
# TUNNUSTEN LUKEMINEN
# ==========================================
echo "Luetaan tunnistetiedot..."

if [ -f "$CREDENTIALS_FILE" ]; then
    # Ladataan muuttujat tiedostosta
    source "$CREDENTIALS_FILE"
else
    echo "❌ Virhe: Tunnistetiedostoa '$CREDENTIALS_FILE' ei löytynyt!"
    echo "Luo tiedosto ja määritä sinne GEOSERVER_USER ja GEOSERVER_PASS."
    exit 1
fi

# Tarkistetaan, että muuttujat eivät ole tyhjiä
if [ -z "$GEOSERVER_USER" ] || [ -z "$GEOSERVER_PASS" ]; then
    echo "❌ Virhe: Tunnusta (GEOSERVER_USER) tai salasanaa (GEOSERVER_PASS) ei löytynyt tiedostosta!"
    exit 1
fi

# ==========================================
# SKRIPTI ALKAA
# ==========================================
echo "Aloitetaan GeoServerin konfigurointi REST API:n kautta..."
echo "--------------------------------------------------------"

# 1. Luodaan Workspace (Työtila)
echo "1. Luodaan työtila: $WORKSPACE_NAME"

WORKSPACE_XML="<workspace><name>${WORKSPACE_NAME}</name></workspace>"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -u "$GEOSERVER_USER:$GEOSERVER_PASS" \
  -X POST \
  -H "Content-type: text/xml" \
  -d "$WORKSPACE_XML" \
  "$GEOSERVER_URL/rest/workspaces")

if [ "$HTTP_STATUS" -eq 201 ]; then
    echo "✅ Työtila luotiin onnistuneesti."
elif [ "$HTTP_STATUS" -eq 409 ]; then
    echo "⚠️ Työtila '$WORKSPACE_NAME' on jo olemassa. Jatketaan..."
else
    echo "❌ Virhe työtilan luonnissa. HTTP-status: $HTTP_STATUS"
    exit 1
fi

echo "--------------------------------------------------------"

# 2. Luodaan WMTS Store (Tietovarasto)
echo "2. Luodaan WMTS store: $STORE_NAME työtilaan $WORKSPACE_NAME"

WMTS_XML="<wmtsStore>
  <name>${STORE_NAME}</name>
  <type>WMTS</type>
  <enabled>true</enabled>
  <workspace>
    <name>${WORKSPACE_NAME}</name>
  </workspace>
  <capabilitiesURL>${WMTS_CAPABILITIES_URL}</capabilitiesURL>
  <authKey>api-key=${MML_API_KEY}</authKey>
</wmtsStore>"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -u "$GEOSERVER_USER:$GEOSERVER_PASS" \
  -X POST \
  -H "Content-type: text/xml" \
  -d "$WMTS_XML" \
  "$GEOSERVER_URL/rest/workspaces/$WORKSPACE_NAME/wmtsstores")

if [ "$HTTP_STATUS" -eq 201 ]; then
    echo "✅ WMTS store luotiin onnistuneesti."
elif [ "$HTTP_STATUS" -eq 409 ]; then
    echo "⚠️ WMTS store '$STORE_NAME' on jo olemassa."
else
    echo "❌ Virhe WMTS storen luonnissa. HTTP-status: $HTTP_STATUS"
    exit 1
fi

echo "--------------------------------------------------------"
echo "Kaikki valmista!"