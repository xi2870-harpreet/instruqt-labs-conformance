# C1a — a `container` as a layout tab target silently disables Play

**Branch:** `repro/c1a-container-tab-target`
**CLI:** `2399-280cb75`

## The config

`layouts.hcl` contains a tab whose `target` is a `container`:

```hcl
tab "t_container" {
  title  = "container as tab target"
  target = resource.container.box
}
```

`container` is not a UI resource. The
[layout reference](https://docs.labs.instruqt.com/reference/content/layout)
restricts tab `target` to `terminal`, `service`, `editor`, `external_website`,
`note` and `cloud_credentials`.

## Step 1 — the CLI accepts it

```
$ instruqt lab validate
==> Validating lab...
    [SUCCESS] Lab is valid
```

## Step 2 — the platform disables Play, and says nothing

Import this branch as a lab and open its overview page. The **Play** button is
rendered `disabled`:

```js
> [...document.querySelectorAll('button')]
    .find(b => /^\s*Play\s*$/.test(b.textContent)).disabled
true
```

There is no explanation anywhere:

| Surface | Result |
| --- | --- |
| Tooltip on the button | none (`title` and `aria-label` are both `null`) |
| Error banner on the page | none |
| Text matching `error/invalid/cannot/failed` in the DOM | none |
| Browser console | no errors |
| Network on click | only a telemetry POST to `/rest/otel/v1/traces` |
| Logs UI (all severities) | no events |

## Isolation

Bisected on this repo. Only the `container` tab target flips Play:

| commit | layout contains | Play |
| --- | --- | --- |
| `dbbb265` | no probe tabs | enabled |
| `e9d2b95` | `target = resource.container.box` | **disabled** |
| `b8e03a5` | `target = resource.virtual_browser.vb` | enabled |

## Expected

Either `instruqt lab validate` rejects a tab `target` that isn't one of the six
supported UI types, or — if the platform is going to refuse the lab — the UI
states the reason. Silently disabling Play with no diagnostic on any surface
leaves the author with nothing to act on.

## Related

`virtual_browser` as a tab target is the sibling case: it also validates, the
lab plays, and the tab simply never renders. Tracked separately as C1b.
