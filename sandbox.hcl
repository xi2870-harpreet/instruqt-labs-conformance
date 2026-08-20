resource "network" "main" {
  subnet = "10.0.220.0/24"
}

resource "container" "box" {
  image {
    name = "ubuntu:24.04"
  }
  entrypoint = ["/bin/bash"]
  command    = ["-c", "sleep infinity"]
  network {
    id = resource.network.main.meta.id
  }
}

resource "container" "web" {
  image {
    name = "nginx:1.27"
  }
  port {
    local = 80
  }
  network {
    id = resource.network.main.meta.id
  }
}

# Utility resources - do they actually materialise at runtime?
resource "random_password" "pw" {
  length = 16
}

resource "template" "tpl" {
  source      = <<-EOT
    rendered-by-template: {{who}}
  EOT
  destination = "./out/template-result.txt"
  variables = {
    who = "instruqt"
  }
}

resource "copy" "cp" {
  source      = "./files/plain.txt"
  destination = "./out/"
}
