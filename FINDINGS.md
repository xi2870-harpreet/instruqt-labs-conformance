# Instruqt Labs (HCL / 2.0) — docs & runtime conformance findings

Tested against `docs.labs.instruqt.com` with CLI `2399-280cb75`, team
`instruqt-support`, on 2026-08-20.

Method: every documented Basic/Full Syntax block was extracted from the
reference pages and run through `instruqt lab validate` in isolation against a
known-good minimal lab; constructs that validated were then run live to see what
the runtime does with them.

Severity key — **P1** blocks an author with no diagnostic, **P2** docs are wrong
so copy-paste fails, **P3** validation gap that bites later.

---

## A. Documented syntax the CLI rejects (docs are wrong)

### A1 — `aws_account` user references are list-indexed, not name-keyed  (P2)

The reference uses name-keyed access in **every** example:

```hcl
resource.aws_account.lab.user.student.access_key_id
```

The CLI rejects it:

```
resource contains invalid interpolated values: invalid list index: "student"
```

`user["student"]` fails identically. `for` expressions over the user list and
aliasing a user into a `local` both fail with `unable to decode body`. The only
working form is positional:

```hcl
resource.aws_account.lab.user.0.access_key_id
```

Impact: positional means adding a `user` block above an existing one silently
repoints every credential in the file. Affects
`/reference/sandbox/cloud/aws/account` (Basic Syntax, Credential Template
Integration, Multi-Region, and the `output` example) and
`/reference/sandbox/ui/cloud-credentials`.

### A2 — `lab` theme value in Full Syntax is invalid  (P2)

Docs Full Syntax says `theme = "modern_dark"`. CLI:

```
lab theme can only be one of: modern-dark, original
```

Underscore vs hyphen. `/reference/content/lab`.

### A3 — `container` has no `shell` argument  (P2)

`/configuration/sandbox` ("Sandbox Resources") shows:

```hcl
resource "container" "workstation" {
  image { name = "ubuntu:22.04" }
  resources { memory = 1024, cpu = 500 }
  shell = "/bin/bash"
}
```

CLI: `An argument named "shell" is not expected here.` `shell` belongs on
`terminal`, and the container reference correctly omits it — the two pages
disagree.

---

## B. Documented resource types that are not implemented

Sweep of every documented type for `not registered`:

### B1 — `http`  (P2)

Has a full reference page (`/reference/sandbox/utilities/http`) with Basic and
Full syntax, listed in the docs index. CLI:

```
unable to create resource: type http, not registered
```

### B2 — `image_cache`  (P2)

Same: `/reference/sandbox/utilities/cache/imagecache`, `type image_cache, not
registered`. Note `container_registry` (the sibling page's actual type name) IS
registered — the page titles "Registry"/"Registry Auth" don't match the HCL type.

All other documented types are registered.

---

## C. Validation gaps — accepted by `instruqt lab validate`, wrong

### C1 — layout tab `target` is not type-checked  (P1 / P3)

The layout reference restricts `target` to `terminal`, `service`, `editor`,
`external_website`, `note`, `cloud_credentials`. Validation enforces nothing.
Two cases confirmed, with **different and both-silent** failure modes:

**C1a — `container` as tab target makes the lab unplayable (P1).**
Validates clean. On the platform the **Play button is `disabled`**, with no
tooltip, no error banner, no console error, no log event, and no network call.
Nothing anywhere says why. Isolated by bisect:

| commit | layout contains | Play |
|--------|-----------------|------|
| `dbbb265` | none of the probes | enabled |
| `e9d2b95` | `target = resource.container.box` | **disabled** |
| `b8e03a5` | `target = resource.virtual_browser.vb` | enabled |

**C1b — `virtual_browser` as tab target is silently dropped (P1).**
Validates clean, lab plays, and the tab simply never appears. Confirmed in a
real lab: a chapter whose layout declared two tabs rendered one, and its
instructions referred learners to the missing tab.

Compounding docs issue: `/reference/sandbox/ui/virtualbrowser` says "Add the
virtual browser to a `layout` tab to surface it to learners" — which the layout
page's own target table contradicts. One of the two pages is wrong.

### C2 — `task` with zero conditions validates  (P3)

The task reference documents `conditions[]` as "one or more required".
A task with no `condition` block passes validation.

### C3 — `container` with no `image` block validates  (P3)

`image` is documented as required.

### C4 — `layout` with zero columns validates  (P3)

Produces a layout that cannot render anything.

---

## D. Runtime / diagnostics

### D1 — the lab loading screen stops updating and never lets you in  (P1)

**Root cause found. This is a frontend bug, not an infrastructure hang.**

Symptom: after clicking Play, the loading screen sticks at `Starting session...`
with the progress bar frozen (consistently around 18%) and never transitions to
`Enter lab`. It stays that way indefinitely — observed well past 4 minutes.
The Logs UI shows **no events at any severity**, because nothing is actually
wrong server-side.

The session is in fact fully provisioned and ready. Opening the same lab URL in
a **new browser tab** (or reloading) immediately shows the real state:
progress bar at 100% and an `Enter lab` button. Entering gives a working lab —
live terminal at `root@box:/#`, instructions rendered.

So the loading view stops applying progress updates and never learns the
session became ready. The learner is stranded on a screen that will never
advance, with no error and nothing in the logs.

Reproduced at commit `4079cca`: original tab frozen at `Starting session...`
~18% while a fresh tab on the identical URL showed `Enter lab`.

**Workaround for authors/learners:** reload the page.

#### Retraction of an earlier bisect

An earlier version of this document attributed the stall to lab configuration
and listed a bisect across `62fb584` → `0cb18ba` implicating the `quiz`
resource. **That conclusion was wrong and is withdrawn.** Every one of those
configurations starts correctly; each "stall" was the same stale loading screen,
and the apparent progress differences between commits were just different
snapshots of a frozen UI. `0cb18ba` was recorded as stalling and later started
fine with no code change at all, which is what exposed the real cause.

No lab-configuration finding should be drawn from that bisect. `template`,
`copy`, `random_password`, `editor`, `service`, `note`, `quiz` and the
zero-condition `task` are all exonerated as causes of the stall.

### D2 — `instruqt lab logs` is unauthorized for labs  (P3)

`instruqt lab logs instruqt-support/<lab>` returns `Unauthorized / Unable to
find lab` with a CLI session that can pull tracks and validate labs. The web
Logs UI works for the same user, so the CLI path appears to be missing the
labs scope.

---

## E. Verified working (no action needed)

Worth recording so these aren't re-tested:

- Activity wiring is validated **bidirectionally** — an `activities` entry with
  no matching `<instruqt-task id>` in the markdown errors, and a markdown tag
  with no `activities` entry errors. Good, precise messages.
- Missing `page.file`, `note.file`, and task `check.script` files all error clearly.
- `aws_account` user with neither `managed_policies` nor `iam_policy` errors,
  matching the documented note.
- Validated as documented: all four quiz question types and `quiz`;
  `variable` / `local` / `output`; `random_password` / `random_id`;
  `copy` (local + URL); `template` (file + heredoc); `secret`; `note`;
  `editor` (local dir + container target); `sidecar`; `vm`; `kubernetes_cluster`;
  `ingress`; all three `exec` modes; container `health_check` / `port_range`;
  `jsonencode` / `upper` / `format` / `file` / `env` functions.
- `network { id = ... }` accepts both `resource.network.main.meta.id` and the
  bare `resource.network.main`. Docs use both forms in different places; both
  work, so it's cosmetic.

### D3 — layout tab `title` is ignored at play  (P2)

A layout tab renders its **internal block name**, not its `title`:

```hcl
tab "t_terminal" {
  title  = "1 terminal"      # ignored
  target = resource.terminal.shell
}
```

The played lab shows `T_terminal`. Confirmed for `terminal` and
`external_website` targets, so it is not specific to `note` tabs.

Already reported against `note` tabs by an Airlock customer on 2026-08-19; this
widens the scope to tabs generally.

