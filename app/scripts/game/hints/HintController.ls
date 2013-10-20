require! { 'game/mediator' 'game/hints/Pointer' 'game/hints/AlertPointer' }

hint-types = pointer: Pointer, alert: Alert

id-counter = 1

timed-event = (e, t) ->
  <- set-timeoute _, t * 1000
  mediator.trigger e

module.exports = class HintController extends Backbone.Model
  defaults: hints: []

  hint-defaults:
    type: \alert
    target: \.player
    content: 'You forgot to add content to your hint!'
    enter: \time:1
    exit: \time:4
    enter-delay: 0
    exit-delay: 0
    side: false

  initialize: ->
    @hints = @get \hints

    [@setup hint for hint in @hints]

  setup: (hint) ->
    id-counter += 1

    HintController::hint-defaults.name = "hint-#id-counter"

    hint = _.defaults hint, HintController::hint-defaults

    view = new hint-types[hint.type] hint

    hint <<< {view}
    {enter, exit} = hint

    if 0 is enter.index-of \time:
      time = enter.split \time: .1 |> parse-int
      enter = "HintEnter#id-counter"
      timed-event enter, time

    <~ @listen-to-once mediator, enter
    do
      <- set-timeout _, hint.enter-delay * 1000
      hint-view.render!
      mediator.trigger "hint-#{hint.name}:enter"

    if 0 is exit.index-of \time:
      time = exit.split \time: .1 |> parse-int
      exit = "HintExit#id-counter"
      timed-event exit, time

    <~ @listen-to-once mediator, exit
    <~ set-timeout _, hint.exit-delay * 1000

    hint-view.remove!
    mediator.trigger "hint-#{hint.name}:exit"

  destroy: ~> [hint.view.remove! for hint in @hints]
