function tick() {
	// should we fund a loan?
	if (Math.random() <= 0.10) { newLoanPurchase(); }

	// should a new lender join?
	if (Math.random() <= 0.05) { newLender(); }

	// should a new borrower appear?
	if (Math.random() <= 0.05) {  newBorrower(); }
}

function writeToScroller(message, color) {
	color2 = "#" + color.substring(2);
	var scroller = document.getElementById("scroller");
	scroller.innerHTML = scroller.innerHTML + "<span style='color:" + color2 + ";'>" + message + "</span><br>";
	scroller.scrollTop = scroller.scrollHeight;
}

function wrapText(n, e, o, t, r, a, c) {
    var l = 0,
        i = e ? 0 > e ? -1 : 1 : 0;
    0 > i && (l = -1);
    for (var u = o.split(" "), p = "", f = 0; f < u.length; f++)
        for (var g = u[f].split(" "), s = 0; s < g.length; s++) {
            p = p + g[s] + " ";
            var x = n.measureText(p),
                m = x.width;
            m > a && (n.fillText(p, t + e + l * m, r), p = "", r += c)
        }
    n.fillText(p, t + e + l * m, r)
}

function componentToHex(n) {
    var e = n.toString(16);
    return 1 == e.length ? "0" + e : e
}

function rgbToHex(n, e, o) {
    return "0x" + componentToHex(n) + componentToHex(e) + componentToHex(o)
}

function getLabelLocation(n) {
    return n / 2 == parseInt(n / 2) ? -17 : 7
}

function getPercentComplete(n, e, o) {
    return (e - o) / (e - n)
}

function getAnimatingValue(n, e, o, t) {
    return e > n ? t * n / e : n > o ? t * (1 - n) / e : t
}

function get(n) {
    return (n = new RegExp("[?&]" + encodeURIComponent(n) + "=([^&]*)").exec(location.search)) ? decodeURIComponent(n[1]) : void 0
}

function latLonToXY(n, e, o) {
    var t = n[0],
        r = n[1],
        a = new Array;
    return a[0] = parseInt(o / 360 * (180 + r)), a[1] = parseInt(e / 180 * (90 - t)), 0 == a[0] && 0 == a[1] && console.log("lat " + t + " lon " + r + " mapped to (0,0)"), a
}

function getColor(n) {
    return n ? colors[n % colors.length] : (n = parseInt(Math.random() * colors.length), colors[n])
}

function hslToRgb(n, e, o) {
    function t(n, e, o) {
        return 0 > o && (o += 1), o > 1 && (o -= 1), 1 / 6 > o ? n + 6 * (e - n) * o : .5 > o ? e : 2 / 3 > o ? n + (e - n) * (2 / 3 - o) * 6 : n
    }
    var r, a, c;
    if (0 == e) r = a = c = o;
    else {
        var l = .5 > o ? o * (1 + e) : o + e - o * e,
            i = 2 * o - l;
        r = t(i, l, n + 1 / 3), a = t(i, l, n), c = t(i, l, n - 1 / 3)
    }
    return [255 * r, 255 * a, 255 * c]
}
var colors = new Array([101, 153, 255], [255, 153, 0], [255, 0, 0], [102, 0, 204], [153, 0, 51], [210, 100, 40], [0, 170, 0], [255, 0, 128], [51, 102, 204], [177, 3, 24], [148, 103, 189], [50, 160, 50], [229, 95, 189], [31, 119, 180]);

