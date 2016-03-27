class Hole
  constructor: (n) ->
    @number = n
    @element = document.getElementById("hole" + n)
    @rownum = parseInt(@element.parentNode.id[3]);
    @filled = false;
    @pieceNum = 0
    @owner = "hole"

  getTouching: (holelist) ->
    e = @number
    r = @rownum
    result = []
    for num in [e+r-1,e+r,e-r-1,e-r]
      otherhole = holelist[num]
      result.push(otherhole) if otherhole? and (otherhole.rownum == r-1 or otherhole.rownum == r+1)
    for num in [e-2,e]
      otherhole = holelist[num]
      result.push(otherhole) if otherhole? and otherhole.rownum == r
    return result
  fill: (player, num) ->
    @element.classList.add("piece-"+num, "filled", player)
    @pieceNum = num
    @owner = player
    @filled = true
  clear: () ->
    @element.classList.remove("piece-"+@pieceNum, "filled", @owner,"sucked","blackHole")
    @pieceNum = 0
    @owner = "hole"
    @filled = false
  suck: () ->
    @element.classList.add("sucked")
  blackhole: () ->
    @element.classList.add("blackHole")

class Game
  constructor: () ->
    @arena = document.getElementById("gamearea")
    @holes = []
    @holes.push(new Hole(i)) for i in [1..21]
    @pieces = {}
    @pieces[i] = [].slice.call(document.getElementsByClassName(i)) for i in ["p1", "p2"]
  reset: () ->
    @pieces[p][i].classList.add("inactive") for p of @pieces for i in [0...10]
    #hole.clear() for hole in @hole
  start: (first="p1") ->
    @reset()
    @first = first
    @currentplayer = first
    @turn = 0
    @setTurn(first)
    @arena.addEventListener "click", @clickCallback.bind(this)
    @loop()
    return true
  setTurn: (player) ->
    @arena.classList.remove("turnp1", "turnp2")
    @arena.classList.add("turn" + player)
    @currentplayer = player
  toggleTurn: () ->
    next = if @currentplayer == "p2" then "p1" else "p2"
    @setTurn(next)
    @turn += 1 if next == @first
    next
  clickCallback: (e) ->
    if e.target.classList.contains("hole") && @turn != "hole"
      @dropPiece(e.target)
      return true
    return false
  dropPiece: (target) ->
    h = @holes[parseInt(/\d{1,2}/.exec(target.id)[0])-1]
    unless h.filled
      @pieces[@currentplayer][@turn].classList.add("used")
      h.fill(@currentplayer, @turn+1)
      @toggleTurn()
      @loop()
  pickUpPiece: () ->
    @pieces[@currentplayer][@turn].classList.remove("inactive")
  blackHole: () ->
    @turn = "hole"
    bh = @holes.find (h) -> !h.filled
    bh.blackhole()
    h.suck() for h in bh.getTouching(@holes)
    values = bh.getTouching(@holes).reduce(((p,c) ->
      p[c.owner] += c.pieceNum
      return p), {"p1": 0, "p2": 0})
    values
  end: () ->
    v = @blackHole()
    m = "Left player won!" if v["p1"] < v["p2"]
    m = "Right player won!" if v["p1"] > v["p2"]
    m = "Tie game." if v["p1"] == v["p2"]
    alert m
  loop: () ->
    if @turn == 10
      @end()
      return true
    @pickUpPiece()
    return false
