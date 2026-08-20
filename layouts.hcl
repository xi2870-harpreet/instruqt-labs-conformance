resource "layout" "tabs_probe" {
  column {
    width = "67"

    tab "t_terminal" {
      title  = "1 terminal"
      target = resource.terminal.shell
      active = true
    }
    tab "t_service" {
      title  = "2 service"
      target = resource.service.webui
    }
    tab "t_editor" {
      title  = "3 editor"
      target = resource.editor.code
    }
    tab "t_note" {
      title  = "4 note"
      target = resource.note.hints
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
