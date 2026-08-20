# Personal global instructions

## How to update this file

When adding a new rule/lesson to this file (whether asked to directly, or
inferred from a correction/confirmation during a session):

1. **Add the information** in the most specific relevant section — prefer
   extending an existing section/list over creating a new top-level one
   for a narrow addition, and link related content with cross-references
   ("see X above/below") the same way the rest of the file does.
2. **Read the whole file afterward**, not just the section touched — check
   for contradictions with unrelated rules stated elsewhere (the same
   discipline this file already asks for when editing any doc/instructions
   file), verify cross-references still resolve in the right direction
   after any reordering, and confirm the addition doesn't duplicate
   something already covered nearby.
3. **Commit and push** to this repo (`~/Documents/dev`, `claude/CLAUDE.md`
   — `~/.claude/CLAUDE.md` is a symlink to it) so the change is backed up
   and the working copy in `~/.claude/` stays live automatically.

Don't skip step 2 just because the edit looks small — several edits this
file has gone through were small individually but introduced a real
contradiction or a stale cross-reference that only showed up on a full
read.

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
     diff against the relevant **Common review-round patterns** list(s)
     below — the general one always, plus the Claude Code skill-authoring
     one if the diff includes a `SKILL.md`. These are the recurring
     classes of P0/P1/P2 comments that cause extra review rounds, so a
     self-check pass catches most of them before a human/bot reviewer has
     to.
  3. Apply its actionable feedback (or explain why not), then re-run
     step 1 if the fix touched code.
  4. Before actually running the commit/push, show the user a brief
     summary of what changed and why, then use `AskUserQuestion` (not a
     free-text question) with three options: **Yes, commit and push** /
     **Stop, don't commit** / **Let's discuss first** — rather than
     committing/pushing immediately. This applies to every commit/push,
     not just the first one in a PR; each subsequent round of fixes gets
     its own confirmation before it goes out.

  Skip steps 2–4 only for trivial one-line/mechanical changes, or if
  the user explicitly says to skip it for this task. Step 1 (build/
  test/format) is never skipped.

### Large changes — stack with Graphite instead of one big PR

- If a change is large enough that it would be hard to review in one
  pass, or naturally decomposes into ordered steps (e.g. add a new
  field → migrate callers → remove the old field; or scaffold → wire
  up → implement), break it into a **stack** of small PRs using
  Graphite (`gt`) rather than one large PR or a pile of independent
  PRs with manual merge-order coordination.
- **Always create every PR in a stack with `gt create` (one call per
  step, each run from the previous step's branch), never by manually
  `git checkout -b`/`git worktree add -b`-ing each branch off
  main/trunk by hand.** `gt create` sets the new branch's parent to
  whatever's currently checked out, so the stack's actual git ancestry
  matches the intended order automatically. Manual branch creation has
  no such guarantee — it's easy to branch step 2 off main instead of
  off step 1 without noticing, since both branches build and pass
  tests fine in isolation. This happened on the MARS-6868
  kafka-publisher stack (2026-08): PR 2 ("startup retry") was manually
  branched off main instead of off PR 1 ("circuit breaker"), so PR 2
  alone didn't inherit PR 1's readiness plumbing — surfacing later as
  an Autotest P1 finding ("pod stays ready during startup retries")
  that a real stack would have caught structurally, since gt would
  have carried PR 1's changes into PR 2 from the start.
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
- **When the same logical resource is provisioned/configured across
  multiple environments (DCs, clusters, tenants) in one batch, every
  environment-derived field must be independently re-derived for each
  one — never carried over by copy-pasting a sibling environment's
  already-finished config as the starting point for the next.**
  Confirmed as a real production incident: onboarding one Mongo cluster
  to `mars-mongo-jdbc-sink` in 5 different prod datacenters produced 5
  PRs that all shipped the identical (wrong) Kafka cluster, because
  each new DC's values file was copy-pasted from the previous DC's
  finished file and only the obviously-per-DC fields (k8s selector,
  namespace) got updated — the less obviously-per-DC fields (Kafka
  cluster/bootstrap servers, consumer group ID, target DB host)
  silently carried over untouched. When reviewing this kind of batch
  change, diff every environment-derived field across all files in the
  batch, not just the ones that look DC-specific at a glance.
- **A cross-environment "these must not match" check is only valid for
  fields structurally guaranteed to differ — don't apply it as a
  blanket rule to every field that's supposed to be re-derived per
  environment (see previous bullet).** Some derived fields (e.g. an
  environment-tier label that's legitimately `prod` in every production
  DC) can coincidentally share the same value across siblings without
  being wrong; a strict inequality check on those produces false
  positives that train people to ignore the check. This recurred twice
  on the same PR: a first fix correctly required a per-DC Kafka cluster
  field to differ across sibling files, then over-generalized to "no
  field should ever match another DC's file," which broke on a field
  that's correctly identical across every prod DC. The right check for
  a field that must be re-derived but can coincidentally match a
  sibling is "was this actually derived from this environment's own
  inputs," not "does it differ from every sibling."
- **A shape-based type-inference heuristic — guessing a value's real
  type from what it looks like, with no persisted type discriminator to
  check against — needs its safety precondition stated explicitly and
  verified against the real data before being enabled, not assumed safe
  by analogy to a previous use.** E.g. reconstructing a Mongo `_id` as
  an ObjectID when a string happens to parse as valid 24-hex-char hex,
  falling back to a plain string otherwise: safe only if none of that
  specific collection's genuine non-ObjectID ids could coincidentally be
  24 hex characters. Document the exact ambiguity on the heuristic
  itself (not just at the call site), and before enabling it for a new
  resource, run the concrete check (e.g. a length/format distribution
  query against the real data) rather than assuming a pattern that was
  safe for a previous resource still holds.
- **Validate individual elements of externally-sourced config
  collections defensively** (a nil/empty entry in a parsed list/map
  from a ConfigMap, YAML file, etc.) — a malformed single entry should
  produce an actionable startup validation error, not a nil-pointer
  panic that crash-loops the pod.
- **Keep code comments short and scannable — state the fact, not the
  narrative.** A comment should read like documentation a developer or
  agent encounters cold, not like a PR description or incident
  retrospective: cut the "why we discovered this" story, specific
  dates/incident references, and restated background already covered
  by the surrounding code or commit message. One or two lines beats a
  paragraph; if a comment needs multiple sentences to justify a
  non-obvious choice, that's a signal to trim it to the one sentence
  that actually matters for a future reader, not to keep the rest "for
  context." This is easy to violate in the middle of a debugging/review
  session, where the investigation narrative is fresh and feels worth
  preserving — it isn't; that narrative belongs in the commit message
  or PR description, not the comment. Concretely:
  ```go
  // BAD — restates the investigation, names a specific deploy/incident,
  // justifies at paragraph length:
  // isReady deliberately does NOT gate on the destination circuit
  // breaker or consecutivePingFailures, even though both are tracked
  // here and exported as metrics: with replicaCount 1 and no Service
  // in front of this Deployment, the only thing readiness actually
  // controls is rollout progression, and a destination outage affects
  // every replica identically (old and new alike). Gating on it risks
  // a new pod transiently reporting ready during the brief window
  // before its own ping-failure count crosses the threshold... which
  // is exactly what was observed in a real staging deploy of
  // mars-multidogs against eu1.staging.dog on 2026-08-19.

  // GOOD — one sentence, states the invariant, no narrative:
  // Deliberately ignores destination health (breaker/ping failures):
  // with 1 replica, gating readiness on it can let a rollout kill the
  // last healthy pod during an outage that affects both pods equally.
  ```
  If a second reviewing agent is run before opening/pushing (see above),
  have it explicitly check new/changed comments against this rule as
  part of that pass — it's the review step most likely to catch this,
  since the comment reads reasonably in isolation to whoever just wrote
  it.

### Common review-round patterns when writing Claude Code skills

A `SKILL.md` is a different artifact class from application code — check
the diff against these in addition to the general list above, whenever the
PR adds or edits a skill:

- **Scope every action to the specific resource requested, never "any
  real content."** When a shared file/installation can host multiple
  logical resources (e.g. multiple collections' mappings in one values
  file, multiple tenants in one config), state-detection and any
  destructive/cleanup action must check for the *specific* requested
  resource's own entry — never infer state from "the file has real
  content" or "the deployment is running" in general, or a cleanup
  action for one resource silently affects every other resource sharing
  the same installation.
- **Never let a skill declare a risky action "safe"/"verified" from a
  coarse proxy signal alone.** Row/document counts matching, or a status
  field reading `RUNNING`, are necessary but not sufficient — they can't
  catch wrong content, a stalled-but-technically-running process, or a
  subset of corrupted records. Either implement genuinely sufficient
  verification (real lag/offset metrics, content-level checks), or
  explicitly hand the "proceed anyway" decision to a human with the
  coarse evidence disclosed — don't let the skill assert a stronger
  conclusion than the evidence supports.
- **Every credential/secret a skill's deployed artifact depends on needs
  an explicit create-and-verify step, or an honest statement that none
  exists.** If a step grants a role/permission but doesn't also provision
  the resulting secret, and nothing else in the repo provisions it
  automatically, don't leave it implicit — give the exact, *verified*
  provisioning command, or say plainly this is a manual, non-self-serve
  gap and have the skill check-and-stop rather than assume it'll
  materialize before deploy.
- **Audit `allowed-tools` against the skill's own body — don't
  copy-paste a sibling's list.** Every command/tool actually invoked in
  the body must be covered by an entry (including `Read`/`Write`/`Edit`
  and `git` commands if the skill edits files or opens PRs), and every
  entry should be exercised somewhere in the body — unused entries
  inherited from another skill are dead weight and a discoverability/
  security smell.
- **`Bash` allowed-tools patterns match on literal command-string
  prefix, not token order or intent.** `Bash(kubectl get -n foo-* *)`
  matches `kubectl get -n foo-x pods`, but NOT `kubectl get pods -n
  foo-x` — write every command in the body in the same argument order as
  its matching pattern, and check by eye rather than assuming a
  "logically equivalent" command will match.
- **When a cleanup/decommission action's final state depends on a
  condition, resolve the condition before taking any irreversible step
  (merging a PR, deleting a resource) — never split the decision across
  a merged step and a "follow-up."** If the correction requires editing
  something already merged, the window in between is a real, live
  inconsistent state, not just an intermediate step.
- **Don't invent a plausible-sounding command/mechanism for a real
  capability gap.** If research doesn't turn up an existing, verified
  tool/workflow for a step (a secret sync, a lag query, an access
  grant), say so explicitly and either use the one genuinely verified
  alternative (e.g. an existing metric another skill in the same repo
  already references) or have the skill stop and hand off to a human —
  a specific-looking command that was never actually run is worse than
  an honest "unresolved" note, since it fails silently later instead of
  during review.
- **Skill frontmatter `description` must be third person** (platform
  skill-discovery convention) — `"Onboards..."`/`"Manages..."`, not
  `"Onboard..."`/`"Manage..."` — since the description field is what
  Claude matches against when selecting a skill.
- **Quote any frontmatter string field that might ever contain a colon**
  (`description`, `argument-hint`, etc.) — an unquoted YAML scalar breaks
  parsing the moment a `key: value`-shaped colon appears inside it (e.g.
  `description: Does X. Scope note: only for Y.` fails to parse; the
  colon after "note" starts a new, invalid mapping key). Quoting is cheap
  and makes the field robust against every future edit, not just today's
  wording — don't rely on "there's no colon in it right now."
- **When a resource can be provisioned but blocked partway through by a
  real external gap** (e.g. everything but a credential Secret exists),
  give that partial-progress state a name of its own (e.g.
  `BLOCKED_ON_CREDENTIAL`) that a status check can detect and resume
  from — don't let it collapse into "not onboarded" (which would restart
  already-done work) or "failed" (which undersells that the skill did
  everything it safely could). And when detecting it depends on some
  artifact (a config entry, a mapping) existing on disk, make sure the
  step that writes that artifact actually runs *before* the step that can
  block — checking a dependent condition (the blocking gap) ahead of the
  thing your own detection logic depends on makes the state unreachable.
- **Never commit an "enabled" config for a resource whose hard dependency
  (a credential, a required external grant) isn't confirmed yet.** If a
  step can't confirm a real prerequisite exists, commit the *safe default*
  (e.g. `replicaCount: 0`) rather than the eventual target value, and
  promote to the real value in a separate follow-up once confirmed — an
  unconfirmed-but-"enabled" config sitting on `main` can get applied by a
  totally unrelated future deploy of the same shared installation and fail
  for reasons that invocation had nothing to do with. Before assuming a
  toggle like this is safe to flip early, check whether the underlying
  field is genuinely per-resource or actually shared/pod-wide across every
  resource in that installation (e.g. one secret env var shared by every
  mapped topic) — that distinction is what determines whether "other
  entries already work, so the dependency must already be satisfied" is a
  valid shortcut or a dangerous assumption.
- **When a cheap status signal is ambiguous between two semantically
  different states, check the more authoritative signal first — never
  as a fallback branch reached only when the cheap signal is absent.**
  E.g. a `replicas: 0` Deployment can mean either "never successfully
  started" (blocked on a missing dependency) or "was active, then
  deliberately stopped" (decommissioned) — these require opposite
  responses (resume vs. leave alone). If a safe-default value (like the
  `replicaCount: 0` pattern above) can land on `main` before its
  dependency is confirmed, that ambiguity becomes reachable in
  practice, not just hypothetical. Structure detection logic so the
  authoritative check (does the dependency actually exist) runs before
  the cheap one is interpreted, not nested inside one branch of it.
- **For a multi-step resumable commit sequence (provision → grant →
  enable), the source of truth for "which step ran" is the committed
  config file, not the live runtime object.** A live Deployment/pod can
  lag the config (not deployed yet), or reflect a stale prior config
  (deploy hasn't picked up a just-merged change) — reading replica count
  or pod state to decide "has the enablement step run" answers a
  different question than "was the enablement commit merged." Check the
  config file's own field first to resume at the right step; only use the
  live object afterward, to confirm that config was actually applied.

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
- When asked to fix an issue by pushing a commit directly onto someone
  else's open PR branch (not your own), leave a PR comment immediately
  after pushing summarizing what changed and why — they didn't request
  the change and have no other way to notice a new commit silently
  appended to their branch. Applies whether the fix was requested by
  them directly, or on their behalf by someone else (e.g. a teammate
  who spotted the issue and asked you to fix it).

### After the PR is merged
- Confirm the merge (e.g. `gh pr view <n> --json state,mergedAt` or
  `gh pr status`) before cleaning anything up.
- If the work was done in a `git worktree` (see **Use worktrees for
  implementation work** below), first check whether a `bazel(...)`
  server is running against it: `ps aux | grep 'bazel('` shows each
  live server's `--workspace_directory=`/`--output_base=` pair on the
  same line, so either flag identifies it. If one is running, `cd`
  into the worktree and run `bazel shutdown` for a clean stop *before*
  removing the worktree — `git worktree remove` does not stop the
  server on its own, and once the worktree directory is gone you can no
  longer `cd` there for a graceful shutdown, only a plain `kill <pid>`
  (safe specifically because the worktree — and so any legitimate user
  of that server — no longer exists once removed). Left running, an
  orphaned server holds its full-size output_base (tens of GB)
  indefinitely until someone happens to notice and clean it up manually
  (see **Freeing disk space** above for reclaiming an output_base once
  its server is stopped). Then remove the worktree: `git worktree
  remove <path>` (add `--force` only if it has no uncommitted changes
  worth keeping — check `git status` in the worktree first).
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
other work and avoids collisions with in-progress branches. Exception:
when the work is a **stack** of PRs, create the branches with
`gt create` instead of `git worktree add -b` (see "Large changes —
stack with Graphite instead of one big PR" above) — a single worktree
checked out to whichever branch is the current stack tip is enough;
juggling one worktree per stack step defeats `gt create`'s "branch off
whatever's currently checked out" guarantee.

### Pull the base branch before creating a worktree

`git worktree add -b <branch> <path>` branches off whatever the local
checkout's base branch currently points to — if that hasn't been fetched
recently, the new branch (and its PR) silently starts hundreds or
thousands of commits behind the real remote base. This showed up as a PR
that "looked really old"/stale on GitHub despite a correct, intentional
diff. Always `git fetch origin <base-branch>` (or `git pull`) in the base
checkout immediately before `git worktree add`, not just at some earlier
point in the session. If a PR is later found to be based on a stale
commit, `git rebase origin/<base-branch>` in the worktree, re-run any
generated/snapshot-file regeneration (don't trust a conflict-free rebase
alone for auto-generated files — regenerate them fresh and diff), then
`git push --force-with-lease`.

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

## Cost management

Decided 2026-08-20 after investigating a real cost-tracking bug and
comparing self-estimated vs. org-billed spend (see `~/.claude/
statusline-tracking.sh`). Two of the four levers identified are config
(`~/.claude/settings.json`: `effortLevel: "medium"` instead of `"high"`,
`model: "sonnet"` instead of `"sonnet[1m]"`) — the other two are habits,
codified here so they persist across sessions:

- **Be selective about spawning subagents (Agent/Explore/Plan/Workflow).**
  Each one is a full separate model invocation with its own token cost —
  don't reach for one to answer something a quick, direct lookup (a single
  `grep`/`Read`/`Bash` call) would settle just as well. Reserve subagents
  for genuinely open-ended research, parallelizable independent work, or
  protecting the main context window from a large result set — not as a
  default first move for anything that touches more than one file.
- **Don't let a single session run indefinitely once the work in it is
  done.** A long-running session resends its whole (growing) context on
  every turn — real, recurring cost, not just an efficiency nitpick. When
  a piece of work is clearly finished and the next ask is unrelated, say so
  and suggest starting fresh (`/clear` or a new session) rather than
  silently continuing to pile unrelated context into the same one.

These are deliberate capability/cost tradeoffs the user chose knowingly —
don't revert to `effortLevel: "high"` or the `[1m]` context model for a
specific hard task without saying so first; escalate per-task instead of
changing the persistent default back.
