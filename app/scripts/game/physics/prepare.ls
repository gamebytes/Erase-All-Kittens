require! {
  './Vector'
  './Matrix'
  './collision'
}

prepare-one = ->
  unless it.prepared
    it.prepared = true
    obj = it
    it.prepare = -> prepare-one obj
    it.destroy = -> obj._destroyed = true

    # Save ids:
    ids = ['*']
    if it.id then ids[*] = that
    if it.data?.id then ids[*] = that

    if it.el?
      if it.el.id then ids[*] = '#' + that

      for class-name in it.el.class-list => ids[*] = '.' + class-name

    it.ids = ids

    # Initialize velocity, position, and jump-frames (used to control height of jump)
    it.v = it.last-v = new Vector 0, 0
    it.p = new Vector it.{x, y}
    it.jump-frames = it.fall-frames = 0

    # Is this a sensor?
    if it.data?.sensor? then it.sensor = true else it.sensor = false

    # pre-calculate basic trig stuff
    unless it.rotation? then it.rotation = 0
    it.sin = sint = sin it.rotation
    it.cos = cost = cos it.rotation
    it.matrix = matrix = new Matrix cost, sint, -sint, cost

    # Player stuff:
    unless it.data? then console.log it

    if it.data?.player then it.handle-input = true

    # Find polygon:
    if it.type is 'rect'
      {width, height, x, y} = it
      hw = width / 2
      hh = height / 2
      it.poly = [
        new Vector x - hw, y - hh
        new Vector x + hw, y - hh
        new Vector x + hw, y + hh
        new Vector x - hw, y + hh
      ]

      # If rotated, rotate each point on the polygon accordingly:
      if it.rotation isnt 0
        it.poly = for point in it.poly
          # center on origin:
          c = point .min it.p

          # Apply rotation matrix, translate back to original position
          matrix.transform c .add it.p

    it.aabb = collision.get-aabb it

  it

prepare = (nodes) ->
  console.log 'prepare:', nodes

  # Map the nodes to their prepared versions.
  nodes = nodes |> map prepare-one

  sort-points = (obj) ->
    p = 0
    if obj.data?.player? then p -= 10
    if obj.data?.dynamic? then p += 1
    p

  nodes = nodes.sort (a, b) -> (sort-points a) - (sort-points b)

  dynamics = nodes |> filter -> it.data?.player? or it.data?.dynamic?

  {dynamics, nodes}

module.exports = prepare
