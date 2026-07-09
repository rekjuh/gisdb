#!/bin/bash

# ==========================================
# ASETUKSET
# ==========================================
GEOSERVER_URL="http://localhost:8083/geoserver"
CREDENTIALS_FILE=".env_geoserver"

# ==========================================
# TUNNUSTEN LUKEMINEN
# ==========================================
echo "Luetaan tunnistetiedot..."
if [ -f "$CREDENTIALS_FILE" ]; then
    source "$CREDENTIALS_FILE"
else
    echo "❌ Virhe: Tunnistetiedostoa '$CREDENTIALS_FILE' ei löytynyt!"
    exit 1
fi

if [ -z "$GEOSERVER_USER" ] || [ -z "$GEOSERVER_PASS" ]; then
    echo "❌ Virhe: Tunnusta tai salasanaa ei löytynyt tiedostosta!"
    exit 1
fi

GWC_API_URL="$GEOSERVER_URL/gwc/rest/gridsets"

# ==========================================
# FUNKTIO: GRIDSETIN LÄHETYS REST APIIN
# ==========================================
laheta_gridset() {
    local gridset_name=$1
    local xml_file=$2

    echo "Lähetetään GridSet: $gridset_name ..."
    
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
      -u "$GEOSERVER_USER:$GEOSERVER_PASS" \
      -X PUT \
      -H "Content-type: application/xml" \
      -d "@$xml_file" \
      "$GWC_API_URL/${gridset_name}.xml")

    if [ "$HTTP_STATUS" -eq 200 ] || [ "$HTTP_STATUS" -eq 201 ]; then
        echo "✅ GridSet '$gridset_name' tallennettu (HTTP $HTTP_STATUS)."
    else
        echo "❌ Virhe '$gridset_name' tallennuksessa. HTTP-status: $HTTP_STATUS"
    fi
}

echo "--------------------------------------------------------"
echo "Aloitetaan JHS 180 -tiilijakojen luonti GeoServeriin..."
echo "--------------------------------------------------------"

# ==========================================
# 1. EPSG:3067 (TM35FIN)
# ==========================================
echo "Luodaan EPSG:3067 (JHS180_TM35FIN) ..."
cat <<EOF > tmp_tm35fin.xml
<gridSet>
  <name>JHS180_TM35FIN</name>
  <srs><number>3067</number></srs>
  <extent>
    <coords>
      <double>-548576.0</double>
      <double>6291456.0</double>
      <double>1548576.0</double>
      <double>8388608.0</double>
    </coords>
  </extent>
  <alignTopLeft>true</alignTopLeft>
  <resolutions>
    <double>8192</double>
    <double>4096</double>
    <double>2048</double>
    <double>1024</double>
    <double>512</double>
    <double>256</double>
    <double>128</double>
    <double>64</double>
    <double>32</double>
    <double>16</double>
    <double>8</double>
    <double>4</double>
    <double>2</double>
    <double>1</double>
    <double>0.5</double>
    <double>0.25</double>
  </resolutions>
  <metersPerUnit>1.0</metersPerUnit>
  <tileHeight>256</tileHeight>
  <tileWidth>256</tileWidth>
</gridSet>
EOF

laheta_gridset "JHS180_TM35FIN" "tmp_tm35fin.xml"
echo "--------------------------------------------------------"

# ==========================================
# 2. GK-KAISTAT (19 - 31)
# ==========================================
echo "Luodaan GK-kaistat (19 - 31) ..."

for gk in {19..31}; do
    # Lasketaan EPSG-koodi (GK19 = 3873, josta se kasvaa yhdellä per kaista)
    epsg=$(( 3854 + gk ))
    
    # Lasketaan kaistan X-koordinaattien ääripäät
    # Perustuu TM35FIN:n ulottuvuuksiin, mutta siirrettynä kaistan valeeidällä
    min_x=$(( gk * 1000000 - 548576 ))
    max_x=$(( gk * 1000000 + 1548576 ))
    
    gridset_name="JHS180_GK${gk}"
    tmp_xml="tmp_gk${gk}.xml"

    cat <<EOF > "$tmp_xml"
<gridSet>
  <name>${gridset_name}</name>
  <srs><number>${epsg}</number></srs>
  <extent>
    <coords>
      <double>${min_x}.0</double>
      <double>6291456.0</double>
      <double>${max_x}.0</double>
      <double>8388608.0</double>
    </coords>
  </extent>
  <alignTopLeft>true</alignTopLeft>
  <resolutions>
    <double>8192</double>
    <double>4096</double>
    <double>2048</double>
    <double>1024</double>
    <double>512</double>
    <double>256</double>
    <double>128</double>
    <double>64</double>
    <double>32</double>
    <double>16</double>
    <double>8</double>
    <double>4</double>
    <double>2</double>
    <double>1</double>
    <double>0.5</double>
    <double>0.25</double>
  </resolutions>
  <metersPerUnit>1.0</metersPerUnit>
  <tileHeight>256</tileHeight>
  <tileWidth>256</tileWidth>
</gridSet>
EOF

    laheta_gridset "$gridset_name" "$tmp_xml"
done

# ==========================================
# SIIVOUS
# ==========================================
echo "--------------------------------------------------------"
echo "Siivotaan väliaikaiset XML-tiedostot..."
rm tmp_tm35fin.xml tmp_gk*.xml

echo "Kaikki valmista! 14 GridSetiä on nyt asennettu GeoServeriin."