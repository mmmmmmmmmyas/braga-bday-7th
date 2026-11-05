// Shared night sky for intro (index.html) and timeline (timeline.html): seeded dust stars and the aurora.
(function () {
  // same seed as always, so both pages draw the same stars
  function dust(W, H) {
    let seed = 7; const rnd = () => (seed = (seed * 16807) % 2147483647) / 2147483647;
    return Array.from({ length: Math.round(W * 0.04096) }, () => ({ x: +((rnd() * 1.3 - 0.15) * W).toFixed(1), y: +((rnd() * 1.2 - 0.1) * H).toFixed(1), r: +(0.6 + rnd() * 1.1).toFixed(2), o: +(0.168 + rnd() * 0.63).toFixed(2) }));
  }

  const FRAGMENT = `#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
uniform vec2 uRes;uniform float uT;uniform float uX0;uniform float uXS;uniform float uGrey;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);
  return mix(mix(hash(i),hash(i+vec2(1.,0.)),f.x),mix(hash(i+vec2(0.,1.)),hash(i+vec2(1.,1.)),f.x),f.y);}
float fbm(vec2 p){return .55*noise(p)+.3*noise(p*2.03+7.1)+.15*noise(p*4.01+3.7);}
vec3 scr(vec3 a,vec3 b){return a+b-a*b;}
vec3 pal(float n){
  n=clamp((n-.25)/.5,0.,1.)*4.;
  vec3 c=mix(vec3(.38,.24,.17),vec3(.29,.19,.18),smoothstep(0.,1.,n));
  c=mix(c,vec3(.40,.38,.27),smoothstep(1.,2.,n));
  c=mix(c,vec3(.24,.44,.29),smoothstep(2.,3.,n));
  return mix(c,vec3(.13,.29,.23),smoothstep(3.,4.,n));
}
vec3 ribbon(vec2 q,float X,float t,float base,float amp,float th,float f,float seed,float spd){
  float line=base+amp*(fbm(vec2(X*f-t*spd+seed,t*.035+seed))-.5)*2.;
  float d=(q.y-line)/(th*(.7+.6*noise(vec2(X*f*1.3+seed+t*.03,seed))));
  float on=smoothstep(.22,.72,noise(vec2(X*f*.62+seed*1.7+t*spd*.5,t*.05+seed)));
  return pal(fbm(vec2(X*.2+seed*3.1,t*.012+seed)))*exp(-d*d)*on*(.84+.24*sin(t*.21+seed*2.3));
}
void main(){
  vec2 uv=gl_FragCoord.xy/uRes;float t=uT;
  float X=uX0+uv.x*uXS;
  vec2 w=vec2(fbm(vec2(X*.5+t*.05,uv.y*1.5-t*.03)),fbm(vec2(X*.5+5.3-t*.04,uv.y*1.5+2.1+t*.025)))-.5;
  vec2 q=vec2(X+w.x*.8,uv.y+w.y*.5);
  vec3 c=vec3(0.);
  c=scr(c,ribbon(q,q.x,t,.00,.16,.46,.32,1.3,.05));
  c=scr(c,ribbon(q,q.x,t,.20,.26,.20,.46,4.1,.07));
  c=scr(c,ribbon(q,q.x,t,.36,.30,.13,.62,7.7,-.06));
  c=scr(c,ribbon(q,q.x,t,.10,.22,.17,.78,2.9,.09));
  c=scr(c,ribbon(q,q.x,t,.52,.26,.09,.90,9.2,-.08));
  float st=.6*noise(vec2(q.x*.55+t*.06,q.y*17.))+.4*noise(vec2(q.x*1.1-t*.08,q.y*37.+3.));
  c*=.78+.44*st;
  float top=.76+.24*noise(vec2(X*.5+t*.05,3.)),e=pow(smoothstep(top,-.05,uv.y),.8);
  c*=.72*e;
  c=mix(c,vec3(dot(c,vec3(.3,.59,.11))),uGrey);
  vec3 bg=vec3(8.,5.,4.)/255.;
  vec3 col=bg+(1.-bg)*c;
  col+=(hash(gl_FragCoord.xy+fract(t))-.5)/170.*min(1.,e*20.);
  gl_FragColor=vec4(col,1.);
}`;

  // aurora: soft horizontal ribbons along the whole timeline, warped by noise, drawn by a shader
  // into a quarter-resolution buffer at 30fps and upscaled by the browser.
  // options: grey (boolean), getCam (returns the camera's world x)
  function aurora(host, options) {
    const grey = options && options.grey ? 1 : 0, getCam = (options && options.getCam) || (() => 0);
    const canvas = document.createElement('canvas');
    canvas.style.cssText = 'position:absolute;left:0;right:0;bottom:0;width:100%;height:30vh;display:block';
    host.appendChild(canvas);
    const grain = document.createElement('div'), n = document.createElement('canvas'); n.width = n.height = 256;
    const nx = n.getContext('2d'), img = nx.createImageData(256, 256);
    for (let i = 0; i < img.data.length; i += 4) { const v = Math.random() < 0.5 ? 0 : 255; img.data[i] = img.data[i + 1] = img.data[i + 2] = v; img.data[i + 3] = Math.random() * 10; }
    nx.putImageData(img, 0, 0);
    grain.style.cssText = `position:absolute;inset:0;background:url(${n.toDataURL()}) 0 0/128px 128px`;
    host.appendChild(grain);
    const A = { last: 0, t0: performance.now(), gl: null };
    function fallback() {
      A.gl = null; canvas.style.display = 'none';
      host.style.background = grey
        ? 'radial-gradient(60% 30vh at 45% 100%,#5f5f5f,transparent),radial-gradient(45% 30vh at 8% 100%,#535353,transparent),radial-gradient(40% 30vh at 78% 100%,#454545,transparent)'
        : 'radial-gradient(60% 30vh at 45% 100%,#4f6b50,transparent),radial-gradient(45% 30vh at 8% 100%,#57553f,transparent),radial-gradient(40% 30vh at 78% 100%,#54402f,transparent)';
    }
    function setup() {
      const gl = canvas.getContext('webgl', { alpha: false, antialias: false, depth: false, stencil: false, powerPreference: 'low-power' });
      if (!gl) return fallback();
      const sh = (type, src) => { const o = gl.createShader(type); gl.shaderSource(o, src); gl.compileShader(o); return gl.getShaderParameter(o, gl.COMPILE_STATUS) ? o : null; };
      const v = sh(gl.VERTEX_SHADER, 'attribute vec2 a;void main(){gl_Position=vec4(a,0.,1.);}'), f = sh(gl.FRAGMENT_SHADER, FRAGMENT), prog = gl.createProgram();
      if (!v || !f) return fallback();
      gl.attachShader(prog, v); gl.attachShader(prog, f); gl.linkProgram(prog);
      if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) return fallback();
      gl.useProgram(prog);
      gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
      gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
      const a = gl.getAttribLocation(prog, 'a'); gl.enableVertexAttribArray(a); gl.vertexAttribPointer(a, 2, gl.FLOAT, false, 0, 0);
      const u = name => gl.getUniformLocation(prog, name);
      gl.uniform1f(u('uGrey'), grey);
      Object.assign(A, { gl, uRes: u('uRes'), uT: u('uT'), uX0: u('uX0'), uXS: u('uXS'), w: 0, h: 0 });
    }
    canvas.addEventListener('webglcontextlost', e => { e.preventDefault(); A.gl = null; });
    canvas.addEventListener('webglcontextrestored', setup);
    setup();
    return {
      tick() {
        if (!A.gl) return;
        const now = performance.now(); if (now - A.last < 33) return; A.last = now;
        const gl = A.gl, w = Math.max(2, Math.round(canvas.clientWidth / 4)), h = Math.max(2, Math.round(canvas.clientHeight / 4));
        // one continuous path along the timeline: fixed scale, always moving forward with the camera
        const xs = 2800 * canvas.clientWidth / 1440, x0 = getCam() - xs / 2;
        if (w !== A.w || h !== A.h) { A.w = canvas.width = w; A.h = canvas.height = h; gl.viewport(0, 0, w, h); gl.uniform2f(A.uRes, w, h); }
        gl.uniform1f(A.uT, 40 + (now - A.t0) / 1000);
        gl.uniform1f(A.uX0, x0 / 1000); gl.uniform1f(A.uXS, xs / 1000);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
      },
      destroy() { if (A.gl) { const lose = A.gl.getExtension('WEBGL_lose_context'); lose && lose.loseContext(); } },
    };
  }

  window.BragaSky = { dust, aurora };
})();
