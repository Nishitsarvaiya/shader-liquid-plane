import {
	Color,
	PerspectiveCamera,
	Scene,
	WebGLRenderer,
	PlaneGeometry,
	DirectionalLight,
	ShaderMaterial,
	Mesh,
	DoubleSide,
	Vector2,
	WebGLRenderTarget,
	LinearFilter,
	RGBAFormat,
	Vector4,
} from "three";
import { OrbitControls } from "three/examples/jsm/Addons";
import vertexShader from "./shaders/vertex.glsl";
import fragmentShader from "./shaders/fragment.glsl";

export default class App {
	constructor() {
		this.init();
	}

	init() {
		console.log("App initialised");
		// viewport
		this.width = window.innerWidth;
		this.height = window.innerHeight;
		this.time = 0;
		this.mouse = new Vector2();
		this.prevMouse = new Vector2();

		this.createComponents();
		this.resize();
		window.addEventListener("resize", () => this.resize());
		this.render();
	}

	createComponents() {
		this.createRenderer();
		this.createCamera();
		// this.createControls();
		this.createScene();
		this.createObjects();
	}

	createRenderer() {
		// renderer
		this.renderer = new WebGLRenderer({ antialias: true, alpha: true });
		this.canvas = this.renderer.domElement;
		document.getElementById("app").appendChild(this.canvas);
		this.renderer.setClearColor(0x242424, 1);
		this.renderer.setPixelRatio(window.devicePixelRatio);
		this.renderer.setSize(this.width, this.height);
	}

	createCamera() {
		this.camera = new PerspectiveCamera(70, this.width / this.height, 100, 2e3);
		this.camera.position.set(0, 0, 600);
	}

	createControls() {
		// controls
		this.controls = new OrbitControls(this.camera, this.canvas);
		this.controls.enableDamping = true;
		this.controls.update();
	}

	createScene() {
		// scene
		this.scene = new Scene();
		this.dispScene = new Scene();
		this.scene.background = new Color(0x242424);
	}

	createLights() {
		// lights
		this.lights = [];
		this.lights[0] = new DirectionalLight(0xffffff, 5);
		this.lights[1] = new DirectionalLight(0xffffff, 5);
		this.lights[2] = new DirectionalLight(0xffffff, 5);
		this.lights[0].position.set(0, 20, 0);
		this.lights[1].position.set(10, 20, 10);
		this.lights[2].position.set(-10, -20, -10);

		this.scene.add(this.lights[0]);
		this.scene.add(this.lights[1]);
		this.scene.add(this.lights[2]);
	}

	createObjects() {
		this.renderTexture = new WebGLRenderTarget(this.width, this.height, {
			minFilter: LinearFilter,
			magFilter: LinearFilter,
			format: RGBAFormat,
		});

		this.geometry = new PlaneGeometry(1, 1, 30, 30);
		this.material = new ShaderMaterial({
			extensions: {
				derivatives: "#extension GL_OES_standard_derivatives : enable",
			},
			uniforms: {
				time: {
					value: 0,
				},
				tex: {
					value: null,
				},
				t: {
					value: 1,
				},
				t2: {
					value: 1,
				},
				pt: {
					value: 0,
				},
				st: {
					value: 0,
				},
				ps: {
					value: new Vector2(this.width, this.height),
				},
				r: {
					value: 0,
				},
				fc: {
					value: 0,
				},
				vc1: {
					value: new Vector2(0.5, 0.5),
				},
				vc2: {
					value: new Vector2(0, 1),
				},
				vc3: {
					value: new Vector2(1, 0),
				},
				c1: {
					value: new Vector4(0, 0, 0, 1),
				},
				c2: {
					value: new Vector4(0.3, 0, 0.9, 0.95),
				},
			},
			transparent: true,
			side: DoubleSide,
			vertexShader: vertexShader,
			fragmentShader: fragmentShader,
		});
		this.plane = new Mesh(this.geometry, this.material);
		this.plane.scale.set(this.width, this.height, 1);
		this.scene.add(this.plane);
	}

	onMove(e) {
		this.mouse.x = e.clientX - this.width / 2;
		this.mouse.y = this.height / 2 - e.clientY;
	}

	resize() {
		this.width = window.innerWidth;
		this.height = window.innerHeight;
		this.material.uniforms.ps.value.x = this.width;
		this.material.uniforms.ps.value.y = this.height;
		this.plane.scale.set(1.15 * this.width, 1.148 * this.height, 1);
		this.camera.fov = 2 * Math.atan(this.height / 2 / 600) * (180 / Math.PI);
		this.renderer.setSize(this.width, this.height);
		this.camera.aspect = this.width / this.height;
		this.camera.updateProjectionMatrix();
	}

	render() {
		requestAnimationFrame(() => this.render());
		this.time += 0.05;
		this.renderer.setRenderTarget(this.renderTexture);
		this.renderer.render(this.dispScene, this.camera);
		this.material.uniforms.tex.value = this.renderTexture.texture;
		this.material.uniforms.time.value = this.time;
		this.renderer.setRenderTarget(null);
		this.renderer.clear();
		this.renderer.render(this.scene, this.camera);
		// this.controls.update();
	}
}
