from qgis.utils import iface
from qgis.core import QgsProject, QgsRasterLayer, QgsVectorLayer
from pathlib import Path

def load_layers():
    project = QgsProject.instance()

    # OpenStreetMap background (XYZ tiles, not WMS)
    osm_uri = (
        "type=xyz&url=https://tile.openstreetmap.org/"
        "{z}/{x}/{y}.png&zmin=0&zmax=19"
    )
    osm = QgsRasterLayer(osm_uri, "OpenStreetMap", "wms")

    if osm.isValid():
        project.addMapLayer(osm)
    else:
        iface.messageBar().pushWarning("OpenStreetMap", "Could not load OSM tiles.")

    # GeoPackage vector layer
    gpkg_path = str(Path(__file__).resolve().parent.parent / "misc" / "aineisto.gpkg")
    table_name = "aineisto"  # Name of the layer inside the GeoPackage
    gpkg = QgsVectorLayer(
        f"{gpkg_path}|layername={table_name}",
        table_name,
        "ogr",
    )

    if gpkg.isValid():
        project.addMapLayer(gpkg)
    else:
        iface.messageBar().pushWarning("GeoPackage", "Could not load the GeoPackage layer.")

iface.initializationCompleted.connect(load_layers)
