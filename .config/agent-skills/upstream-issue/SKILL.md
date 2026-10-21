---
name: upstream-issue
description: Prepare an upstream issue draft, reproducer, patch, and assessment when a dependency bug blocks the requested solution.
---

## Parent

Spawn one subagent on the next lower model class in the same family, with a fresh context. Pass it this skill, the applicable user instructions, the blocked requirement, the environment, the failure evidence, and what you already tried. The subagent runs the whole investigation without further delegation.

Continue independent work meanwhile. When it returns, review the artifacts for accuracy and edit `issue.md` until it stands alone. Link the case from existing progress notes. The investigation does not resolve the parent blocker.

## Investigation

Work locally. Do not publish anything or change the parent project or its environment. Preserve user edits.

Resume an existing case for the same repository and defect, or create `~/issue_tracking/<upstream_package>/<YYYYMMDD>_<issue>/`. Write the status and next action to `assessment.md` first so an interrupted case can resume. The case holds only the deliverables. Put source copies, builds, and caches in scratch space, record its path in the assessment, and remove the disposable files at the end.

Rule out user error first: check the calling code against the installed version's documented behavior. If usage explains the failure, write `assessment.md` as one paragraph with the cause, the corrected call, and its validation result, then return.

Otherwise, search upstream issues and PRs for duplicates and existing fixes, and read the contribution guide and issue template. Use the official clone under `~/git/upstream/` when it exists. With Git authorization, clone it if absent, or update an idle, clean default branch with `git pull --ff-only`. Work in a scratch copy of the latest default branch commit and record that commit.

Distinguish observed results from inference in every artifact.

### `issue.md`

Model it on https://github.com/pydata/xarray/issues/11539. A maintainer with no parent context must be able to reproduce and assess the defect from it alone.

- First line: `File at: <url>`, the new-issue URL with the template selected, or the existing issue or PR for a duplicate. Give a reason when the destination is not the obvious repository.
- Then `# <title>`: the failing behavior, with the upstream API in backticks.
- Use the template headings verbatim, checkboxes included.
- State the symptom, then the mechanism in one or two sentences. Back each claim about upstream code or docs with a permalink at the base commit.
- Under expected behavior, also name the nearby case that must keep failing.
- The example uses upstream packages only. It is one self-contained script with inline dependencies (PEP 723 for Python) and upstream pinned to its default branch, followed by the full error output.
- Close with the fix in one sentence, an offer to open a PR, and links to related issues.
- Give the environment as the project's own version report inside `<details>`.

Save the example script in the case and run it from an independent directory. For a duplicate, draft only a useful addition. If no upstream action is warranted, skip the issue.

### `fix.patch`

The smallest fix against the base commit. Put the regression test in the existing upstream test file that covers the changed code, in the style of its neighbors, so the patch matches how upstream organizes tests. Verify that the test fails for the reported reason before the fix and passes after it. Run upstream's linters, include new files in the patch, and check it with `git apply --check` on a clean base. If upstream already fixes the defect or no defensible fix exists, omit the patch and say why.

### `assessment.md`

Keep current findings only, each fact once. Open with:

1. **Confidence**: why the defect is real and the fault is upstream, not our usage. Cite the documented contract the calling code follows.
2. **Verification**: rate the reproducer 1 to 10 (10 is minimal, self-contained, and correct) and explain lost points. Give the commands and results that show which source runs, that the reproducer fails on the latest default branch commit (name it), that the patch is minimal and correct, and that the regression test fails before the fix and passes after (name its preexisting test file).
3. **Merge likelihood**: rate 1 to 10 the chance a maintainer merges the patch with no nits. Below 10, list each remaining or potential issue.

Then give the status, next action, blocked requirement, parent path and revision, upstream URL, source path, base commit and when you checked it, affected versions, contribution requirements, whether the patch applies to the parent's dependency version, any workaround with its tradeoffs, and unresolved limits.

If progress needs unavailable resources or a design decision, save the partial result and name what is missing. Return the case path, diagnosis, validation limits, and next action to the parent.
