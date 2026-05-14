# AA Terminal-Bench 2

This repository is a convenience snapshot of the 84 Terminal-Bench v2 tasks listed by Artificial Analysis for its Coding Agent Index methodology.

It is not the complete upstream Terminal-Bench 2 dataset. Upstream has 89 tasks in the snapshot used here; Artificial Analysis lists 84 tasks and says it excludes five tasks because of environment compatibility issues.

## Sources

- Artificial Analysis methodology: https://artificialanalysis.ai/methodology/coding-agents-benchmarking
- Upstream Terminal-Bench 2 repository: https://github.com/harbor-framework/terminal-bench-2
- Upstream snapshot used for this repository: `2fd12b88aafdd04a52c298e3940bcb189f9766d6`
- Snapshot date checked: 2026-05-14

Artificial Analysis does not publish a Terminal-Bench 2 source commit on the methodology page. This repository pins the current upstream snapshot used during reconstruction so the task copy can be reproduced byte-for-byte.

## Task Set

The included 84 tasks are copied into `tasks/<task-id>/`. Each task keeps its upstream `task.toml`, `instruction.md`, environment, solution, and tests.

One test fixture file is intentionally redacted for public GitHub hosting: `tasks/sanitize-git-repo/tests/test_outputs.py` contained fake-looking credential strings that triggered GitHub push protection. The file path is recorded in `artifacts/redacted_files.txt`; the rest of the included task directories are byte-identical to upstream.

The five upstream tasks not present in the Artificial Analysis list are:

| Task | Upstream difficulty | Category |
| --- | --- | --- |
| `feal-linear-cryptanalysis` | hard | mathematics |
| `filter-js-from-html` | medium | security |
| `gpt2-codegolf` | hard | software-engineering |
| `make-doom-for-mips` | hard | software-engineering |
| `write-compressor` | hard | software-engineering |

Difficulty distribution for the 84 included tasks:

| Difficulty | Count |
| --- | ---: |
| easy | 4 |
| medium | 54 |
| hard | 26 |

## Scoring Notes

Artificial Analysis describes Terminal-Bench v2 in the Coding Agent Index as:

| Field | Value |
| --- | --- |
| Evaluation field | Agentic Terminal Use |
| Questions | `84*` |
| Repeats | `3` |
| Response type | Terminal-based task execution |
| Scoring | Test suite pass/fail, `pass@1` |

For test-suite evaluations, each evaluated attempt receives a binary `pass@1` result: `1` for pass and `0` for fail. The public benchmark score is the average of task-level `pass@1` results for an agent variant. When a benchmark uses repeats, those repeat results are included in the same average.

For Terminal-Bench v2 specifically, that implies an Artificial Analysis component score over `84 * 3 = 252` task attempts, scored by test-suite pass/fail and averaged as `pass@1`.

## AA-Style Eval Runner

This repository keeps upstream task manifests unchanged. AA-specific evaluation policy is stored in [`aa_eval.yaml`](aa_eval.yaml), and the generic wrapper lives in [`scripts/eval.py`](scripts/eval.py).

Smoke-test the planned 84-task / 3-repeat matrix without running an agent:

```bash
./scripts/run_eval.sh --dry-run
```

Run a real evaluation by providing a command that executes one task attempt and exits with `0` on pass and non-zero on fail:

```bash
AA_RUNNER_COMMAND='my-tb2-runner --task-dir {task_dir} --task-id {task}' \
  ./scripts/run_eval.sh
```

The wrapper records one JSONL row per task-repeat attempt and writes `summary.json` with the AA-style binary `pass@1` average. The public AA methodology specifies the 84-task subset, 3 repeats, and test-suite pass/fail scoring; it does not publish a TB2-specific source commit or additional episode/token limits.

## Artifacts

- `artifacts/aa_terminal_bench_2_tasks.txt`: the 84 tasks listed by Artificial Analysis.
- `artifacts/terminal_bench_2_official_tasks.txt`: the 89 upstream tasks at the pinned source snapshot.
- `artifacts/excluded_tasks.txt`: the five upstream tasks absent from the AA list.
- `artifacts/task_metadata.tsv`: included task metadata extracted from `task.toml`.
- `artifacts/difficulty_summary.tsv`: included task difficulty counts.
- `artifacts/excluded_task_metadata.tsv`: metadata for the five excluded upstream tasks.
- `artifacts/redacted_files.txt`: public-hosting redaction exceptions.

## Reproduction

Run:

```bash
./scripts/reproduce.sh
```

The script compares the checked-in task lists with the pinned upstream snapshot, validates the 89/84/5 counts, and byte-compares the included task directories against upstream except for the documented redacted fixture.

To re-fetch the currently published Artificial Analysis task list:

```bash
python3 scripts/fetch_aa_task_list.py
```

The live Artificial Analysis page can change. The checked-in artifacts are the pinned reconstruction used for this repository.

## License

The copied Terminal-Bench 2 task files retain the upstream Apache-2.0 license. See `LICENSE`.
