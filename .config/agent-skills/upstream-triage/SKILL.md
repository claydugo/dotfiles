---
name: upstream-triage
description: Re-evaluate the cases under ~/issue_tracking. Punt what upstream already fixed, bring open cases to the upstream-issue bar, record what happened to filed cases, and publish a scored report.
argument-hint: [package or case path]
disable-model-invocation: true
---

Run on every case under `~/issue_tracking`, or on the cases the argument names. Never file, comment, push, or propose backports.

## Per case

The case files are hypotheses. Derive each status again from upstream at the latest default-branch commit.

- Filed: fetch the issue and PR. Add the outcome to `~/issue_tracking/calibration.md`: predicted merge likelihood, labels, review comments, rounds to merge, merged or closed. When a review comment shows a pattern that the upstream-issue skill misses, propose an edit to that skill.
- Fixed upstream: punt with the fix commit and the first release tag that contains it.
- Usage error, or no defensible fix: punt with the reason.
- Open: list its gaps against the upstream-issue skill. Give each open case to its own subagent, in parallel, with that list.

## Verify independently

Do not accept a returned case on its word. For each open case:

- run the repro text from `issue.md` in an empty directory on the newest build or nightly;
- run the differential sweep against the reference again;
- apply `fix.patch` to a clean worktree, and run the regression test and the project's lint;
- compare `issue.md` and `pr.md` with the live templates and with the merged analogs;
- run the project's automated PR review on the patch, if the repo includes one.

Fix what fails, or send the case back with the failure.

## Report

Publish one artifact. For each case, give the landing (file or punt) and the reason.

Give your own assessment, 1 to 10, of severity, patch minimalness, patch correctness, how well the issue format matches issues that led to a merge, and maintainer likelihood to press merge with no feedback. Anchor severity to the project's own priority labels. Aim for 10 in each column: fix what blocks a 10 before you report. For each score below 10, give the evidence, the reason, and whether anything other than upstream CI or the user can still close it. Use `calibration.md` to correct optimism.

For each case to file, also answer: do the maintainers care about this defect, or will they read it as user error? Cite how other backends or implementations behave and the merged fixes of the same class.

Add the submission walkthrough for each project in the order to run it, and a list of every issue, PR, and commit used, as links. Name each scratch directory kept, with its size, and stop background processes that you started.