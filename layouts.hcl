resource "layout" "tabs_probe" {
  column {
    width = "67"

    tab "t_terminal" {
      title  = "1 terminal"
      target = resource.terminal.shell
      active = true
    }

    # BISECT probe: virtual_browser is documented but absent from the tab-target table
    tab "t_vbrowser" {
      title  = "6 virtual_browser"
      target = resource.virtual_browser.vb
    }

    tab "t_extweb" {
      title  = "5 external_website"
      target = resource.external_website.ext
    }
  }

  column {
    width = "33"
    instructions {
      active = true
    }
  }
}
