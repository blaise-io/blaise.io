canvas = document.querySelector('canvas')
#canvas.setAttribute 'width', window.innerWidth + 'px'
#canvas.setAttribute 'height', window.innerHeight + 'px'
context = canvas.getContext '2d'

context.fillStyle = '#fff'
context.fillRect 0, 0, canvas.width, canvas.height

context.globalCompositeOperation = 'destination-out'
context.font = 'normal 120px georgia, sans-serif'
context.fillStyle = '#fff'
context.fillText 'Blaise Kal', 10, 120
