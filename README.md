# Instruqt Labs HCL conformance probe

A throwaway lab that exercises documented Instruqt 2.0 HCL features to surface
discrepancies between https://docs.labs.instruqt.com and the shipping CLI /
runtime.

It deliberately contains constructs that **pass `instruqt lab validate` but are
wrong**, so that running it shows what the runtime actually does:

- a `virtual_browser` used as a layout tab target
- a `container` used as a layout tab target
- a `task` with zero `condition` blocks

See the findings write-up that accompanies this repo.
