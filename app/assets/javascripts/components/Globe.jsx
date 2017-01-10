// @flow
//= require three.min
//= require Tween
//= require OrbitControls

class Globe extends React.Component {

  /*
  */

  static worldToScreen(vector){
    let vec = new THREE.Vector3(vector.x, vector.y, vector.z);
    let windowWidth = window.innerWidth;
    let minWidth = 1280;

    if(windowWidth < minWidth) {
      windowWidth = minWidth;
    }

    let widthHalf = (windowWidth/2);
    let heightHalf = (window.innerHeight/2);

    vec.project(this.camera);

    const x = ( vec.x * widthHalf ) + widthHalf;
    const y = - ( vec.y * heightHalf ) + heightHalf;

    return {x, y};
  }

  static gpsToWorld(radius, lat, lon, elevation = 0) {
    const phi   = (90-lat)*(Math.PI/180);
    const theta = (lon+180)*(Math.PI/180);

    const r = radius + (elevation / 2.0);
    const x = -(r * Math.sin(phi)*Math.cos(theta));
    const z = (r * Math.sin(phi)*Math.sin(theta));
    const y = (r * Math.cos(phi));

    return {x, y, z};
  }

  static gpsToScreen(radius, lat, lon, elevation = 0) {
    return this.worldToScreen(this.gpsToWorld(radius, lat, lon, elevation));
  }

  constructor(props: mixed) {
    super(props);

    const { renderer, scene, width, height, texturePath } = this.props;
    this.camera = new THREE.OrthographicCamera(width / -2, width / 2, height / 2, height / -2, 1, 10000);

    renderer.setPixelRatio(window.devicePixelRatio );
    renderer.setSize( width, height );
    renderer.setClearColor(0x112330);

    this.camera.position.z = width * 2;
    this.camera.position.y = height;
    this.camera.position.x = 0;

    const controls = new OrbitControls(this.camera, renderer.domElement);

    controls.enableDamping = true;
    controls.dampingFactor = 0.1;
    controls.autoRotate = true;
    controls.autoRotateSpeed = 0.1;
    controls.rotateSpeed = 0.2;
    controls.zoomSpeed = 0.2;
    controls.minPolarAngle = 45*Math.PI/180.0;
    controls.maxPolarAngle = 135*Math.PI/180.0;
    controls.enablePan = false;
    controls.enableKeys = false;
    //save a reference
    this.controls = controls;

    scene.add(new THREE.AmbientLight( 0xffffff ));

    const earth = new Earth(height / 2, texturePath)
    scene.add(earth);
    requestAnimationFrame(this.update.bind(this));

    controls.dollyTo(0.01);
    //zoom us in!
    new TWEEN.Tween({zoom: 0.01})
      .easing(TWEEN.Easing.Cubic.InOut)
      .to({zoom: 1.0}, 3000)
      .onUpdate(function() {
        controls.dollyTo(this.zoom);
      })
      .delay(500)
      .onComplete(() => {
        earth.performIntroduction()
      })
      .start();
  }

  componentDidMount() {
    requestAnimationFrame(this.update.bind(this));
    this.wrapperEl.appendChild(this.props.renderer.domElement);
  }

  // THREE's render loop.
  update(timestamp) {
    TWEEN.update();
    this.controls.update();
    this.props.renderer.render(this.props.scene, this.camera);

    requestAnimationFrame(this.update.bind(this));
  }

  // React's render loop
  render() {
    const overlayStyle = {
      zIndex: 10,
      position: 'absolute',
      top: 0,
      left: 0,
      width: this.props.width,
      height: this.props.height,
      pointerEvents: 'none',
      color: 'white',
    };
    return(
      <div ref={ (element) => {this.wrapperEl = element }} className='globe' style={{position: 'relative'}}>
        <div style={overlayStyle}>
        </div>
      </div>

    );
  }
}

class Markers extends THREE.Group {
  // this adds markers to the object's parent geometry
  constructor(placementGeometry) {
    super();

    this.placementGeometry = placementGeometry; //what are we placing our markers on?
    this.addMarker(new SpikeMarker(50), 35.6895, 139.6917); //Tokyo
    this.addMarker(new SpikeMarker(10), 31.2304, 121.4737); //Shanghai
    this.addMarker(new SpikeMarker(10), 52.5200, 13.4050); //Berlin
    this.addMarker(new SpikeMarker(50), 51.5074, 0.1278); //London
    this.addMarker(new SpikeMarker(20), 48.8566, -2.3522); //Paris
    this.addMarker(new SpikeMarker(50), 40.7128, -74.0059); //NYC
    this.addMarker(new SpikeMarker(30), 42.3601, -71.0589); //Boston
    this.addMarker(new SpikeMarker(10), 41.8781, -87.6298); //Chicago
    this.addMarker(new SpikeMarker(5), 25.7617, -80.1918); //Miami
    this.addMarker(new SpikeMarker(40), 34.0522, -118.2437); //LA
    this.addMarker(new SpikeMarker(30), 37.7749, -122.4194); //SF
    this.addMarker(new SpikeMarker(20), 47.6062, -122.3321); //Seatle
    this.addMarker(new SpikeMarker(20), -26.2041, 28.0473); //johanesburg
    this.addMarker(new SpikeMarker(20), -33.8688,151.2093); //
    this.addMarker(new SpikeMarker(15),-25.2048, -55.2708);
    this.addMarker(new SpikeMarker(20),-23.5505, -46.6333);
    this.addMarker(new SpikeMarker(25),23.6345, -102.5528);
    this.addMarker(new SpikeMarker(20),19.0760,  72.8777);
    this.addMarker(new SpikeMarker(20),1.3521, 103.8198);

    const maxPoints = 2000;
    this.loadMarkers('/answers_map.json', (data) => {
      let pointsCount = 0;
      for(const location of data.locations) {
        this.addMarker(new MinorMarker(), location.lat, location.lng);
        pointsCount+=1;
        if(pointsCount >= maxPoints) {
          return;
        }
      }
    });
  }

  loadMarkers(url, callback) {
    const request = new XMLHttpRequest();
    request.open('GET', url);
    request.onload = () => {
      const json = JSON.parse(request.responseText);
      callback(json);
    }
    request.onerror = () => console.error(request);
    request.send();
  }

  addMarker(marker: Marker, lat: number, lon: number) {
    this.placeOnEarth(marker, lat, lon, 1);
    this.add(marker);
    marker.onComplete(() => {
      this.remove(marker);
    });
  }

  placeOnEarth(object: THREE.Object3D, lat: number, lon: number, elevation = 0) {
    const radius = this.placementGeometry.parameters.radius;

    const {x,y,z} = Globe.gpsToWorld(radius, lat, lon, elevation);
    object.position.set(x,y,z);
    object.lookAt(new THREE.Vector3(0,0,0));
    object.rotateX( -1.5708 );
  }
}

class Marker extends THREE.Object3D {
  onComplete(callback) {
    if(this.tween) {
      this.tween.onComplete(callback);
    }
  }
}

class SpikeMarker extends Marker {
  onComplete(callback) {
    //void function. do not perform
  }
  constructor(magnitude = 100) {
    super();

    //TODO: make our own buffered line here:
    const geo = new THREE.CubeGeometry(10, 2, 10);
    geo.translate(0,1,0); //the height / 2
    const topColor = new THREE.Color(0x56f0ff);
    const bottomColor = new THREE.Color(0x0477d6);
    for(let i=0; i<12; i++) {
      if(i%2 == 0) {
        geo.faces[i].vertexColors = [bottomColor, topColor, bottomColor];
      }
      else {
        geo.faces[i].vertexColors = [topColor, topColor, bottomColor];
      }
    }
    geo.faces[4].vertexColors = [bottomColor, bottomColor, bottomColor];
    geo.faces[5].vertexColors = [bottomColor, bottomColor, bottomColor];
    geo.faces[6].vertexColors = [topColor, topColor, topColor];
    geo.faces[7].vertexColors = [topColor, topColor, topColor];

    const mat = new THREE.MeshLambertMaterial({color: 0xffffff, transparent: true, opacity: 0.8, vertexColors: THREE.FaceColors});
    const mesh = new THREE.Mesh(geo, mat);
    this.add(mesh);

    this.tween = new TWEEN.Tween(mesh.scale)
      .easing(TWEEN.Easing.Elastic.InOut)
      .to({y:magnitude}, 3000)
      .delay(Math.random()*1000)
      .start();
  }
}

class MinorMarker extends Marker {
  constructor(size) {
    super();
    if(size == undefined) {
      size = Math.random() * 20 + 5;
    }
    const geo = new THREE.Geometry();
    geo.vertices.push( new THREE.Vector3() );
    //const mat = new THREE.PointsMaterial({size: size, color: 0xf0ab4e, transparent: true});
    //const mat = new THREE.PointsMaterial({size: size, color: 0x009dff, transparent: true});
    //const mat = new THREE.PointsMaterial({size: size, color: 0x56f0ff, transparent: true});
    const mat = new THREE.PointsMaterial({size: size, color: 0x7ae8ff, transparent: true});
    const points = new THREE.Points(geo, mat);
    this.add(points);
    this.tween = new TWEEN.Tween(points.material)
      .to({opacity: 0}, (Math.random() * 1000) + 1000)
      .repeat(1000)
      .start();
  }
}

class BeaconMarker extends Marker {
  constructor() {
    super();
    const geo = new THREE.RingBufferGeometry(10,20, 12,1);
    const mat = new THREE.MeshBasicMaterial({color: 0x0008BF3});
    const object = new THREE.Mesh(new THREE.CircleBufferGeometry(20,12,1), mat);
    const pulseMat = new THREE.MeshBasicMaterial({color: 0x008BF3, transparent: true, opacity: 0.5})
    const pulse = new THREE.Mesh(geo, pulseMat);
    pulse.scale.set(2,2,2);

    object.add(pulse);
    object.rotateX( -1.5708 );

    this.add(object);
    new TWEEN.Tween(pulse.scale)
      .to({x:3,y:3},1000)
      .repeat(3)
      .start();

    this.tween = new TWEEN.Tween(pulse.material)
      .to({opacity: 0.1}, 1000)
      .repeat(3)
      .start();
  }
}

class NoiseMarker extends Marker {
  constructor(radius, magnitude) {
    super();
    const geo = new THREE.CircleBufferGeometry(radius, 8);
    const mat = new THREE.ShaderMaterial({
      transparent: true,
      blending: THREE.AdditiveBlending,
      uniforms: {
        amount: { type: "f", value: 100 },
        jitter: { type: "f", value: 1 },
        blur: {type: "f", value: 0 },
      },
      vertexShader: `
        varying vec2 vUv;
        void main() {
          vUv = uv;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);
        }
      `,
      fragmentShader: `
        varying vec2 vUv;
        uniform float amount;
        uniform float jitter;
        uniform float blur;
        vec3 hash3( vec2 p )
        {
          vec3 q = vec3( dot(p,vec2(127.1,311.7)),
                         dot(p,vec2(269.5,183.3)),
                         dot(p,vec2(419.2,371.9)) );
          return fract(sin(q)*43758.5453);
        }

        float iqnoise( in vec2 x, float u, float v )
        {
          vec2 p = floor(x);
          vec2 f = fract(x);
          float k = 1.0+63.0*pow(1.0-v,4.0);
          float va = 0.0;
          float wt = 0.0;
          for( int j=-2; j<=2; j++ ) {
            for( int i=-2; i<=2; i++ ) {
              vec2 g = vec2( float(i),float(j) );
              vec3 o = hash3( p + g )*vec3(u,u,1.0);
              vec2 r = g - f + o.xy;
              float d = dot(r,r);
              float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
              va += o.z*ww;
              wt += ww;
            }
          }
          return va/wt;
        }

        void main(void)
        {
          vec2 p = 0.5 - 0.5*sin( vUv );
          p = p*p*(3.0-2.0*p);
          p = p*p*(3.0-2.0*p);
          p = p*p*(3.0-2.0*p);
          float f = iqnoise( amount*vUv, jitter, blur ) / 3.0;
          gl_FragColor = vec4( f, f, f, 0.5 );
        }
      `,
    });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.rotateX(-1.5);
    this.add(mesh);
  }
}

class Skybox extends THREE.Object3D {
  constructor() {
    super();

    const width = window.innerWidth;
    const geo = new THREE.CubeGeometry(width, width, width);

  }
}

class WorldGrid extends THREE.Object3D {
  constructor(radius, meridians, parallels) {
    super();

    this.type = 'WorldGrid'

    const geometry = new THREE.SphereBufferGeometry(radius, meridians, parallels);
    const material = new THREE.PointsMaterial({size: 18, color: 0x275f86, sizeAttenuation: true});
    const points = new THREE.Points(geometry, material);

    this.add(points);
  }
}

class Earth extends THREE.Group {
  static earthMaterial(texturePath) {
    return(
      new THREE.ShaderMaterial({
        uniforms: {
          map: { value: new THREE.TextureLoader().load(texturePath) },
        },
        vertexShader: `
          varying vec3 vNormal;
          varying vec2 vUv;
          void main() {
            gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
            vNormal = normalize( normalMatrix * normal );
            vUv = uv;
          }
        `,
        fragmentShader: `
          uniform sampler2D map;
          uniform vec2 markerPosition;

          varying vec3 vNormal;
          varying vec2 vUv;

          void main() {
            vec3 diffuse = texture2D(map, vUv).xyz;

            float intensity = 1.0 - dot( vNormal, vec3( 0.0, 0.0, 1.0 ) );
            vec3 atmosphere = vec3( 0.0078431, 0.16470, 0.4 ) * pow( intensity, 4.0 );

            gl_FragColor = vec4(diffuse + atmosphere, 1.0);
          }
        `,
      })
    );
  }

  static atmosphereMaterial() {
    return(
      new THREE.ShaderMaterial({
        side: THREE.BackSide,
        blending: THREE.AdditiveBlending,
        transparent: true,
        uniforms: {},
        vertexShader: `
          varying vec3 vNormal;
          void main() {
            vNormal = normalize( normalMatrix * normal );
            gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
          }
        `,
        fragmentShader: `
          varying vec3 vNormal;
          void main() {
            float intensity = pow(0.8 - dot(vNormal, vec3(0, 0, 1.0)), 10.0);
            gl_FragColor = vec4(0.0078431, 0.16470, 0.4, 0.5) * intensity;
          }
        `})
    );
  }

  constructor(radius, texturePath) {
    super();

    this.type = 'Earth';

    /*
    const loader = new THREE.JSONLoader();
    loader.load('/sphere.json', function ( object ) {

      object.traverse( child => {
        if ( child instanceof THREE.Mesh ) {
          child.scale.set(width, width, width);
        }
      });

      const geometry = object.scale(width / 2, width / 2, width / 2);
      const mesh = new THREE.Mesh(geometry, new THREE.MeshBasicMaterial({ wireframe: true}));

      scene.add( mesh );
      }, this.onProgress, this.onError );
    */

    const geometry = new THREE.SphereBufferGeometry( radius, 24, 32 );
    const mesh = new THREE.Mesh(geometry, this.constructor.earthMaterial(texturePath));

    mesh.name = 'earthMesh';

    const atmosphere = new THREE.Mesh(geometry, this.constructor.atmosphereMaterial());
    atmosphere.scale.set(1.03, 1.03, 1.03);

    this.add(mesh);
    this.add(atmosphere)
    this.add(new WorldGrid(radius, 48, 48));
    this.rotation.order = 'ZXY';
    this.rotation.y = -180*Math.PI/180.0;
  }

  // the TADA
  performIntroduction() {
    const earthGeo = this.children[0].geometry;
    this.add(new Markers(earthGeo));
  }

}

Globe.defaultProps = {
  width: window.innerWidth,
  height: window.innerHeight,
  renderer: new THREE.WebGLRenderer( { antialias: true }),
  scene: new THREE.Scene(),
  locations: [],
}
