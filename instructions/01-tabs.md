# Tab target conformance

The layout for this page declares **seven** tabs. Count how many actually render.

| # | Tab | Target resource | In the docs' tab-target table? |
|---|-----|-----------------|-------------------------------|
| 1 | terminal | `terminal` | yes |
| 2 | service | `service` | yes |
| 3 | editor | `editor` | yes |
| 4 | note | `note` | yes |
| 5 | external_website | `external_website` | yes |
| 6 | virtual_browser | `virtual_browser` | **no** |
| 7 | container | `container` | **no** (not a UI resource) |

Tabs 6 and 7 both pass `instruqt lab validate`. If they do not appear above,
validation accepted a layout the runtime cannot honour.

<instruqt-task id="noop"></instruqt-task>
