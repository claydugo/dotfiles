---
name: upstream-issue
description: Investigate a dependency bug that blocks the requested work. Produce a merge-ready upstream issue, patch, and PR draft, or a documented punt.
---

Goal: a maintainer reads the issue in under a minute, labels it actionable, and merges the PR with no review round. When upstream already fixed the defect or our usage causes it, the goal is a short documented punt.

## Parent

Spawn one subagent on the next lower model class with a fresh context. Give it this skill, the user's instructions, the blocked requirement, the environment, the failure evidence, and what you tried. Continue independent work. When it returns, run the acceptance checks yourself before you accept the case. The case does not resolve the parent blocker.

## Case

Use `~/issue_tracking/<package>/<YYYYMMDD>_<slug>/`, or resume the existing case for the same defect. Write the status and next action to `assessment.md` first. Put clones, builds, and caches in scratch space and record the path. Work locally: never file, comment, push, or change the parent project. Preserve user edits, but flag any edit that makes a draft wrong. Read and run upstream files from the user's checkout under `~/git/forks/<package>` or `~/git/upstream/<package>` when one exists, and do not modify it.

## Start from raw sources

Prior notes and summaries are hypotheses. Base each decision on:

- the upstream repo at the latest default-branch commit (record it): CONTRIBUTING, issue and PR templates, AI policy, merge rules, and any in-repo review automation;
- `git log -S` and blame of the lines you touch, and the merged PRs that changed them or fixed the same class of defect, with their review threads and approvers;
- the reference that the project treats as correct (another backend, the composite path, the spec);
- the behavior of a build of the base commit or the newest nightly, not the docs.

## Decide

1. Usage error: compare the call with the documented contract. If usage explains the failure, write one paragraph (cause, corrected call, validation) and stop.
2. Already fixed: name the fix commit and the first release tag that contains it. Punt. Do not propose backports.
3. Duplicate: draft only a comment that adds information.
4. Otherwise fix it. Give each independent upstream cause its own case.

## Prove it

- Reproduce from an empty directory on the newest default-branch build or nightly. Run unbuffered so output before a crash survives, and paste the output as a user sees it.
- Run a differential sweep of the patched build against the reference over the product of the inputs that matter (dtypes, layouts, optional arguments, `out=`). It must reject exactly what the reference rejects and compute the same values elsewhere. Run the sweep on the unpatched build too, so you know which cases the patch changes.
- The regression test fails for the reported reason before the fix and passes after. The neighboring tests pass.
- Run the project's own lint entry point and `git apply --check` on a clean worktree.
- Run the project's version report script, unmodified, on the standard build that ran the repro. Paste its output with nothing added or removed. Each version named in the drafts matches a run.
- For a regression, narrow the version range or bisect.
- Each claim in `issue.md` and `pr.md` has a measurement in `assessment.md`. Without a measurement, remove the claim.

## Shape it like what merges

Read three to five merged analogs from the likely reviewer. Match their check style, error strings, test file and test name, title prefix, body length, tone, and AI disclosure. Write the shortest casual form that lets a maintainer act. For template sections reserved for humans, put a short draft in the submission notes for the user to rewrite, and leave the section itself empty. Take the trigger that hit us from the parent work and name only its public parts (the upstream model or library, not ours). If the parent context does not show the trigger, ask the user. Never name internal projects, hosts, or private links.

## Deliverables

- `issue.md`: a `File at: <url>` line, `# <title>`, then the template fields verbatim. Give the symptom, the trigger that hit us in one sentence, a minimal plain repro and its output, one permalink for the mechanism, a one-line fix offer, a one-line AI note, and the version report in `<details>`.
- `fix.patch`: the smallest change, with the test in the existing test file for that code.
- `pr.md`: submission notes, a `---` line, then the filled PR template and a commit message. The notes give the exact steps for a first-time contributor: file order, the gating label to wait for, the draft and ready commands (`gh pr create --draft --body-file` with the notes removed), CLA, and the drafts for the human-only sections.
- `reproducer.*`: each repro as a runnable file.
- `assessment.md`: Confidence, Verification (commands, results, base commit), and Merge likelihood 1 to 10 with each risk. Then the status, next action, submission process (gating labels, draft rules, CLA, CI labels), analogs consulted, affected versions, workaround, and limits. Keep current facts only.

## Acceptance checks

Run the repro text from `issue.md` verbatim in an empty directory. Run the differential sweep again. Compare each draft with the live template. Check each claim against the assessment. Return the case path, the landing, and the steps left for the user.
