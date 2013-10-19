require! mediator

/*

  Blur based on:

StackBlur - a fast almost Gaussian Blur For Canvas

Version:  0.5
Author:   Mario Klingemann
Contact:  mario@quasimondo.com
Website:  http://www.quasimondo.com/StackBlurForCanvas
Twitter:  @quasimondo

In case you find this class useful - especially in commercial projects -
I am not totally unhappy for a small donation to my PayPal account
mario@quasimondo.de

Or support me on flattr:
https://flattr.com/thing/72791/StackBlur-a-fast-almost-Gaussian-Blur-Effect-for-CanvasJavascript

Copyright (c) 2010 Mario Klingemann

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
mul_table = [
  512,512,456,512,328,456,335,512,405,328,271,456,388,335,292,512,
  454,405,364,328,298,271,496,456,420,388,360,335,312,292,273,512,
  482,454,428,405,383,364,345,328,312,298,284,271,259,496,475,456,
  437,420,404,388,374,360,347,335,323,312,302,292,282,273,265,512,
  497,482,468,454,441,428,417,405,394,383,373,364,354,345,337,328,
  320,312,305,298,291,284,278,271,265,259,507,496,485,475,465,456,
  446,437,428,420,412,404,396,388,381,374,367,360,354,347,341,335,
  329,323,318,312,307,302,297,292,287,282,278,273,269,265,261,512,
  505,497,489,482,475,468,461,454,447,441,435,428,422,417,411,405,
  399,394,389,383,378,373,368,364,359,354,350,345,341,337,332,328,
  324,320,316,312,309,305,301,298,294,291,287,284,281,278,274,271,
  268,265,262,259,257,507,501,496,491,485,480,475,470,465,460,456,
  451,446,442,437,433,428,424,420,416,412,408,404,400,396,392,388,
  385,381,377,374,370,367,363,360,357,354,350,347,344,341,338,335,
  332,329,326,323,320,318,315,312,310,307,304,302,299,297,294,292,
  289,287,285,282,280,278,275,273,271,269,267,265,263,261,259];

shg_table = [
  9, 11, 12, 13, 13, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17,
  17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19,
  19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20,
  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22,
  22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
  22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 23,
  23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23,
  23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23,
  23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23,
  23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
  24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
  24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
  24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
  24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24 ];

blur = (img, radius) ->

  {width, height} = img

  pixels = img.data
  x = undefined
  y = undefined
  i = undefined
  p = undefined
  yp = undefined
  yi = undefined
  yw = undefined
  r_sum = undefined
  g_sum = undefined
  b_sum = undefined
  r_out_sum = undefined
  g_out_sum = undefined
  b_out_sum = undefined
  r_in_sum = undefined
  g_in_sum = undefined
  b_in_sum = undefined
  pr = undefined
  pg = undefined
  pb = undefined
  rbs = undefined
  div = radius + radius + 1
  w4 = width .<<. 2
  widthMinus1 = width - 1
  heightMinus1 = height - 1
  radiusPlus1 = radius + 1
  sumFactor = radiusPlus1 * (radiusPlus1 + 1) / 2
  stackStart = new BlurStack()
  stack = stackStart
  i = 1
  while i < div
    stack = stack.next = new BlurStack()
    stackEnd = stack  if i is radiusPlus1
    i++
  stack.next = stackStart
  stackIn = null
  stackOut = null
  yw = yi = 0
  mul_sum = mul_table[radius]
  shg_sum = shg_table[radius]
  y = 0
  while y < height
    r_in_sum = g_in_sum = b_in_sum = r_sum = g_sum = b_sum = 0
    r_out_sum = radiusPlus1 * (pr = pixels[yi])
    g_out_sum = radiusPlus1 * (pg = pixels[yi + 1])
    b_out_sum = radiusPlus1 * (pb = pixels[yi + 2])
    r_sum += sumFactor * pr
    g_sum += sumFactor * pg
    b_sum += sumFactor * pb
    stack = stackStart
    i = 0
    while i < radiusPlus1
      stack.r = pr
      stack.g = pg
      stack.b = pb
      stack = stack.next
      i++
    i = 1
    while i < radiusPlus1
      p = yi + (((if widthMinus1 < i then widthMinus1 else i)) .<<. 2)
      r_sum += (stack.r = (pr = pixels[p])) * (rbs = radiusPlus1 - i)
      g_sum += (stack.g = (pg = pixels[p + 1])) * rbs
      b_sum += (stack.b = (pb = pixels[p + 2])) * rbs
      r_in_sum += pr
      g_in_sum += pg
      b_in_sum += pb
      stack = stack.next
      i++
    stackIn = stackStart
    stackOut = stackEnd
    x = 0
    while x < width
      pixels[yi] = (r_sum * mul_sum) .>>. shg_sum
      pixels[yi + 1] = (g_sum * mul_sum) .>>. shg_sum
      pixels[yi + 2] = (b_sum * mul_sum) .>>. shg_sum
      r_sum -= r_out_sum
      g_sum -= g_out_sum
      b_sum -= b_out_sum
      r_out_sum -= stackIn.r
      g_out_sum -= stackIn.g
      b_out_sum -= stackIn.b
      p = (yw + ((if (p = x + radius + 1) < widthMinus1 then p else widthMinus1))) .<<. 2
      r_in_sum += (stackIn.r = pixels[p])
      g_in_sum += (stackIn.g = pixels[p + 1])
      b_in_sum += (stackIn.b = pixels[p + 2])
      r_sum += r_in_sum
      g_sum += g_in_sum
      b_sum += b_in_sum
      stackIn = stackIn.next
      r_out_sum += (pr = stackOut.r)
      g_out_sum += (pg = stackOut.g)
      b_out_sum += (pb = stackOut.b)
      r_in_sum -= pr
      g_in_sum -= pg
      b_in_sum -= pb
      stackOut = stackOut.next
      yi += 4
      x++
    yw += width
    y++
  x = 0
  while x < width
    g_in_sum = b_in_sum = r_in_sum = g_sum = b_sum = r_sum = 0
    yi = x .<<. 2
    r_out_sum = radiusPlus1 * (pr = pixels[yi])
    g_out_sum = radiusPlus1 * (pg = pixels[yi + 1])
    b_out_sum = radiusPlus1 * (pb = pixels[yi + 2])
    r_sum += sumFactor * pr
    g_sum += sumFactor * pg
    b_sum += sumFactor * pb
    stack = stackStart
    i = 0
    while i < radiusPlus1
      stack.r = pr
      stack.g = pg
      stack.b = pb
      stack = stack.next
      i++
    yp = width
    i = 1
    while i <= radius
      yi = (yp + x) .<<. 2
      r_sum += (stack.r = (pr = pixels[yi])) * (rbs = radiusPlus1 - i)
      g_sum += (stack.g = (pg = pixels[yi + 1])) * rbs
      b_sum += (stack.b = (pb = pixels[yi + 2])) * rbs
      r_in_sum += pr
      g_in_sum += pg
      b_in_sum += pb
      stack = stack.next
      yp += width  if i < heightMinus1
      i++
    yi = x
    stackIn = stackStart
    stackOut = stackEnd
    y = 0
    while y < height
      p = yi .<<. 2
      pixels[p] = (r_sum * mul_sum) .>>. shg_sum
      pixels[p + 1] = (g_sum * mul_sum) .>>. shg_sum
      pixels[p + 2] = (b_sum * mul_sum) .>>. shg_sum
      r_sum -= r_out_sum
      g_sum -= g_out_sum
      b_sum -= b_out_sum
      r_out_sum -= stackIn.r
      g_out_sum -= stackIn.g
      b_out_sum -= stackIn.b
      p = (x + (((if (p = y + radiusPlus1) < heightMinus1 then p else heightMinus1)) * width)) .<<. 2
      r_sum += (r_in_sum += (stackIn.r = pixels[p]))
      g_sum += (g_in_sum += (stackIn.g = pixels[p + 1]))
      b_sum += (b_in_sum += (stackIn.b = pixels[p + 2]))
      stackIn = stackIn.next
      r_out_sum += (pr = stackOut.r)
      g_out_sum += (pg = stackOut.g)
      b_out_sum += (pb = stackOut.b)
      r_in_sum -= pr
      g_in_sum -= pg
      b_in_sum -= pb
      stackOut = stackOut.next
      yi += width
      y++
    x++

BlurStack = ->
  @r = 0
  @g = 0
  @b = 0
  @a = 0
  @next = null

mediator.on 'blur', (img, done) ->
  console.log "Blur data got"

  blur img, 50

  console.log "Blur done"

  done img
