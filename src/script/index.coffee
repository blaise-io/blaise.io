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
            retry = => dom.webFontLoaded(font, callback)
            window.setTimeout(retry, 50)
        dummy.parentNode.removeChild(dummy)


class CanvasCutout
    constructor: (@cards) ->
        @font = @getFontProperties()
        dom.webFontLoaded(@font.family.split(',')[0], => @bindLoadAll())

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
            @addCanvasToCard(card, img)
        else
            img.onload = => @addCanvasToCard(card, img)

    addCanvasToCard: (card, img) ->
        canvas = document.createElement('canvas')
        canvas.width = card.offsetWidth
        canvas.height = card.offsetHeight

        h1 = card.querySelector('h1')

        context = canvas.getContext('2d')

        context.font = "#{@font.size} #{@font.family}"
        context.fillStyle = '#000'
        context.fillText(
            h1.childNodes[0].nodeValue.toUpperCase(), 15,
            9 + parseInt(@font.lineHeight, 10)
        )

        time = h1.querySelector('time')
        if time
            context.textAlign = 'right'
            context.fillText(
                time.innerHTML, canvas.width - 15,
                9 + parseInt(@font.lineHeight, 10)
            )

        context.fillStyle = '#fff'
        context.globalCompositeOperation = 'xor'
        context.fillRect(0, 0, canvas.width, canvas.height)

        context.globalCompositeOperation = 'source-atop'
        context.drawImage(img, 15, h1.offsetHeight + 15, img.getAttribute('width'), img.getAttribute('height'))

        card.insertBefore(canvas, card.childNodes[0])
        dom.addClass(card, 'cut')


class CardScroll
    MAX_SKEW: 90
    EXTEND_V: 0

    constructor: (@container) ->
        @cards = @container.querySelectorAll('.card')
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


new CanvasCutout document.querySelectorAll('.card')
new CardScroll document.querySelector('.cards')
