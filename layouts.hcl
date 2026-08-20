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

    # ---- C1a REPRO -------------------------------------------------------
    # `container` is not a UI resource and is absent from the layout
    # reference's tab-target table, yet `instruqt lab validate` accepts this.
    # Effect on the platform: the Play button renders disabled, with no
    # tooltip, banner, console error, log event or network call explaining why.
    # ----------------------------------------------------------------------
    tab "t_container" {
      title  = "container as tab target"
      target = resource.container.box
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
