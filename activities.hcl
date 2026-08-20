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

# probe: docs say one or more conditions are required; validate accepts zero
resource "task" "empty" {
  description = "Task declared with zero conditions"
  config {
    target = resource.container.box
  }
}

resource "single_choice_question" "q1" {
  question    = "Which resource type is NOT in the layout tab-target table?"
  answer      = "virtual_browser"
  distractors = ["terminal", "service", "note"]
  hints       = ["Check the layout reference."]
}

resource "multiple_choice_question" "q2" {
  question    = "Which of these are documented but unregistered resource types?"
  answer      = ["http", "image_cache"]
  distractors = ["container", "template"]
}

resource "quiz" "qz" {
  questions = [
    resource.single_choice_question.q1,
    resource.multiple_choice_question.q2,
  ]
  show_hints   = true
  show_answers = true
}
