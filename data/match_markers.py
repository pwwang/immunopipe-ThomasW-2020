import pandas as pd
from datar import f
from datar.base import unique
from datar.tibble import tibble, column_to_rownames
from datar.dplyr import filter_, bind_rows
from pathlib import Path


def match_one_cluster(markers, cluster, ip_markers_dir):
    # print(markers)
    cluster_markers = markers >> filter_(f.Cluster == cluster, f.Method == "FindMarkers")
    # print(cluster_markers)
    matches = {}

    markerfile_list = list(ip_markers_dir.glob("*/markers.txt"))
    for markerfile in markerfile_list:
        ip_cluster = markerfile.parent.name
        ip_markers = pd.read_csv(markerfile, sep="\t").gene
        matched_markers_idx = cluster_markers.Marker.isin(ip_markers)
        # matches[ip_cluster] = sum(cluster_markers.Stats[matched_markers_idx]) / sum(
        #     cluster_markers.Stats
        # )
        matches[ip_cluster] = sum(matched_markers_idx) / len(cluster_markers)

    df = tibble(**matches)
    df["Cluster"] = cluster
    return df


if __name__ == "__main__":
    markers = Path(__file__).parent / "markers.txt"
    markers = pd.read_csv(markers, sep="\t")
    clusters = unique(markers.Cluster)

    ip_markers_dir = Path(__file__).parent.parent.joinpath(
        "Immunopipe-output",
        "ClusterMarkers",
        "samples.markers",
        "Cluster",
    )

    df = None
    for cluster in clusters:
        df = bind_rows(df, match_one_cluster(markers, cluster, ip_markers_dir))
        # break

    df = df >> column_to_rownames(f.Cluster)
    print(df)
