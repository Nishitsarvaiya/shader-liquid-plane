#define GLSLIFY 1 

uniform float t;
uniform float t2;
uniform float time;
uniform float pt;
varying vec2 vUv;

float ea1(float x) {
    return x < 0.5 ? 16. * x * x * x * x * x : 1. - pow(-2. * x + 2., 5.) / 2.;
}
float ea2(float x) {
    return x < 0.5 ? 8. * x * x * x * x : 1. - pow(-2. * x + 2., 4.) / 2.;
}
float pi = 3.14159265359;

void main() {
    vUv = uv;
    vec3 pos = position;
    pos.z -= 85.;
    vec2 ct = vec2(0.5);
    float p = ea1(t);
    float p2 = ea2(t2);
    float np = min(2. * p2, 2. * (1. - p2));
    pos.y -= .15 * sin(uv.x * pi + 0.25) * np;
    pos.y += 1. * (1. - p);
    float nPt = min(2. * pt, 2. * (1. - pt));
    // pos.x *= 1. -(0.05 * (pt));  
    float dist = distance(vUv, ct);
    float md = length(ct);
    float nd = dist / md;
    float b = nd * 150.;
    float c = -nd * 150.;
    float fm = mix(c, b, pt);
    // pos.z -= fm * nPt;  
    float dt = distance(vec2(uv), vec2(0.5)) * 1.25;
    pos.z -= dt * 85. * pt;
    pos.y *= 1. + (0.11 * pt);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}