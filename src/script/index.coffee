dom =
    getClassNameArr: (element) ->
        element.className.split(/[\s]+/g)

    setClassNameArr: (element, arr) ->
        element.className = arr.join(' ').trim()

    addClass: (element, addArr...) ->
        arr = dom.getClassNameArr(element)
        arr.push(value) for value in addArr when value not in arr
        dom.setClassNameArr(element, arr)

    removeClass: (element, removeArr...) ->
        arr = dom.getClassNameArr(element)
        ret = []
        ret.push(value) for value in arr when value not in removeArr
        dom.setClassNameArr(element, ret)

    transform: (element, transform) ->
        prefixes = ['transform', 'webkitTransform', 'mozTransform',
                    'msTransform']
        if not dom._transform
            for prefix in prefixes
                if typeof element.style[prefix] isnt 'undefined'
                    dom._transform = prefix
        element.style[dom._transform] = transform

    webFontLoaded: (font, callback) ->
        dummy = document.createElement('span')
        dummy.innerHTML = '!@#$%'
        dummy.style.font = '300px serif'
        document.body.appendChild(dummy)
        width = dummy.offsetWidth
        dummy.style.font = "300px #{font}, serif"
        if width isnt dummy.offsetWidth
            callback()
        else
            retry = =>
                dom.webFontLoaded(font, callback)
            window.setTimeout(retry, 50)
        dummy.parentNode.removeChild(dummy)


class CanvasCutout
    constructor: (@cards) ->
        @font = @getFontProperties()
        dom.webFontLoaded(@font.family.split(',')[0], =>
            @bindLoadAll())

    getFontProperties: ->
        h1 = document.querySelector('h1')
        style = window.getComputedStyle(h1, null)
        font =
            family    : style.getPropertyValue('font-family')
            size      : style.getPropertyValue('font-size')
            lineHeight: style.getPropertyValue('line-height')

    bindLoadAll: ->
        @bindLoadImage(card) for card in @cards

    bindLoadImage: (card) ->
        img = card.querySelector('img')
        if (img.complete)
            new CardCanvas(card, img, @font)
        else
            img.onload = =>
                new CardCanvas(card, img, @font)


class CardCanvas
    constructor: (@card, @img, @font) ->
        h1 = @card.querySelector('h1')
        time = card.querySelector('time')

        @width = @card.offsetWidth
        @height = @card.offsetHeight

        @padding = 15
        @textY = 9 + parseFloat(@font.lineHeight)

        @imgY = h1.offsetHeight + @padding - 2
        @imgW = parseInt(@img.getAttribute('width'), 10)
        @imgH = parseInt(@img.getAttribute('height'), 10)

        @title = h1.childNodes[0].nodeValue.toUpperCase()
        @time = time.childNodes[0].nodeValue if time

        @addCanvasToCard()

    addCanvasToCard: ->
        canvas = document.createElement('canvas')
        canvas.width = @width
        canvas.height = @height

        @context = canvas.getContext('2d')

        @paintCanvas(null)
        @bindEvents()

        @card.insertBefore(canvas, @card.childNodes[0])
        dom.addClass(@card, 'cut')

    paintCanvas: (hover) ->
        if hover?
            @context.globalCompositeOperation = 'source-over'
            @context.clearRect(0, 0, @width, @height)
        if hover
            @paintAction()

        @paintTitle()
        @paintTime()
        @paintBackground()
        @paintImage()

    bindEvents: ->
        @img.onmouseenter = =>
            @paintCanvas(true)
        @img.onmouseout = =>
            @paintCanvas(false)

    paintTitle: ->
        @context.textAlign = 'left'
        @context.font = "#{@font.size} #{@font.family}"
        @context.fillText(@title, @padding, @textY)

    paintAction: ->
        if @time
            @context.textAlign = 'right'
            @context.font = "100px #{@font.family}"
            @context.fillText('◹', @width - @padding * 2, @imgY + 75)

    paintTime: ->
        if @time
            @context.textAlign = 'right'
            @context.fillText(@time, @width - @padding, @textY)

    paintBackground: ->
        @context.fillStyle = '#fff'
        @context.globalCompositeOperation = 'xor'
        @context.fillRect(0, 0, @width, @height)

    paintImage: ->
        @context.globalCompositeOperation = 'source-atop'
        @context.drawImage(@img, @padding, @imgY, @imgW, @imgH)


class CardScroll
    MAX_SKEW: 90
    EXTEND_V: 0

    constructor: (@container) ->
        @cards = @container.querySelectorAll('.card')
        dom.addClass(document.documentElement, 'fancy')
        @container.onscroll = window.onresize = window.onload = =>
            @updateAll()
        @updateAll();

    updateAll: ->
        v1 = @container.scrollTop - @EXTEND_V
        v2 = v1 + window.innerHeight + @EXTEND_V + @EXTEND_V
        @updateCard(card, v1, v2) for card in @cards

    updateCard: (card, v1, v2) ->
        ch = card.offsetHeight
        c1 = card.offsetTop
        c2 = c1 + ch
        frac = 0

        if v1 > c1
            dom.removeClass(card, 'bottom')
            dom.addClass(card, 'top')
            if v1 < c2
                frac = (v1 - c1) / ch
        else if v2 < c2
            dom.removeClass(card, 'top')
            dom.addClass(card, 'bottom')
            if v2 > c1
                frac = (v2 - c2) / ch

        @applyStyle(card, frac)

    applyStyle: (card, frac) ->
        transform = "perspective(400px) rotateX(#{ frac * @MAX_SKEW }deg)"
        dom.transform(card, transform)
        card.style.opacity = 1 - Math.abs(frac)


# Exclude slowpokes from all fun
if not (/(ios|android|mobile)/gi).test(navigator.userAgent)
    new CanvasCutout(document.querySelectorAll('.card'))
    new CardScroll(document.querySelector('.cards'))
