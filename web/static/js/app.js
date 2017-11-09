import "phoenix_html";
import "three-canvas-renderer";

let mouseX = 0,
    mouseY = 0,
    windowHalfX = window.innerWidth / 2,
    windowHalfY = window.innerHeight / 2,
    camera, scene, renderer, container;

const color = 0xffffff;

class showTime {
  constructor() {
    this.wrapper = document.getElementsByClassName('wrapper')[0];
  }

  render() {
    document.addEventListener("DOMContentLoaded", this.showPage() );
  }

  showPage() {
    this.wrapper.classList.add('show');
  }
}

class CanvasBackground {
  constructor() {
    this.container = document.getElementById("canvas"); 
  }

  render() {
    this.initBackground();
    this.animate();
  }

  initBackground() {
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000);
    camera.position.z = 100;

    scene = new THREE.Scene();

    renderer = new THREE.CanvasRenderer({
      alpha: true
    });

    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setClearColor(0x000000, 0); // canvas background color
    renderer.setSize(window.innerWidth, window.innerHeight);
    this.container.appendChild(renderer.domElement);

    let PI2 = Math.PI * 2;
    let material = new THREE.SpriteCanvasMaterial({
      color: color,
      opacity: 0.5,
      program: function(context) {

        context.beginPath();
        context.arc(0, 0, 0.5, 0, PI2, true);
        context.fill();
      }
    });

    this.draw(material);
  }

  draw(material) {
    let geometry = new THREE.Geometry(), 
        particle;

    for (var i = 0; i < 150; i++) {
      particle = new THREE.Sprite(material);
      particle.position.x = Math.random() * 2 - 1;
      particle.position.y = Math.random() * 2 - 1;
      particle.position.z = Math.random() * 2 - 1;
      particle.position.normalize();
      particle.position.multiplyScalar(Math.random() * 10 + 600);
      particle.scale.x = particle.scale.y = 5;
      scene.add(particle);
      geometry.vertices.push(particle.position);
    }

    const line = new THREE.Line(geometry, new THREE.LineBasicMaterial({
      color: color,
      opacity: 0.2
    }));

    scene.add(line);

    document.addEventListener('mousemove', this.onDocumentMouseMove, false);
    window.addEventListener('resize', this.onWindowResize, false);
  }

  onWindowResize() {
    windowHalfX = window.innerWidth / 2;
    windowHalfY = window.innerHeight / 2;
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  }

  onDocumentMouseMove(event) {
    mouseX = (event.clientX - windowHalfX) * 0.05;
    mouseY = (event.clientY - windowHalfY) * 0.2;
  }

  onDocumentTouchStart(event) {
    if (event.touches.length > 1) {
      event.preventDefault();
      mouseX = (event.touches[0].pageX - windowHalfX) * 0.7;
      mouseY = (event.touches[0].pageY - windowHalfY) * 0.7;
    }
  }

  onDocumentTouchMove(event) {
    if (event.touches.length == 1) {
      event.preventDefault();
      mouseX = event.touches[0].pageX - windowHalfX;
      mouseY = event.touches[0].pageY - windowHalfY;
    }
  }

  animate() {
    window.requestAnimationFrame(this.animate.bind(this));
    this.renderAnimation();
  }

  renderAnimation() {
    camera.position.x += (mouseX - camera.position.x) * 0.1;
    camera.position.y += (-mouseY + 200 - camera.position.y) * 0.05;
    camera.lookAt(scene.position);
    renderer.render(scene, camera);
  }
}

const canvas = new CanvasBackground().render();
const fitbit = new showTime().render();
