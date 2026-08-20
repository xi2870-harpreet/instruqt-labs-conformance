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
