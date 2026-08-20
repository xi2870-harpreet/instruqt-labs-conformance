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

resource "single_choice_question" "q1" {
  question    = "Which resource type is NOT in the layout tab-target table?"
  answer      = "virtual_browser"
  distractors = ["terminal", "service", "note"]
  hints       = ["Check the layout reference."]
}

resource "quiz" "qz" {
  questions    = [resource.single_choice_question.q1]
  show_hints   = true
  show_answers = true
}

