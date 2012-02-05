// http://www.html5canvastutorials.com/demos/labs/html5_canvas_flash_killer/
// Original code by Eric Rowell

#import('dart:html');

class MousePos {
  num x;
  num y;
  MousePos(this.x,this.y);
}

class MouseState {
  MousePos pos;
  bool down;
  MouseState() {
    pos = new MousePos(0,0);
    down = false;
  }
}

class Particle {
  num x;
  num y;
  num imgX;
  num imgY;
  num vx;
  num vy;
  bool isRolling;
  bool isLocked;
  Particle(this.x, this.y, this.imgX, this.imgY, this.vx, this.vy, this.isRolling, this.isLocked);
}

class flashkiller {

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  Stopwatch stopwatch;
  var timeDiff = 0;
  List<Particle> particles;
  var crossHairRadius = 25;
  MouseState mouse; 
  ImageElement imageObj;
  
  flashkiller() {
    particles = new List<Particle>();
    mouse = new MouseState();
  }

  void run() {
    onload();
  }
  
  void onload() {
    canvas = document.query("#myCanvas");
    context = canvas.getContext("2d");
    
    // init particles
    for (var n = 0; n < 30; n++) {
      for (var i = 0; i < 30; i++) {
        var imgX = n * 10;
        var imgY = i * 10;
        particles.add(new Particle(
          imgX+139,
          imgY,
          imgX,
          imgY,
          0,
          0,
          false,
          true));
      }
    }
    
    canvas.on.click.add((MouseEvent event) {
      mouse.down = true;
    }, false);
    
    canvas.on.mouseMove.add((MouseEvent event) {
      mouse.pos.x = event.offsetX;
      mouse.pos.y = event.offsetY;
    }, false);
    
    canvas.on.mouseOut.add((MouseEvent event) {
      mouse.pos.x = event.offsetX;
      mouse.pos.y = event.offsetY;
    }, false);
    
    imageObj = new Element.tag('img');
    imageObj.on.load.add((var event) {
      stopwatch = new Stopwatch.start();
      drawFrame(int t) {
        stopwatch.stop();
        timeDiff = stopwatch.elapsedInMs();
        stopwatch.reset();
        stopwatch.start();
        // update
        updateParticles();
        
        // clear
        context.clearRect(0, 0, canvas.width, canvas.height);
        
        // draw
        drawParticles();
        drawCrossHair();
        
        // request new animation frame
        document.window.webkitRequestAnimationFrame(drawFrame, canvas);
      }
      drawFrame(0);
    });
    imageObj.src = "flash_img.jpg";
    
  }
  
//  animate() {
//   
//  }
  
  updateParticles() {
    if (mouse.down) {
      particles.forEach((var particle) {
        var radius = Math.sqrt(Math.pow(particle.x - mouse.pos.x, 2) +
          Math.pow(particle.y - mouse.pos.y, 2));
        
        if (radius <= crossHairRadius) {
          var vx = ((Math.random() * 10) - 5) * timeDiff / 10;
          var vy = ((Math.random() * 10) - 5) * timeDiff / 10;
          
          particle.vx = vx;
          particle.vy = vy;
          particle.isLocked = false;
          particle.isRolling = false;      
        }          
      });
      mouse.down = false;
    }
    
    particles.forEach((var particle) {
      var floorFriction = 0.003 * timeDiff;
      var gravity = 0.005 * timeDiff;
      var collisionDamper = 3;
      
      if (!particle.isLocked) {
        particle.x += particle.vx;
        particle.y += particle.vy;
        
        if (particle.isRolling) {
            if (particle.vx > 0) {
                particle.vx -= floorFriction;
                if (particle.vx <= 0) {
                    particle.isLocked = true;
                }
            }
            else {
                particle.vx += floorFriction;
                if (particle.vx > 0) {
                    particle.isLocked = true;
                }
            }
            
            if (particle.x > canvas.width - 10) {
                particle.vx *= -1;
            }
            else if (particle.x < 0) {
                particle.vx *= -1;
            }
        } else {
            particle.vy += gravity;
            
            if (particle.x > canvas.width - 10) {
                particle.x = canvas.width - 10;
                particle.vx /= collisionDamper;
                particle.vx *= -1;
            }
            if (particle.x < 0) {
                particle.x = 0;
                particle.vx /= collisionDamper;
                particle.vx *= -1;
            }
            
            if (particle.y > canvas.height - 10) {
                particle.y = canvas.height - 10;
                particle.vy /= collisionDamper;
                particle.vy *= -1;
            }
            if (particle.y < 0) {
                particle.y = 2;
                particle.vy /= collisionDamper;
                particle.vy *= -1;
            }
            
            //if particle is about to roll on floor ...
            if (particle.vy.abs() < 0.5 &&
            particle.y > canvas.height - 13) {
            
                particle.y = canvas.height - 10;
                particle.vy = 0;
                particle.isRolling = true;
            }
        }
      }
    });
  }
  
  drawParticles() {
    particles.forEach((var particle) {
      context.drawImage(imageObj, particle.imgX, particle.imgY, 
        10, 10, particle.x, particle.y, 10, 10);
    });
  }
  
  drawCrossHair() {
    var mouseX = mouse.pos.x;
    var mouseY = mouse.pos.y;
    
    context.globalAlpha = 0.5;
    context.beginPath();
    context.arc(mouseX, mouseY, crossHairRadius, 0, 2 * Math.PI, false);
    context.fillStyle = "blue";
    context.fill();
    
    context.globalAlpha = 1;
    context.moveTo(mouseX, mouseY - crossHairRadius - 10);
    context.lineTo(mouseX, mouseY + crossHairRadius + 10);
    context.strokeStyle = "black";
    context.lineWidth = 4;
    context.stroke();
    
    context.beginPath();
    context.moveTo(mouseX - crossHairRadius - 10, mouseY);
    context.lineTo(mouseX + crossHairRadius + 10, mouseY);
    context.strokeStyle = "black";
    context.lineWidth = 4;
    context.stroke();
  }

  void write(String message) {
    // the HTML library defines a global "document" variable
    document.query('#status').innerHTML = message;
  }
}

void main() {
  new flashkiller().run();
}
