function addEarth() {
    var e = new THREE.SphereGeometry(600, 50, 50),
        t = new THREE.SpotLight(16777215, .3);
    t.position.set(2850, 350, 0), t.castShadow = !0, t.shadowMapWidth = 1024, t.shadowMapHeight = 1024, t.shadowCameraNear = 500, t.shadowCameraFar = 4e3, t.shadowCameraFov = 30, t.shadowMapVisible = !0, camera.add(t), globe_far_side = new THREE.MeshPhongMaterial({
        color: "white",
        emissive: "rgb(200,200,200)",
        transparent: !0,
        map: THREE.ImageUtils.loadTexture("assets/" + GLOBE_SKIN_BACK),
        castShadow: !0,
        receiveShadow: !0,
        side: THREE.BackSide
    }), globe_near_side = new THREE.MeshPhongMaterial({
        color: "white",
        emissive: "rgb(200,200,200)",
        transparent: !0,
        map: THREE.ImageUtils.loadTexture("assets/" + GLOBE_SKIN_FRONT),
        castShadow: !0,
        receiveShadow: !0
    });
    var n = new THREE.Mesh(new THREE.SphereGeometry(600, 50, 50), globe_far_side);
    scene.add(n);
    var n = new THREE.Mesh(new THREE.SphereGeometry(600, 50, 50), globe_near_side);
    scene.add(n);
    var o = Shaders.atmosphere;
    uniforms = THREE.UniformsUtils.clone(o.uniforms), material = new THREE.ShaderMaterial({
        uniforms: uniforms,
        vertexShader: o.vertexShader,
        fragmentShader: o.fragmentShader,
        side: THREE.BackSide,
        blending: THREE.NormalBlending,
        transparent: !0
    }), mesh = new THREE.Mesh(e, material), mesh.scale.set(.95, .95, .95), scene.add(mesh)
}

function latLonToVector3(e, t) {
    var n = new THREE.Vector3(0, 0, 0);
    t += 10, e -= 2;
    var o = PI_HALF - e * Math.PI / 180 - .01 * Math.PI,
        r = 2 * Math.PI - t * Math.PI / 180 + .06 * Math.PI,
        a = 600;
    return n.x = Math.sin(o) * Math.cos(r) * a, n.y = Math.cos(o) * a, n.z = Math.sin(o) * Math.sin(r) * a, 0 == n.x && 0 == n.y && 0 == n.z && console.log(e + ", " + t + " is a (0,0,0) vector"), n
}

function bezierCurveBetween(e, t) {
    var n = e.clone().sub(t).length(),
        o = n > 1160 ? .5 : .4,
        r = n > 1160 ? .52 : .4,
        a = e.clone().lerp(t, .5),
        i = a.length();
    a.normalize(), a.multiplyScalar(i + n * o);
    var s = (new THREE.Vector3).subVectors(e, t);
    s.normalize();
    var l = n * r,
        c = e,
        d = a.clone().add(s.clone().multiplyScalar(l)),
        p = a.clone().add(s.clone().multiplyScalar(-l)),
        m = t,
        h = new THREE.CubicBezierCurve3(e, c, d, a),
        g = new THREE.CubicBezierCurve3(a, p, m, t),
        v = Math.floor(.02 * n + 6),
        E = h.getPoints(v);
    return E = E.splice(0, E.length - 1), E = E.concat(g.getPoints(v))
}

function getGeom(e) {
    var t;
    if (geoms[e.length].length > 0) {
        t = geoms[e.length].pop();
        for (var n = (e[0], 0); n < e.length; n++) t.vertices[n].set(0, 0, 0);
        return t.verticesNeedUpdate = !0, t
    }
    t = new THREE.Geometry, t.dynamic = !0, t.size = 10.05477225575;
    for (var n = 0; n < e.length; n++) t.vertices.push(new THREE.Vector3);
    return t
}

function returnGeom(e) {
    geoms[e.vertices.length].push(e)
}

function tweenFnLinear(e) {
    return e
}

function tweenFnEaseIn(e) {
    return e * e * e * e
}

function tweenFnEaseOut(e) {
    return e >= 1 ? e : 1 - --e * e
}

function tweenPoints(e, t, n, o, r, a, i, s, l, c) {
    var d = {
        n: 0,
        points: t,
        geometry: e,
        time: Date.now(),
        duration: n,
        tweenFn: o,
        delay: r,
        x: a,
        y: i,
        x_offset: s,
        name: l,
        color: c,
        line: null
    };
    return tweens.push(d), d
}

function tweenPoint() {
    var e = tweens.length,
        t = Date.now();
    for (ctx.clearRect(0, 0, MAP_WIDTH, MAP_HEIGHT), offset = 5; e--;)
        if (tweens[e].delay > 0) tweens[e].delay = tweens[e].delay - 1;
        else if (0 == tweens[e].delay) tweens[e].time = Date.now(), tweens[e].delay = -1;
    else {
        var n = tweens[e],
            o = n.points[n.n],
            a = n.geometry,
            i = a.vertices.length,
            s = (t - n.time) / n.duration,
            l = n.tweenFn(s > 2 ? 2 : s),
            c = Math.floor(i * l),
            d = c - i;
        if (c > n.n)
            if (1 >= s) {
                for (var p = n.n; i > p; p++) c > p && (o = n.points[p]), a.vertices[p].set(o.x, o.y, o.z);
                n.n = c, a.verticesNeedUpdate = !0
            } else {
                for (var p = 1; d > p; p++) a.vertices[p].set(0, 0);
                a.verticesNeedUpdate = !0
            }
        if (percent_complete = Math.min(s / 2, 1), r = getAnimatingValue(percent_complete, .1, .9, 6), pointsize = getAnimatingValue(percent_complete, .1, .9, 10), x_center = tweens[e].x - offset, y_center = tweens[e].y, borrower_name = tweens[e].name, x_offset = tweens[e].x_offset, ctx.fillStyle = tweens[e].color, ctx.beginPath(), ctx.rect(x_center - 2 * r / 2, y_center - 2 * r / 2, 2 * r, 2 * r), ctx.fill(), ctx.lineWidth = 1, ctx.strokeStyle = "black", ctx.stroke(), ctx.fillStyle = "black", ctx.font = pointsize + "px Arial", wrapText(ctx, x_offset, borrower_name, tweens[e].x, y_center, 75, pointsize), s >= 2) {
            var m = n.line;
            scene.remove(m), lines.splice(lines.indexOf(m), 1), returnGeom(a), tweens.splice(e, 1)
        }
    }
}

function lender_registered(e, t, n, o, r, a) {
    if (VISIBLE) {
        coords = new Array, coords[0] = t, coords[1] = n, coords2 = latLonToXY(coords, MAP_HEIGHT, MAP_WIDTH);
        var i = coords2[0],
            s = coords2[1],
            l = getLabelLocation(e.length);
        points.push({
            type: "lender",
            x_offset: l,
            x: i,
            y: s,
            time: Date.now(),
            name: e + " just joined Kiva",
            color: "rgb(" + parseInt(o) + ", " + parseInt(r) + ", " + parseInt(a) + ")",
            duration: 2500
        })
    }
}

function lender_joined_team(e, t, n, o, r, a, i) {
    if (VISIBLE) {
        coords = new Array, coords[0] = t, coords[1] = n, coords2 = latLonToXY(coords, MAP_HEIGHT, MAP_WIDTH);
        var s = coords2[0],
            l = coords2[1],
            c = getLabelLocation(e.length);
        points.push({
            type: "lender",
            x_offset: c,
            x: s,
            y: l,
            time: Date.now(),
            name: e + " joined " + o,
            color: "rgb(" + parseInt(r) + ", " + parseInt(a) + ", " + parseInt(i) + ")",
            duration: 2500
        })
    }
}

function loan_registered(e, t, n, o, r, a) {
    if (VISIBLE) {
        coords = new Array, coords[0] = t, coords[1] = n, coords2 = latLonToXY(coords, MAP_HEIGHT, MAP_WIDTH);
        var i = coords2[0],
            s = coords2[1],
            l = getLabelLocation(e.length);
        points.push({
            type: "borrower",
            x_offset: l,
            x: i,
            y: s,
            time: Date.now(),
            name: "New Loan: " + e,
            color: "rgb(" + parseInt(o) + ", " + parseInt(r) + ", " + parseInt(a) + ")",
            duration: 2500
        })
    }
}

function add_loans_purchased(e) {
    if (VISIBLE) {
        lender_lat = parseFloat(e.lender.lat), lender_lon = parseFloat(e.lender.lon), lender_name = e.lender.name, null == lender_name && (lender_name = "Anonymous"), color_r = parseInt(e.color.r), color_g = parseInt(e.color.g), color_b = parseInt(e.color.b), lender = [lender_lat, lender_lon, lender_name, color_r, color_g, color_b];
        var t = new Array;
        for (b = 0; b <= e.loans.length - 1; b++) {
            lat = parseFloat(e.loans[b].location.lat), lon = parseFloat(e.loans[b].location.lon), name = e.loans[b].name;
            var n = [lat, lon, name, color_r, color_g, color_b];
            t[b] = n
        }
        addData(lender, t)
    }
}

function newPath() {
	origin_idx = parseInt(Math.random() * geos.length);
	origin_coords = geos[origin_idx];
	how_many = parseInt(Math.random() * 10);
	color = getColor();

//console.log(orig[originate_at]);
//console.log(dest[terminate_at]);

	originate_at = [origin_coords[0], origin_coords[1], "Origin", color[0], color[1], color[2]];

	var terminate_at = new Array;

	for (b = 0; b <= how_many; b++) {
		dest_idx = parseInt(Math.random() * geos.length);
		lat = parseFloat(geos[dest_idx][0]), lon = parseFloat(geos[dest_idx][1]), color_r = parseInt(30 + 200 * Math.random()), color_g = parseInt(30 + 200 * Math.random()), color_b = parseInt(30 + 200 * Math.random()), name = "Dest " + b;
		var a = [lat, lon, name, color_r, color_g, color_b];
		terminate_at[b] = a;
	}

	addData(originate_at, terminate_at);
}

function addData(e, t) {
    for (var n = {
        lat: e[0],
        lon: e[1]
    }, o = latLonToVector3(n.lat, n.lon), r = e[3], a = e[4], i = e[5], s = rgbToHex(r, a, i), l = t.length <= FAT_BASKET_THRESHOLD ? LAUNCH_OFFSET : LAUNCH_OFFSET_FAST, c = 0, d = 0; d < t.length; d++) {
        var p = {
            lat: t[d][0],
            lon: t[d][1]
        }, m = latLonToVector3(p.lat, p.lon),
            h = t[d][2],
            g = bezierCurveBetween(o, m),
            v = getGeom(g),
            E = o.clone().sub(m).length(),
            w = d * l;
        coords = new Array, coords[0] = p.lat, coords[1] = p.lon, coords2 = latLonToXY(coords, MAP_HEIGHT, MAP_WIDTH);
        var _ = coords2[0],
            u = coords2[1],
            f = E + MIN_DURATION,
            x = f + 20 * d * l,
            T = getLabelLocation(h.length);
        if (x + w > c) {
            c = x;
            var y = "rgb(" + parseInt(r) + ", " + parseInt(a) + ", " + parseInt(i) + ")"
        }
        var I = tweenPoints(v, g, f, tweenFnEaseOut, w, _, u, T, h, y),
            H = parseInt(s, 16),
            S = new THREE.LineBasicMaterial({
                color: H,
                linewidth: 3
            }),
            b = new THREE.Line(v, S);
        lines.push(b), I.line = b, scene.add(b)
    }
    coords = new Array, coords[0] = n.lat, coords[1] = n.lon, coords2 = latLonToXY(coords, MAP_HEIGHT, MAP_WIDTH);
    var M = coords2[0],
        A = coords2[1],
        T = getLabelLocation(e[2].length);
    points.push({
        type: "lender",
        x_offset: T,
        x: M,
        y: A,
        time: Date.now(),
        name: e[2],
        color: y,
        duration: c
    })
}

function checkIdle() {
    IDLE === !0 && (target.x -= .003, target.y > .005 && (target.y -= .001), target.y < .005 && (target.y += .001), Math.abs(target.y) < .001 && (target.y = .001))
}

function addOverlay() {
    var e = new THREE.SphereGeometry(600, 50, 50);
    overlay = new THREE.Texture(document.querySelector("#canvas"));
    var t = new THREE.MeshBasicMaterial({
        map: overlay,
        transparent: !0,
        opacity: 1,
        blending: THREE.NormalBlending
    }),
        n = new THREE.Mesh(e, t);
    scene.add(n)
}

function render() {
    tweenPoint();
    for (var e = points.length; e--;) {
        {
            Date.now() - points[e].time
        }
        Date.now() - points[e].time >= 2.1 * points[e].duration && points.splice(e, 1)
    }
    for (var e = 0; e < points.length; e++) switch (percent_complete = getPercentComplete(0, 2.1 * points[e].duration, Date.now() - points[e].time), r = getAnimatingValue(Math.abs(percent_complete), .1, .9, 6), alpha = getAnimatingValue(percent_complete, .2, .8, 1), pointsize = getAnimatingValue(percent_complete, .1, .9, 10), points[e].type) {
        case "lender":
            ctx.fillStyle = points[e].color, ctx.globalAlpha = 1, ctx.beginPath(), ctx.arc(points[e].x - r / 2, points[e].y, r, 0, 2 * Math.PI, !1), ctx.fill(), ctx.lineWidth = 1, ctx.strokeStyle = "black", ctx.stroke(), ctx.fillStyle = "black", ctx.font = pointsize + "px Arial", wrapText(ctx, points[e].x_offset, points[e].name, points[e].x, points[e].y, 75, pointsize);
            break;
        case "borrower":
            ctx.fillStyle = points[e].color, ctx.globalAlpha = 1, ctx.beginPath(), offset = 5, x_center = points[e].x - offset, y_center = points[e].y, ctx.rect(x_center - 2 * r / 2, y_center - 2 * r / 2, 2 * r, 2 * r), ctx.fill(), ctx.lineWidth = 1, ctx.strokeStyle = "black", ctx.stroke(), ctx.fillStyle = "black", ctx.font = pointsize + "px Arial", wrapText(ctx, points[e].x_offset, points[e].name, points[e].x, points[e].y, 75, pointsize);
            break;
        default:
            console.log("error: we should never get here")
    }
    overlay.needsUpdate = !0, rotation.x += .1 * (target.x - rotation.x), rotation.y += .1 * (target.y - rotation.y), DISTANCE += .3 * (target.zoom - DISTANCE), checkIdle(), camera.position.x = DISTANCE * Math.sin(rotation.x) * Math.cos(rotation.y), camera.position.y = DISTANCE * Math.sin(rotation.y), camera.position.z = DISTANCE * Math.cos(rotation.x) * Math.cos(rotation.y), camera.lookAt(scene.position), renderer.autoClear = !1, renderer.clear(), renderer.render(scene, camera)
}

function animate() {
    requestAnimationFrame(animate), VISIBLE && (DEBUG && stats.begin(), render(), DEBUG && stats.end())
}

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight, camera.updateProjectionMatrix(), renderer.setSize(window.innerWidth, window.innerHeight)
}

function get(e) {
    return (e = new RegExp("[?&]" + encodeURIComponent(e) + "=([^&]*)").exec(location.search)) ? decodeURIComponent(e[1]) : void 0
}

function setMinDuration(e) {
    MIN_DURATION = parseInt(e)
}
var POS_X = 1800,
    POS_Y = 500,
    POS_Z = 1800,
    DISTANCE = 1e4,
    WIDTH = window.innerWidth,
    HEIGHT = window.innerHeight,
    GLOBE_SKIN_FRONT = "trans_world_80.png",
    GLOBE_SKIN_BACK = "trans_world_50.png",
    path = window.location.pathname;
"/live" == path.substr(0, 5) ? (WIDTH = 654, HEIGHT = 600) : "/replay" == path.substr(0, 7) && (WIDTH = 950, HEIGHT = 600, GLOBE_SKIN_FRONT = "hp_80.png", GLOBE_SKIN_BACK = "hp_50.png"), MAP_HEIGHT = 1024, MAP_WIDTH = 2048;
var PI_HALF = Math.PI / 2,
    IDLE = !0,
    IDLE_TIME = 3e3,
    FOV = 45,
    NEAR = 1,
    FAR = 15e4,
    LAUNCH_OFFSET = 3,
    LAUNCH_OFFSET_FAST = 1,
    FAT_BASKET_THRESHOLD = 90,
    MIN_DURATION = 1200,
    VISIBLE = !0,
    DEBUG = !1,
    target = {
        x: -2,
        y: 0,
        zoom: 2500
    }, global_antialias = !0,
    alpha_setting = "texture2D( texture, vUv ).a",
    Shaders = {
        earth: {
            uniforms: {
                texture: {
                    type: "t",
                    value: null
                }
            },
            vertexShader: ["varying vec3 vNormal;", "varying vec2 vUv;", "void main() {", "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );", "vNormal = normalize( normalMatrix * normal );", "vUv = uv;", "}"].join("\n"),
            fragmentShader: ["uniform sampler2D texture;", "varying vec3 vNormal;", "varying vec2 vUv;", "void main() {", "vec3 diffuse = texture2D( texture, vUv ).xyz;", "float intensity = 1.05 - dot( vNormal, vec3( 0.0, 0.0, 1.0 ) );", "vec3 atmosphere = vec3( 0.2, 0.2, 0.2 ) * pow( intensity, 3.0 );", "gl_FragColor = vec4( diffuse + atmosphere," + alpha_setting + " );", "}"].join("\n")
        },
        atmosphere: {
            uniforms: {},
            vertexShader: ["varying vec3 vNormal;", "void main() {", "vNormal = normalize( normalMatrix * normal );", "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 0.85 );", "}"].join("\n"),
            fragmentShader: ["varying vec3 vNormal;", "void main() {", "float intensity = pow( 0.9 - dot( vNormal, vec3( 0, 0, 1.0 ) ), 12.0 );", "gl_FragColor = vec4( 0.2, 0.2, 0.2, 0.3 ) * intensity;", "}"].join("\n")
        }
    }, renderer = new THREE.WebGLRenderer({
        antialias: !0
    });
renderer.setSize(WIDTH, HEIGHT), renderer.setClearColor(15658734, 1);
var mapDiv = document.getElementById("globe");
mapDiv.appendChild(renderer.domElement);
var camera = new THREE.PerspectiveCamera(FOV, WIDTH / HEIGHT, NEAR, FAR);
camera.position.set(POS_X, POS_Y, POS_Z), camera.lookAt(new THREE.Vector3(0, 0, 0));
var scene = new THREE.Scene;
scene.add(camera);
var geoms = [];
! function() {
    for (var e = 0; 500 > e; e++) geoms[e] = []
}();
var tweens = [],
    lines = [],
    points = [],
    lineColors = [],
    ctx = document.querySelector("#canvas").getContext("2d");

var orig2 = new Array(
[ -45.8745994567871, 170.503005981445],
[ 49.263599395752, -123.138999938965],
[ 49.8955993652344, -97.138298034668],
[ 50.447234, -104.618013],
[ 51.045, -114.0572222],
[ 51.0453246, -114.0581012],
[ 51.0536994934082, -114.06199645996101],
[ 53.540901184082, -113.49400329589801],
[ 53.543564, -113.490452],
[ 53.710098266601605, -113.21299743652298],
[ 56.1267013549805, 10.1091995239258],
[ 61.215599060058594, -149.897994995117]);

! function() {
    for (var e = 0; 10 > e; e++) {
        var t = new THREE.Color,
            n = Math.random();
        t.setHSL(.6 - .5 * n, 1, .5), lineColors.push(new THREE.LineBasicMaterial({
            color: t,
            linewidth: 3
        }))
    }
}();
var overlay, rotation = {
        x: 0,
        y: 0
    }, stats = new Stats;
stats.setMode(0), stats.domElement.style.position = "absolute", stats.domElement.style.right = "0px", stats.domElement.style.top = "0px", DEBUG && document.body.appendChild(stats.domElement), addEarth(), addOverlay(), animate();


