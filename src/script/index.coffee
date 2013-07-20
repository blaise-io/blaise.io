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
        prefixes = ['transform', 'webkitTransform', 'mozTransform', 'msTransform']
        if not dom._transform
            for prefix in prefixes
                if typeof element.style[prefix] isnt 'undefined'
                    dom._transform = prefix
        element.style[dom._transform] = transform


class CanvasCutout
    constructor: (@elements) ->
        canvas = document.querySelector('canvas')
        context = canvas.getContext('2d')

        context.fillStyle = '#fff'
        context.fillRect(0, 0, canvas.width, canvas.height)

        context.globalCompositeOperation = 'destination-out'
        context.font = 'normal 120px georgia, sans-serif'
        context.fillStyle = '#fff'
        context.fillText('Blaise Kal', 10, 120)


class CardScroll

    MAX_SKEW: 90
    VIEWPORT: 0

    constructor: (@container) ->
        @cards = @container.querySelectorAll('.card')
        @container.onscroll = window.onresize = =>
            @updateAll()
        @updateAll();

    updateAll: ->
        v1 = @container.scrollTop - @VIEWPORT
        v2 = v1 + window.innerHeight + @VIEWPORT + @VIEWPORT
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


cards = new CardScroll document.querySelector '.cards'
