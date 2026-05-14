#!/usr/bin/env python3
"""Print the Terminal-Bench v2 task list from the AA methodology page."""

from __future__ import annotations

import html
import re
import sys
import urllib.request


URL = "https://artificialanalysis.ai/methodology/coding-agents-benchmarking"


def main() -> int:
    raw = urllib.request.urlopen(URL, timeout=30).read().decode("utf-8", "replace")
    try:
        start = raw.index("Terminal Bench 2<!-- -->: <!-- -->84")
        end = raw.index("SWE Atlas<!-- -->: <!-- -->124", start)
    except ValueError as exc:
        raise SystemExit(f"Could not find the Terminal Bench 2 task section in {URL}") from exc

    chunk = raw[start:end]
    tasks = [html.unescape(match) for match in re.findall(r"<li>([a-z0-9][a-z0-9_.-]*)</li>", chunk)]
    for task in sorted(tasks):
        print(task)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
