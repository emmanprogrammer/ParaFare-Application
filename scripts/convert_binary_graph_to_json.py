#!/usr/bin/env python3
"""Convert local binary graph files into JSON graph format used by the app.

Expected binary file formats (little-endian):

nodes.bin record (24 bytes):
  - uint64 node_id
  - double latitude
  - double longitude

edges.bin record (20 bytes):
  - uint64 from_node_id
  - uint64 to_node_id
  - float distance_meters

Usage:
  python scripts/convert_binary_graph_to_json.py \
    --nodes-bin nodes.bin \
    --edges-bin edges.bin \
    --out assets/graph/gensan_graph.json
"""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path

NODE_STRUCT = struct.Struct('<Qdd')
EDGE_STRUCT = struct.Struct('<QQf')


def read_nodes(path: Path):
    data = path.read_bytes()
    if len(data) % NODE_STRUCT.size != 0:
        raise ValueError(f'Invalid nodes.bin size {len(data)} (expected multiple of {NODE_STRUCT.size})')

    result = []
    for i in range(0, len(data), NODE_STRUCT.size):
        node_id, lat, lon = NODE_STRUCT.unpack_from(data, i)
        result.append({'id': str(node_id), 'latitude': lat, 'longitude': lon})
    return result


def read_edges(path: Path):
    data = path.read_bytes()
    if len(data) % EDGE_STRUCT.size != 0:
        raise ValueError(f'Invalid edges.bin size {len(data)} (expected multiple of {EDGE_STRUCT.size})')

    result = []
    for i in range(0, len(data), EDGE_STRUCT.size):
        from_id, to_id, meters = EDGE_STRUCT.unpack_from(data, i)
        result.append(
            {
                'fromNodeId': str(from_id),
                'toNodeId': str(to_id),
                'distanceMeters': float(meters),
            }
        )
    return result


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--nodes-bin', type=Path, required=True)
    parser.add_argument('--edges-bin', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    return parser.parse_args()


def main():
    args = parse_args()
    nodes = read_nodes(args.nodes_bin)
    edges = read_edges(args.edges_bin)

    payload = {'nodes': nodes, 'edges': edges}
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(payload, indent=2), encoding='utf-8')

    print(f'Converted {len(nodes)} nodes and {len(edges)} edges -> {args.out}')


if __name__ == '__main__':
    main()
