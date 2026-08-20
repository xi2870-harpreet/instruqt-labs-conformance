resource "task" "noop" {
  description = "Confirm the sandbox is up"
  config {
    target = resource.container.box
  }
  condition "ok" {
    description = "Always passes - this page is about tab rendering"
    check {
      script = "scripts/task/noop/check.sh"
    }
  }
}
