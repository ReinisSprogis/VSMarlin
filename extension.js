const vscode = require('vscode');
const THREE = require('three');

const {hoverInfoActivate} = require('./hover');

  
async function activate(context) {
    console.log('Congratulations, your extension "extension" is now active!');
   hoverInfoActivate(context);
  
  

   
     let disposable = vscode.commands.registerCommand('marlin.showToolpath', async () => {
       // Create and show a new WebView panel
       const panel = vscode.window.createWebviewPanel(
         'toolpathView',
         'Toolpath',
         vscode.ViewColumn.Beside,
         {
           enableScripts: true
         }
       );
   
       // Get the current file G-code content
       const editor = vscode.window.activeTextEditor;
       const document = editor.document;
       const gcodeContent = document.getText();
   
       // Parse G-code and generate 3D toolpath data
       const toolpathData = parseGcode(gcodeContent);
   
       // Render the 3D toolpath in the WebView
       panel.webview.html = getToolpathHtml(toolpathData);
     });
   
     context.subscriptions.push(disposable);
   

}

exports.activate = activate;



function parseGcode(gcodeContent) {
    const lines = gcodeContent.split('\n');
    const coordinates = [];
    let current = new THREE.Vector3();
  
    for (const line of lines) {
      if (line.startsWith('G1')) {
        const matchX = line.match(/X(-?\d+(\.\d+)?)/);
        const matchY = line.match(/Y(-?\d+(\.\d+)?)/);
        const matchZ = line.match(/Z(-?\d+(\.\d+)?)/);
  
        const newX = matchX ? parseFloat(matchX[1]) : current.x;
        const newY = matchY ? parseFloat(matchY[1]) : current.y;
        const newZ = matchZ ? parseFloat(matchZ[1]) : current.z;
  
        const next = new THREE.Vector3(newX, newY, newZ);
        coordinates.push(current, next);
        current = next;
      }
    }
  
    return coordinates;
  }
//   const OrbitControlsConstructor = new Function('THREE', OrbitControlsCode + '\\n return THREE.OrbitControls;');
//   const OrbitControls = OrbitControlsConstructor(THREE);
  
//   const controls = new OrbitControls(camera, renderer.domElement);

//   const points = ${JSON.stringify(toolpathData)};

//   const material = new THREE.LineBasicMaterial({ color: 0xffffff });
//   const geometry = new THREE.BufferGeometry().setFromPoints(points.map(p => new THREE.Vector3(p.x, p.y, p.z)));

//   const line = new THREE.Line(geometry, material);
  
  function getToolpathHtml(toolpathData) {
    const threeJsScript = `https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js`;
 
  
    const toolpathScript = `
   
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);
  
    const loader = new THREE.FileLoader();

        const square = new THREE.BoxGeometry(1, 1, 1);
        const material = new THREE.MeshBasicMaterial({ color: 0xFF0000 });
        const cube = new THREE.Mesh(square, material);
      scene.add(cube);
  
      camera.position.y = 1;
        camera.position.z = 3;
        camera.lookAt(0, 0, 0);
  
      
      
  
    function animate() {
        requestAnimationFrame(animate);
        renderer.render(scene, camera);
      }
      animate();
  `;
  
    return `
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>3D Toolpath Visualization</title>
        <style>
        html, body {
        margin: 0;
        padding: 0;
        overflow: hidden;
        height: 100%;
        }
        </style>
        <script src="${threeJsScript}"></script>
      </head>
      <body>
      <p>Hello<p>
        <script>
        ${toolpathScript}
        </script>
      </body>
    </html>
    
          `;
       }
  