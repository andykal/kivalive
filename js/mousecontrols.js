! function() {
    var e = renderer.domElement,
        t = !1,
        r = {
            x: 0,
            y: 0
        }, n = {
            x: 0,
            y: 0
        }, o = null;
    e.addEventListener("mousedown", function(e) {
        t = !0, IDLE = !1, clearTimeout(o), r = {
            x: e.clientX,
            y: -e.clientY
        }, n = {
            x: target.x,
            y: target.y
        }
    }), e.addEventListener("mouseup", function() {
        t = !1, clearTimeout(o), o = setTimeout(function() {
            IDLE = !0
        }, IDLE_TIME)
    }), e.addEventListener("mousemove", function(e) {
        if (1 == t) {
            var o = e.clientX,
                u = -e.clientY;
            target.x = n.x + .005 * (r.x - o), target.y = n.y + .005 * (r.y - u), target.y = target.y > PI_HALF ? PI_HALF : target.y, target.y = target.y < -PI_HALF ? -PI_HALF : target.y
        }
    }), renderer.domElement.addEventListener("mousewheel", function(e) {
        return target.zoom -= .3 * e.wheelDeltaY, target.zoom > 2500 && (target.zoom = 2500), target.zoom < 1500 && (target.zoom = 1500), e.preventDefault(), !1
    }), renderer.domElement.addEventListener("DOMMouseScroll", function(e) {
        return target.zoom += 3 * e.detail, target.zoom > 2500 && (target.zoom = 2500), target.zoom < 1500 && (target.zoom = 1500), e.preventDefault(), !1
    }), document.querySelector("#fullscreen").addEventListener("click", function() {
        var e = document.querySelector("#globe");
        e.requestFullScreen && e.requestFullScreen(), e.webkitRequestFullScreen && e.webkitRequestFullScreen(), e.mozRequestFullScreen && e.mozRequestFullScreen()
    })
}();

