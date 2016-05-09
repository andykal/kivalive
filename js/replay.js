function replay() {
    interval = setInterval("check_tx();", 300)
}

function check_tx() {
    idx >= tx.length && clearInterval(interval);
    for (var a = new Array; tx[idx][0] < currtime;) {
        for (currlender = tx[idx][1]; tx[idx][1] == currlender;) {
            var o = Math.random(),
                n = .65 + .35 * Math.random(),
                e = .3 + .15 * Math.random(),
                r = hslToRgb(o, n, e);
            if (1579853 == tx[idx][8]) i = 0, u = 150, s = 214;
            else var i = parseInt(r[0]),
            u = parseInt(r[1]), s = parseInt(r[2]);
            var P = [parseFloat(tx[idx][4]), parseFloat(tx[idx][5]), tx[idx][2], i, u, s],
                H = [parseFloat(tx[idx][6]), parseFloat(tx[idx][7]), tx[idx][3], 200, 100, 200];
            if (a.push(H), idx++, idx >= tx.length) {
                clearInterval(interval);
                break
            }
        }
        if (addData(P, a), ++idx >= tx.length) {
            clearInterval(interval);
            break
        }
    }
    currtime += delta;
    var l = document.getElementById("myCanvas"),
        t = l.getContext("2d"),
        p = (currtime - starttime) / (endtime - starttime),
        G = 400 * p;
    t.beginPath(), t.rect(276, 46, G, 8), t.fillStyle = "#4b9123", t.fill()
}
idx = 0, starttime = 1393343121, endtime = 1393365594, setMinDuration(250), currtime = 1393343e3, delta = 30;

