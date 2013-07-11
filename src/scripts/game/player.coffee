DynamicBody = require "game/physics/dynamicBody"

Vector = Box2D.Common.Math.b2Vec2
b2WorldManifold = Box2D.Collision.b2WorldManifold

mediator = require "game/mediator"

module.exports = class Player extends Backbone.View
  tagName: 'img'
  className: 'player'

  initialize: (start = {x:0,y:0}, w, h) ->
    @el.src = '//s3-eu-west-1.amazonaws.com/somehats/web-platformer/at.png'
    @el.width = 40
    @el.height = 40

    @$el.attr "data-ignore", true

    console.log start

    @$el.css
      position: "absolute"
      top: h/2 - 20 + start.y
      left: w/2 - 20 + start.x

    shape =
      type: 'circle'
      x: start.x + w/2
      y: start.y + h/2
      radius: 20
      el: @el

    @body = new DynamicBody shape
    @body.isPlayer = true

    @setupKeyboardControls()

  setupKeyboardControls: ->
    torque = 5
    maxAngularVelocity = 15
    jumpImpulse = new Vector(0, -7)
    jumpLimit = Math.PI / 2

    left = false
    right = false
    up = false

    b = @body

    mediator.on "keydown:a,left", ->
      if not left
        left = true
        right = false

    mediator.on "keyup:a,left", ->
      if left
        left = false

    mediator.on "keydown:d,right", ->
      if not right
        right = true
        left = false

    mediator.on "keyup:d,right", ->
      if right
        right = false

    mediator.on "keydown:w,up,space", ->
      if not up
        up = true
        jump()

    mediator.on "keyup:w,up,space", ->
      if up
        up = false

    mediator.on "frame", =>
      acc = if left then -torque else if right then torque else 0
      av = b.angularVelocity()
      if (maxAngularVelocity > Math.abs av) or (acc / av < 0)
        b.body.ApplyTorque acc

    jumpa = Math.PI / 2 - jumpLimit
    jumpb = Math.PI / 2 + jumpLimit

    jump = ->
      edge = b.body.GetContactList()

      # Adapted from http://sierakowski.eu/list-of-tips/114-box2d-basics-part-1.html

      while edge isnt null
        manifold = new b2WorldManifold()
        edge.contact.GetWorldManifold manifold
        collisionNormal = manifold.m_normal

        # Check which fixture is the character, and flip normal if needed
        fix = edge.contact.GetFixtureB().GetBody().GetUserData()

        if fix.isPlayer is true
          collisionNormal.x *= -1
          collisionNormal.y *= -1

        angle = Math.atan2 collisionNormal.y, collisionNormal.x

        if jumpa < angle < jumpb
          b.body.ApplyImpulse jumpImpulse, b.body.GetWorldCenter()
          break

        edge = edge.next
