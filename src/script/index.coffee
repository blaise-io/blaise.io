# DOM Utils
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
        if not dom._transformPrefix
            prefixes = [
                'transform',
                'webkitTransform',
                'mozTransform',
                'msTransform'
            ]
            for prefix in prefixes
                if typeof element.style[prefix] isnt 'undefined'
                    dom._transformPrefix = prefix
        element.style[dom._transformPrefix] = transform

    storage: (key, val) ->
        if key and localStorage?
            if val
                return localStorage.setItem(key, val)
            else
                return localStorage.getItem(key)

    webFontLoaded: (font, callback) ->
        dummy = document.createElement('span')
        dummy.style.visibility = 'hidden'
        dummy.style.font = '300px serif'
        dummy.innerHTML = '!@#$%'
        document.body.appendChild(dummy)
        width = dummy.offsetWidth
        dummy.style.font = "300px #{font}, serif"
        if width isnt dummy.offsetWidth
            dummy.parentNode.removeChild(dummy)
            callback()
        else
            retry = =>
                dom.webFontLoaded(font, callback)
            window.setTimeout(retry, 50)


# Background seaping through text effect in cards
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


# Individual card
class CardCanvas
    constructor: (@card, @img, @font) ->
        h1 = @card.querySelector('h1')
        time = h1.querySelector('time')

        @hover =
            img : false
            link: false

        @width = @card.offsetWidth
        @height = @card.offsetHeight

        @padding = 15
        @textY = 9 + parseFloat(@font.lineHeight)

        @imgY = h1.offsetHeight + @padding - 2
        @imgW = parseInt(@img.getAttribute('width'), 10)
        @imgH = parseInt(@img.getAttribute('height'), 10)

        @link = h1.querySelector('a')
        if @link
            @linkW = @link.offsetWidth
            @title = @link.textContent
        else
            @title = h1.textContent

        @title = @title.toUpperCase().trim()
        @time = time.innerHTML.trim() if time

        @addCanvasToCard()

    addCanvasToCard: ->
        canvas = document.createElement('canvas')
        canvas.width = @width
        canvas.height = @height

        @context = canvas.getContext('2d')

        @paintCanvas()
        @bindEvents() if @link

        @card.insertBefore(canvas, @card.childNodes[0])
        dom.addClass(@card, 'cut')

    paintCanvas: ->
        @context.clearRect(0, 0, @width, @height)
        @context.globalCompositeOperation = 'source-over'

        @paintTitle()
        @paintTime() if @time
        @paintImgHover() if @hover.img
        @paintLinkHover() if @hover.link
        @paintBackground()
        @paintImage()

    bindEvents: ->
        @img.onmouseenter = =>
            @hover.img = true
            @paintCanvas()
        @img.onmouseout = =>
            @hover.img = false
            @paintCanvas()
        if @link
            @link.onmouseenter = =>
                @hover.link = true
                @paintCanvas()
            @link.onmouseout = =>
                @hover.link = false
                @paintCanvas()

    paintTitle: ->
        @context.textAlign = 'left'
        @context.font = "#{@font.size} #{@font.family}"
        @context.fillText(@title, @padding, @textY)

    paintLinkHover: ->
        @context.fillRect(@padding, @textY + 2, @linkW, 1)

    paintImgHover: ->
        s = 1
        o = 2

        # T R B L
        @context.fillRect(@padding + o, @imgY + o, @imgW - o - o, s)
        @context.fillRect(@padding + @imgW - s - o, @imgY + o, s, @imgH - o - o)
        @context.fillRect(@padding + o, @imgY + @imgH - o - s, @imgW - o - o, s)
        @context.fillRect(@padding + o, @imgY + o, s, @imgH - o - o)

    paintTime: ->
        @context.textAlign = 'right'
        @context.fillText(@time, @width - @padding, @textY)

    paintBackground: ->
        @context.fillStyle = '#fff'
        @context.globalCompositeOperation = 'xor'
        @context.fillRect(0, 0, @width, @height)

    paintImage: ->
        @context.globalCompositeOperation = 'source-atop'
        @context.drawImage(@img, @padding, @imgY, @imgW, @imgH)


# 3D effect when scrolling cards
class CardScroll
    constructor: (@container) ->
        @cards = @container.querySelectorAll('article')
        @container.onscroll = window.onresize = window.onload = =>
            @updateAll()
        @updateAll();

    updateAll: ->
        v1 = @container.scrollTop
        v2 = v1 + window.innerHeight
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
        @applyStyle(card, ch, frac)

    applyStyle: (card, ch, frac) ->
        transform = ''
        if frac
            transform += "perspective(#{ ch + (ch * 2 / 3) }px) "
            transform += "rotateX(#{ frac * 90 }deg)"

        dom.transform(card, transform)
        card.style.opacity = 1 - Math.abs(frac)


# Scrolling background gradient and favicon
class ThemeNav
    KEY: 'theme'
    ICON: document.querySelector('link[rel=icon]')
    APPLY_TO: document.documentElement
    DEFAULT_THEME: dom.getClassNameArr(document.documentElement)[0],

    constructor: (@themeLis) ->
        @themes = []
        @index(li) for li in @themeLis
        @load(dom.storage(@KEY) || @DEFAULT_THEME)

    index: (li) ->
        theme = li.className
        @themes.push(theme)
        li.onclick = =>
            @select(theme)
            dom.storage(@KEY, theme)

    load: (theme) ->
        @mask = new Image()
        @mask.src = @ICON.href
        if (@mask.complete)
            @loadTheme(theme)
        else
            @mask.onload = =>
                @loadTheme(theme)

    loadTheme: (theme) ->
        @select(theme) if theme in @themes

    select: (theme) ->
        args = @themes.slice()
        args.unshift(@APPLY_TO)
        dom.removeClass.apply(dom, args)
        dom.addClass(@APPLY_TO, theme)
        @favicon()

    favicon: ->
        element = document.querySelector('.bg')
        style = window.getComputedStyle(element, null)
        bg = style.getPropertyValue('background-image')
        [from, to] = bg.match(/rgb\([0-9]+, [0-9]+, [0-9]+\)/gi)

        if from and to
            canvas = document.createElement('canvas')
            w = canvas.width = 16
            h = canvas.height = 16

            context = canvas.getContext('2d')
            gradient = context.createLinearGradient(0, w, h, 0)
            gradient.addColorStop(0, from)
            gradient.addColorStop(1, to)

            context.drawImage(@mask, 0, 0, w, h)
            context.globalCompositeOperation = 'source-atop'

            context.fillStyle = gradient
            context.fillRect(0, 0, canvas.width, canvas.height)

            icon = document.createElement('link')
            icon.rel = 'icon'
            icon.type = 'image/png'
            icon.href = canvas.toDataURL()

            @ICON.parentNode.replaceChild(icon, @ICON)
            @ICON = icon


# Initialize; exclude slowpokes
if not (/(ios|android|mobile)/gi).test(navigator.userAgent)
    dom.addClass(document.documentElement, 'ENHANCED')
    new CardScroll(document.querySelector('.cards'))
    new CanvasCutout(document.querySelectorAll('article'))
    new ThemeNav(document.querySelectorAll('.themes li'))
