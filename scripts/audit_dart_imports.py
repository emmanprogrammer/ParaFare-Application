#!/usr/bin/env python3
"""Simple local import audit for Dart files.

Checks that:
- relative imports resolve on disk
- package imports for this repo (`package:parafare_application/...`) resolve to `lib/...`
"""

from __future__ import annotations

import re
from pathlib import Path

PACKAGE_NAME = 'parafare_application'
IMPORT_RE = re.compile(r"import\s+'([^']+)';")


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    missing: list[str] = []

    for dart_file in sorted((repo_root / 'lib').rglob('*.dart')):
        text = dart_file.read_text(encoding='utf-8')
        for match in IMPORT_RE.finditer(text):
            uri = match.group(1)

            if uri.startswith('dart:'):
                continue

            if uri.startswith('package:'):
                prefix = f'package:{PACKAGE_NAME}/'
                if not uri.startswith(prefix):
                    continue
                rel_path = uri.removeprefix(prefix)
                target = repo_root / 'lib' / rel_path
            else:
                target = (dart_file.parent / uri).resolve()

            if not target.exists():
                missing.append(
                    f"{dart_file.relative_to(repo_root)} -> {uri} (missing {target.relative_to(repo_root)})",
                )

    if missing:
        print('Missing imports found:')
        for item in missing:
            print(f'- {item}')
        return 1

    print('Import audit passed: no missing local Dart imports.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
