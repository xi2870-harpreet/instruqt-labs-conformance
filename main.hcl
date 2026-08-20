resource "page" "tabs" {
  title = "Tab target conformance"
  file  = "instructions/01-tabs.md"
  activities = {
    noop = resource.task.noop
  }
}

resource "page" "activities" {
  title = "Activity conformance"
  file  = "instructions/02-activities.md"
  activities = {
    qz    = resource.quiz.qz
    empty = resource.task.empty
  }
}

resource "lab" "main" {
  title       = "Instruqt Labs HCL conformance probe"
  description = "Exercises documented HCL features to surface docs/runtime discrepancies."

  settings {
    timelimit {
      duration   = "1h"
      show_timer = true
    }
  }

  layout = resource.layout.tabs_probe

  content {
    chapter "tabs" {
      title = "Tabs"
      page "tabs" {
        reference = resource.page.tabs
      }
    }
    chapter "activities" {
      title = "Activities"
      page "activities" {
        reference = resource.page.activities
      }
    }
  }
}
