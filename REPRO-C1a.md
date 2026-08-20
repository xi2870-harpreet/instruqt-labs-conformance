# C1a — `instruqt lab validate` misses a tab-target type error the platform catches

**Branch:** `repro/c1a-container-tab-target`
**CLI:** `2399-280cb75`

## The issue

The **platform validator behaves correctly here** — this is a CLI gap.

`layouts.hcl` contains a tab whose `target` is a `container`:

```hcl
tab "t_container" {
  title  = "container as tab target"
  target = resource.container.box
}
```

### The CLI accepts it

```
$ instruqt lab validate
==> Validating lab...
    [SUCCESS] Lab is valid
```

### The platform rejects it, with a good message

On the lab overview a warning icon appears next to the branch selector. Hovering
it shows:

```
Validation error
[error] layouts.hcl:1:1: target type "container" is not allowed for
"column[0].tab[2].target"
(resource: resource.layout.tabs_probe, field: column[0].tab[2].target)
```

Play is disabled, which is the right call.

## What should change

`instruqt lab validate` should apply the same tab-target type check the platform
already applies, so this is caught locally instead of after a push. The platform
message is exactly what the CLI should print.

## Correction

An earlier version of this file claimed the disabled Play button had no
explanation anywhere. **That was wrong.** The explanation is in a tooltip on the
branch-selector warning icon; it only enters the DOM on hover, which is why an
automated sweep of the page text, the button attributes, the console and the
network missed it. The platform surfaces this properly.

## Sibling case — tracked as C1b

`virtual_browser` as a tab target behaves differently and worse: the platform
validator raises **no** error, Play stays enabled, the lab runs, and the tab
simply never renders. See `repro/c1b-virtual-browser-tab`.
