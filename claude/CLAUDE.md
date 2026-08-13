# Personal global instructions

## Freeing disk space without losing downloaded dependencies (Bazel repos)

This applies to any large Bazel monorepo (e.g. dd-source) checked out on this
machine. The dependency graph is large enough that a full rebuild after a
cold cache can take a very long time. When disk fills up, **never** do
either of these — they discard content that would otherwise need a full
re-download/re-fetch over the network:

- `bazel clean --expunge` (or deleting an output_base's `external/` directory)
- deleting `~/Library/Caches/bazel` (the shared repository/disk cache used
  across all workspaces and worktrees on this machine)

Instead, reclaim space in this order — each step is pure garbage or
rebuildable output, not downloaded content:

1. **Check `df -h /` first**, then `git count-objects -vH` in the repo root.
   A large `size-garbage` value means stale `tmp_pack_*` files under
   `.git/objects/pack/` — leftovers from a `git fetch`/`push`/`repack` that
   was killed mid-operation (common when multiple worktrees/agent sessions
   hit the same clone concurrently). Confirm none are mid-write with
   `find .git/objects/pack -name 'tmp_pack_*' -mmin -10` (should be empty),
   then delete the rest: `find .git/objects/pack -name 'tmp_pack_*' -mmin +10 -delete`.
   Verify afterward with `git count-objects -vH` (`garbage: 0`) and a sanity
   `git status`/`git log`.
2. **Check for orphaned bazel output bases.** Each worktree/workspace path
   gets its own `/private/var/tmp/_bazel_$USER/<hash>` output_base. Cross-
   reference `ps aux | grep 'bazel('` (shows each live server's
   `--output_base=`) against `ls /private/var/tmp/_bazel_$USER/`; any hash
   directory with no matching live process (e.g. from a worktree that no
   longer exists) can be removed — sandbox files are often read-only, so
   `chmod -R u+w <dir> && rm -rf <dir>`.
3. **Run `bzl clean`** (no `--expunge`) in an active workspace to clear its
   own `bazel-out`/execroot build outputs. This is pure recompilable output;
   it leaves `external/` (fetched deps) and the shared disk cache untouched.

Never touch an output_base that has a currently-running `bazel(...)` server
attached — another session may be actively using it.

## Pull request conventions

Applies to every PR Claude creates or reviews, in any repo, unless a
repo's own CLAUDE.md overrides it.

### Creating PRs
- PR title format: `[MARS-XXX]: <title>` — the Jira ticket key in brackets,
  followed by a colon and a short descriptive title. If there's no Jira
  ticket for the work, ask before dropping the prefix rather than guessing.
- Commit messages: short and descriptive (a single focused summary line,
  not a changelog) — one commit per logical change, not one giant commit
  per review round.
- PR descriptions: short and easy to understand — a couple of sentences
  or a few bullets on what changed and why, not an exhaustive essay. Do
  not hard-wrap lines in the body (no manual line breaks mid-paragraph);
  write each paragraph/bullet as one continuous line and let the
  renderer (GitHub, terminal, etc.) soft-wrap it — hard-wrapped text
  looks broken when rendered at a different width.
- **Before submitting (opening or pushing) any code**, in this order:
  1. Verify build succeeds (e.g. `bzl build`/`go build`, or the repo's
     equivalent), the relevant tests pass (e.g. `bzl test`/`go test` for
     the changed package(s) at minimum), and the code is formatted per
     the repo's tool (e.g. `gofmt`, `prettier`, `black`) with no diffs
     left unformatted. Fix failures at the root cause rather than
     skipping or disabling the check. If a failure is a known
     environment limitation (see **CI failure triage** below) rather
     than a real bug, say so explicitly instead of silently ignoring it.
  2. Send the diff to a second agent (via the Agent tool,
     `subagent_type: code-reviewer` if available, otherwise
     `general-purpose`) for an independent review pass. Brief it to:
     (a) look for simplifications — dead code, needless abstraction,
     over-engineering — without dropping functionality, (b) confirm no
     existing behavior was lost or broken, and (c) explicitly check the
     diff against the **Common review-round patterns** list below —
     these are the recurring classes of P0/P1/P2 comments that cause
     extra review rounds, so a self-check pass catches most of them
     before a human/bot reviewer has to.
  3. Apply its actionable feedback (or explain why not), then re-run
     step 1 if the fix touched code, before opening/pushing.

  Skip steps 2–3 only for trivial one-line/mechanical changes, or if
  the user explicitly says to skip it for this task. Step 1 (build/
  test/format) is never skipped.

### Large changes — stack with Graphite instead of one big PR

- If a change is large enough that it would be hard to review in one
  pass, or naturally decomposes into ordered steps (e.g. add a new
  field → migrate callers → remove the old field; or scaffold → wire
  up → implement), break it into a **stack** of small PRs using
  Graphite (`gt`) rather than one large PR or a pile of independent
  PRs with manual merge-order coordination.
- Typical flow: `gt create` for each logical step on top of the
  previous branch, `gt submit --stack` (or `gt stack submit`,
  depending on the installed `gt` version — check `gt --help` if
  unsure) to open/update all PRs in the stack at once, `gt sync` after
  the bottom of the stack merges to restack the rest on the new trunk.
- **Each PR in the stack must build and pass tests on its own**, using
  only what's landed in it and the PRs below it — not by assuming a
  later PR's code already exists. This is the actual failure mode
  being avoided: a middle PR that only compiles/passes once a PR above
  it in the stack is also merged is not really independently
  mergeable, and blocks/breaks anyone who merges the stack out of
  order or partially. If a step genuinely can't stand alone (e.g. a
  caller must exist before a new required field can be added), keep it
  in the same PR rather than splitting further, or land it behind a
  no-op default that doesn't require the follow-up in place.
- Keep the stack's PR titles/branches clearly ordered (e.g. via the
  `[MARS-XXX]: <title>` convention above, with a consistent step
  suffix like `(1/3)`) so reviewers and `gt log` make the merge order
  obvious.
- Apply all the same per-PR rules in this section (build/test/format,
  second-agent review, description conventions) to *each* PR in the
  stack individually, not just the stack as a whole.

### Common review-round patterns to self-check

Recurring classes of feedback that have shown up repeatedly across
review rounds — check the diff against these explicitly (in step 1 or
2 above) rather than waiting for a reviewer to catch them:

- **Decoders/parsers must reject unconsumed trailing data.** Anything
  that decodes one value from a byte/string buffer (`json.Decoder`,
  Avro `NativeFromBinary`, custom binary unpacking, etc.) can silently
  leave bytes unread on a truncated/corrupted/concatenated payload. If
  the API exposes a "bytes remaining" / "more data" signal, check it
  and error out — don't assume "decoded without error" means "the
  whole input was valid."
- **Tests must assert on the real value, not a stand-in.** Don't
  construct a fresh comparison value (`errors.New("...")`, a literal)
  that merely looks like what's expected — assert on the actual
  variable returned by the code under test. A test that can pass
  whether or not the code is right is worse than no test.
- **Prefer structural/deep equality over partial checks in tests**
  (e.g. `len(map) == len(map)`, checking one field of a struct) unless
  there's a specific reason a partial check is stronger — a length- or
  field-only check passes on wrong contents.
- **Enumerate every state explicitly in state machines / multi-state
  checks** (circuit breakers, retry states, connection states, etc.).
  A binary check like `if state != X` silently lumps every other state
  together with the "good" one — verify each state gets the treatment
  it actually needs, not just the two the author was thinking about.
- **Never let customer/user-controlled data reach logs or error text**
  that flows to a shared logger, even indirectly through a wrapped
  error. When there's no safe structured alternative (e.g. an error
  code), prefer full redaction (a static message) over partial/regex
  redaction — partial redaction is easy to get wrong and easy for a
  reviewer to poke a hole in.
- **New tests that need infra (containers, DBs, network) must be wired
  into CI, not just runnable locally.** Verify the CI config (tags,
  provider extensions, required services) matches what an existing,
  working test target in the same repo uses — a test that only runs
  locally is invisible to CI until it's already merged.
- **When editing a doc/instructions file, grep the whole file for
  related statements before submitting**, not just the section being
  changed — a new option/exception can silently contradict an
  unrelated rule stated elsewhere in the same file.
- **K8s probe/readiness budgets must scale with loop iteration counts,
  not assume a fixed default.** If startup does N sequential per-item
  operations each with its own timeout (e.g. per-index schema
  propagation, per-topic initialization), the `startupProbe`/
  `livenessProbe` failure threshold and period must be derived from
  `N * per_item_timeout` (plus fixed overhead), not left at a default
  that only covers the 1-item case — this recurred as multiple separate
  comments on the same PR before being generalized once.
- **Don't let a shared timeout/context silently lose budget to
  preliminary work.** If a timeout is documented as "the budget for
  operation X," and the code does other calls (a status check, a
  create call) before starting X using the *same* context, those calls
  eat into X's budget invisibly. Give each logical wait its own
  deadline, or derive it by adding the preliminary calls' cost rather
  than reusing the outer deadline verbatim.
- **When renaming/removing a config field, migrate every fixture that
  references the old shape, not just production code.** Search for the
  old field name across lint fixtures, test data, example configs, and
  docs (`grep -r <old_field_name>`) — a stale fixture using removed
  fields often doesn't fail loudly, it just silently tests nothing
  (e.g. an empty range) while looking green.
- **Validate uniqueness/collision invariants explicitly and fail fast**
  when a mapping/routing step could let two distinct inputs collapse
  onto the same output key (e.g. two topics deriving the same table
  name). Silently overwriting one with the other is a data-loss bug
  that won't show up until production traffic exercises the collision.
- **Validate individual elements of externally-sourced config
  collections defensively** (a nil/empty entry in a parsed list/map
  from a ConfigMap, YAML file, etc.) — a malformed single entry should
  produce an actionable startup validation error, not a nil-pointer
  panic that crash-loops the pod.

### Reviewing / addressing PR feedback
- Address every open review comment — don't silently skip ones that seem
  minor or debatable; if a suggested change is wrong or a false positive,
  say so in the reply rather than ignoring the thread.
- After fixing (or explaining why no fix is needed) reply directly on
  each comment thread explaining what was done.
- Once a thread has been replied to and the fix is pushed, resolve/close
  that review thread — don't leave addressed threads open. This is a
  separate action from replying: a `gh api .../pulls/<n>/comments -f
  in_reply_to=<id>` reply does NOT mark the thread resolved by itself.
  Resolve it explicitly via the GraphQL mutation, using the thread's
  `thread_node_id` (the `PRRT_...` id, not the numeric comment id):
  `gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:
  {threadId:$id}){thread{isResolved}}}' -f id="<PRRT_...>"`. After a
  push, re-fetch the thread list and check `resolved`/`outdated` per
  thread before assuming replying was enough — some bots (e.g. Datadog
  Autotest) auto-resolve on their own re-scan, but others don't, so verify
  rather than assume either way.
- Once every thread from the current round is resolved and the fixes are
  pushed, comment `@datadog review` on the PR to trigger another Autotest
  pass — don't wait for the next push to be the trigger; an explicit
  re-review comment after a full round of fixes catches anything the
  fixes themselves introduced or missed, before a human reviewer looks again.

### After the PR is merged
- Confirm the merge (e.g. `gh pr view <n> --json state,mergedAt` or
  `gh pr status`) before cleaning anything up.
- If the work was done in a `git worktree` (see **Use worktrees for
  implementation work** below), remove it: `git worktree remove
  <path>` (add `--force` only if it has no uncommitted changes worth
  keeping — check `git status` in the worktree first).
- Delete the local feature branch once merged and no longer needed:
  `git branch -d <branch>` (from the main checkout, not the worktree
  being removed).
- Prune stale remote-tracking refs: `git fetch --prune` (or `git remote
  prune origin`).
- For Bazel repos, if disk space is actually tight, follow the
  **Freeing disk space** section above (`bzl clean`, orphaned output
  bases) rather than anything destructive to the fetched dependency
  cache.
- Don't delete anything the user hasn't confirmed is merged, and never
  force-delete a branch/worktree with uncommitted work without checking
  first.

## CI failure triage

Never assume a CI failure is "just" a known/benign limitation (e.g. a
sandbox environment quirk) without first confirming the root cause via
real telemetry — Datadog CI/test-event search
(`search_datadog_ci_pipeline_events`, `search_datadog_test_events`) or
equivalent, not guesswork from a truncated pasted log. Two superficially
identical-looking failures can have different root causes (e.g. a real
build/lint error vs. missing CI infra wiring vs. the actual known
limitation) — verify each one, even if a previous failure in the same
run turned out to be benign.

## `gh` CLI multi-account repos

If `gh` fails to resolve a repo/PR ("Could not resolve to a Repository")
under the active account, don't retry the same command — some
repos/orgs only resolve under a specific logged-in account. Check
`gh auth status` for other logged-in accounts and switch with
`gh auth switch --hostname github.com --user <account>` before retrying.
This may need to be redone per-repo within the same session if work
moves between repos that resolve under different accounts.

## Use worktrees for implementation work

When implementing a feature or fix (not just exploring/reading), use
`git worktree add` to create an isolated worktree rather than working
directly on the current checkout — keeps the main checkout stable for
other work and avoids collisions with in-progress branches.

### Verify the worktree/branch before running a deploy command

Before running any deploy-triggering command (`bzl run .../config/k8s:staging`,
`:staging-fast`, or any other CNAB/Conductor workflow target), confirm the
directory you're about to run it from is the worktree with the branch you
actually mean to deploy — not the primary checkout, which is often sitting on
`main` or a different, stale branch left over from earlier work in the
session. Deploy commands build and push whatever code is on disk at
invocation time, with no warning if that's the wrong branch — this
previously caused a real incident: a deploy was run from the primary
checkout (on `main`, pre-dating an open feature branch's fixes) instead of
the feature branch's worktree, silently shipping old code/config that then
crash-looped in a way that looked like a code bug but was actually just the
wrong commit being deployed.

Before every deploy command:
1. `pwd` and `git branch --show-current` (or `git -C <dir> ...` if not
   `cd`-ing) in the exact directory the command will run from — confirm both
   match the worktree/branch you mean to deploy.
2. `git log -1 --oneline` to confirm the expected commit is checked out,
   especially right after pushing new commits from a *different* worktree in
   the same session — it's easy to push from worktree A and then run the
   deploy from worktree B (or the primary checkout) out of habit.

If a deploy behaves unexpectedly (wrong config, stale behavior, an immediate
crash right after a rollout that should have fixed something), re-verify
which worktree/branch was actually used to build it before assuming the new
code itself is broken.

## Google Docs formatting

Applies to every Google Doc/tab Claude creates or writes into via the
`datadog-google-workspace` MCP tools, in any doc, unless that specific doc's
own existing style clearly establishes something different. Confirmed by
inspecting the actual paragraph/run styles of the "MDD-R-005" design doc
(not just its named-style defaults, which are misleadingly Arial) —
the doc's real, consistently-applied conventions are:

- **Font**: Roboto for all text (title, headings, body). Use Roboto Mono
  for inline code / code blocks specifically.
- **Body text alignment**: JUSTIFIED, not left-aligned.
- **Heading structure**: TITLE for the doc/section title, HEADING_1 for
  top-level sections, using the named-style default sizes as-is (Title
  26pt, Heading 1 20pt, Normal text 11pt) rather than manually overriding
  font sizes.
- Practically, when using `insert_markdown`: pass `font_family: "Roboto"`.
  That param does **not** set alignment — follow up with
  `update_paragraph_style` (`alignment: "JUSTIFIED"`) over the inserted
  range, or `style_paragraphs_matching`, as a separate step every time.
