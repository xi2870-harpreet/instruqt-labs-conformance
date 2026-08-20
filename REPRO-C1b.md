# C1b — a `virtual_browser` tab target is accepted, then silently never renders

**Branch:** `repro/c1b-virtual-browser-tab`
**CLI:** `2399-280cb75`

## The issue

`layouts.hcl` declares three tabs:

```hcl
tab "t_terminal" { target = resource.terminal.shell }
tab "t_vbrowser" { target = resource.virtual_browser.vb }   # <-- never appears
tab "t_extweb"   { target = resource.external_website.ext }
```

Everything reports healthy:

- `instruqt lab validate` → `[SUCCESS] Lab is valid`
- No warning icon on the branch selector, **no Validation error tooltip**
- Play is enabled, the lab starts normally

And then the played lab renders **two** tabs, not three:

```
declared   t_terminal    t_vbrowser    t_extweb
observed   T_terminal    -- absent --  T_extweb
```

Nothing anywhere reports that a declared tab was dropped.

## Why this one matters more than C1a

For a `container` target the platform validator raises a clear error and
disables Play (see `repro/c1a-container-tab-target`). For `virtual_browser` it
raises nothing at all — the lab looks fine, ships, and a learner just never sees
the tab. An author following the instructions to "switch to the browser tab"
sends learners to something that does not exist.

## Docs contradiction

- [virtual_browser reference](https://docs.labs.instruqt.com/reference/sandbox/ui/virtualbrowser):
  "Add the virtual browser to a `layout` tab to surface it to learners."
- [layout reference](https://docs.labs.instruqt.com/reference/content/layout):
  the tab-target table lists `terminal`, `service`, `editor`,
  `external_website`, `note`, `cloud_credentials` — **not** `virtual_browser`.

One of those two pages is wrong, and the runtime currently matches neither: it
neither surfaces the tab nor rejects the config.

## Expected

Either render the tab, or reject it the way `container` is rejected — with a
Validation error naming the field. Silently dropping a declared tab is the worst
of the three options.

## Also seen in a real lab

Same behaviour in `instruqt-support/aws-cloud-account-lab-hp`: a chapter whose
layout declared an AWS-console `virtual_browser` tab alongside a credentials tab
rendered only the credentials tab, and the chapter's instructions referred
learners to the missing tab.
