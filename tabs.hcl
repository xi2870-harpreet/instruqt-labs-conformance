resource "terminal" "shell" {
  target = resource.container.box
  shell  = "/bin/bash"
}

resource "service" "webui" {
  target = resource.container.web
  port   = 80
  scheme = "http"
}

resource "note" "hints" {
  file = "notes/hints.md"
}

resource "external_website" "ext" {
  url                = "https://example.com"
  open_in_new_window = true
}

# EXPECTED-BROKEN probes -------------------------------------------------
# Both validate today. Neither is in the layout reference's tab-target table.
resource "virtual_browser" "vb" {
  url = "https://example.com"
}
