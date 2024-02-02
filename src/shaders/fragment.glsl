#define GLSLIFY 1 
#define PI 3.14159265359 
#define PI2 6.28318530718 

uniform float time;
uniform float pt;
uniform float st;
uniform sampler2D tex;
uniform vec2 ps;
uniform float r;
uniform float fc;
uniform vec2 vc1;
uniform vec2 vc2;
uniform vec2 vc3;
uniform vec4 c1;
uniform vec4 c2;
varying vec2 vUv;

float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float ns(vec2 p) {
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);
    float res = mix(mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x), mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x), u.y);
    return res * res;
}

float ub(vec2 p, vec2 b, float r) {
    return length(max(abs(p) - b + r, 0.0)) - r;
}

vec4 la(vec4 frg, vec4 bc) {
    return frg * frg.a + bc * (1.0 - frg.a);
}

float aastep(float threshold, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * 0.70710678118654757;
    return smoothstep(threshold - afwidth, threshold + afwidth, value);
}

float sw(vec2 pt, vec2 center, float radius, float line_width, float edge_thickness, float side) {
    vec2 d = pt - center;
    float theta = time * .25 * side;
    vec2 p = vec2(cos(theta), -sin(theta)) * radius;
    float h = clamp(dot(d, p) / dot(p, p), 0.0, 1.0);
    //float h = dot(d,p)/dot(p,p);  
    float l = length(d - p * h);
    float gradient = 0.0;
    const float gradient_angle = PI * .25;
    if (length(d) < radius) {
        float angle = mod(theta + atan(d.y, d.x), PI2);
        gradient = clamp(gradient_angle - angle, 0.0, gradient_angle) / gradient_angle * 0.5;
    }
    return gradient + 1.0 - smoothstep(line_width, line_width + edge_thickness, l);
}

void main() {
    vec2 m = vUv;
    vec2 m2 = vUv;
    vec4 n = texture2D(tex, vUv);
    float z = n.r * 2. * PI;
    vec2 dr = vec2(sin(z));
    vec2 uv = vUv + dr * n.r * 0.1;
    float d1 = distance(uv, vc1);
    float d2 = distance(uv, vc2);
    float d3 = distance(uv, vc3);
    float gr = mix(-0.2, 0.2, rand(uv + sin(time)));
    vec2 mv = vec2(time * 0.05, time * -0.05);
    float f = ns((uv * d1 * 2.) + mv);
    f += ns((uv * d2 * 2.5) + vec2(time * -0.075, time * 0.05));
    f += gr;
    f = smoothstep(0., 2., f);
    // f = fract(f);    
    float mx = smoothstep(0., 0.1, f) - smoothstep(0.5, 1., f);
    vec4 color = mix(c1, c2, f);
    float nPt = min(2. * pt, 2. * (1. - pt));
    float u = .3 * sin(m.x * PI + 0.25) * nPt;
    float d = -.3 * sin(m.x * PI + 0.25) * nPt;
    m.y -= mix(u, d, st);
    float ft = step(m.y, pt);
    vec2 rs = ps * (0.5 - vec2(fc * 0.35, fc));
    vec2 rs2 = ps * (0.5 - vec2(fc * 0.35, fc));
    float ra = r;
    vec2 yl = vUv;
    yl.y += 0.002;
    yl.x += 0.00125;
    float cr = ub(((vUv - vec2(fc * 0.35, fc * 0.75)) * ps) - rs, rs, ra);
    float cr2 = ub(((yl - vec2(fc * 0.35, fc * 0.75)) * vec2(ps.x * 0.99725, ps.y * 0.995)) - rs2, rs2, ra);
    cr = clamp(cr, 0.0, 1.);
    cr2 = clamp(cr2, 0.0, 1.);
    vec4 br = vec4(0., 0., 0., 0.);
    vec4 s1 = mix(color, vec4(0., 0., 0., 1.), ft);
    vec3 brcl = vec3(77. / 255.);
    brcl += sw(yl, vec2(0.5), 1.5, 0.00003, 0.00001, 1.) * vec3(85. / 255.);
    vec4 final = mix(s1, la(mix(vec4(brcl, 1.), vec4(0.), cr2), vec4(0., 0., 0., 1.)), cr);
    float alpha = 1.;
    float cut = 0.001;
    alpha *= aastep(cut, m2.x);
    alpha *= 1. - aastep(1. - cut, m2.x);
    alpha *= aastep(cut, m2.y);
    alpha *= 1. - aastep(1. - cut, m2.y);
    gl_FragColor = vec4(final.rgb, alpha);
}