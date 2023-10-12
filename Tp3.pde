import processing.sound.*;
import fisica.*;


//__captura
int PUERTO_OSC = 12345;
//Receptor receptor;

float poscX;
float poscY;
boolean monitor=true;
PFont fuente;

SoundFile sonido1;
SoundFile sonido2;
SoundFile sonido3;
SoundFile sonido4;
SoundFile sonido5;
SoundFile sonido6;

FWorld world;
Canon cannon;
Torta torta;
SoundFile sonido;

int milisegundos = 0;
int segundos = 20;//CAMBIAR
int Valor = 1;
PVector cannonPos;
int puntos = 0;
boolean suma = false;
int sumapuntaje;
int counter;
float cannonWidth = 40;
float cannonHeight = 20;
ArrayList<Bola> targets = new ArrayList<Bola>();
float bolaRadio = 10; // Radio de la bola
PImage inicioimg;
PImage fondo;
PImage[] ingredientes;
PImage ganasteimg;
PImage perdisteimg;
PImage flecha;
PImage gravMed;
float distancia;
float mapFuerza;
String tipoDeBolaActual = "Ninguna"; // Variable para mostrar el tipo de bola actual
int gravedad = 100;
float medirGrav;
int countpuntaje = 0;
Bola nuevaBola = null; // Declarar nuevaBola como una variable global
Bola bolaActual;

boolean juego;
boolean inicio;
boolean perdiste;
boolean ganaste;

void setup() {
  size(1000, 650);
  //Inicio cap
  setupOSC(PUERTO_OSC);
  //receptor = new Receptor();
  fuente = createFont("SOLAR.ttf", 20);
  textFont(fuente);
  juego = false;
  inicio = true;
  perdiste = false;
  ganaste = false;
  sonido = new SoundFile(this, "ambiente.mp3");
  sonido1 = new SoundFile(this, "boton2.mp3"); // SONIDO
  sonido2= new SoundFile (this, "ambiente.mp3"); //SONIDO
  sonido3= new SoundFile (this, "fallaste.mp3"); //SONIDO
  sonido4= new SoundFile (this, "ganaste.mp3"); //SONIDO
  sonido5= new SoundFile (this, "Acabotiempo.mp3"); //SONIDO
  sonido6= new SoundFile (this, "lanzar4.mp3"); //SONIDO


  sonido.play();//SONIDO
  sonido.amp(1.0);

  Fisica.init(this);
  world = new FWorld();
  world.setEdges();
  torta = new Torta(width - 250, height - 100);
  torta.addToWorld(world);
  cannonPos = new PVector(50, height - 50);
  inicioimg = loadImage("inicio.png");
  inicioimg.resize(width, height);
  fondo = loadImage("fondo.png");
  perdisteimg = loadImage("perdiste.png");
  ganasteimg = loadImage("ganaste.png");
  flecha = loadImage("Flecha.png");
  gravMed = loadImage("gravedad.png");
  flecha.resize(40, 70);
  gravMed.resize(120, 120);
  fondo.resize(width, height);
  counter = 120;
  ingredientes = new PImage[4];
  ingredientes[0] = loadImage("ing1.png");
  ingredientes[1] = loadImage("ing2.png");
  ingredientes[2] = loadImage("ing3.png");
  ingredientes[3] = loadImage("ing4.png");



  // Inicializar el cañón
  cannon = new Canon(cannonPos.x, cannonPos.y, cannonWidth, cannonHeight);

  // Crear la primera bola con valor 1
  bolaActual = generarNuevaBola(Valor);
}


void draw() {

  if (inicio == true) {
    juego = false;
    perdiste = false;
    ganaste = false;
    nuevaBola = null;
    segundos = 10;
    puntos = 0;
    background(inicioimg);
    //println("INICIO");
  } else if (juego == true) {
    textSize(25);
    //println("JUEGO");
    if (frameCount % 150 == 0) {
      gravedad = int(random(-300, 300));
      world.setGravity(0, gravedad); // Actualizar la gravedad
      // println("Nueva gravedad: " + gravedad);
    }
    medirGrav = map(gravedad, -300, 300, 0, 360);

    //println("JUEGO");

    inicio = false;
    perdiste = false;
    ganaste = false;
    background(fondo);
    imageMode(CENTER);
    world.step();
    torta.display();

    // Muestra el tipo de bola actual en la pantalla
    pushStyle();

    textSize(16);
    fill(0);

    imageMode(CENTER);
    milisegundos++;

    if (milisegundos > 60) {
      milisegundos = 0;
      segundos--;
    }

    if (segundos <= 12 && !sonido5.isPlaying()) {
      sonido5.play();
      sonido.amp(1.0);
    } else {
      sonido5.stop();
    }

    //    if (segundos <= 0 || juego == false) {
    //    }

    textSize(25);
    text("Tiempo:" + segundos, 20, 30);
    for (int i = 0; i < targets.size(); i++) {
      Bola target = targets.get(i);
      pushMatrix();
      translate(target.getX(), target.getY());
      rotate(target.getRotation());
      // Cambiar el color por la imagen correspondiente
      image(ingredientes[target.tipo - 1], 0, 0, target.getSize(), 
        (ingredientes[target.tipo - 1].height * target.getSize()) / ingredientes[target.tipo - 1].width);
      popMatrix();
    }
    popStyle();

    mapFuerza = map(mouseY, 0, height, height, 265);
    noStroke();
    fill(230, 0, 20, 90);
    rect(80, 270, 83, 270 - mapFuerza);
    pushMatrix();
    fill(230, 0, 20);
    textMode(CORNER);
    translate(22, 250);
    rotate(radians(270));
    text("Fuerza", 0, 0);
    popMatrix();

    cannon.display();
    if (nuevaBola != null) {
      if (nuevaBola.getX() > torta.tortaBody.getX() - 150 &&
        nuevaBola.getX() < torta.tortaBody.getX() + 150 &&
        nuevaBola.getY() > torta.tortaBody.getY() - 55) {
        if (!nuevaBola.contacto) {
          nuevaBola.contacto = true;
          nuevaBola.setStatic(true);
          sumapuntaje++;
          Valor = (Valor % 4) + 1; // Actualiza el valor en un ciclo de 1 a 4
          bolaActual = generarNuevaBola(Valor);
        }
      }
    }
    text("Puntos: " + sumapuntaje, 20, 60);
    if (segundos < 0 && sumapuntaje < 4) {
      perdiste = true;
      juego = false;
    }
    if (sumapuntaje >= 4) {
      ganaste = true;
      juego = false;
    }
    pushStyle();
    image(gravMed, width - 150, 150);
    pushMatrix();
    translate(width - 150, 150);
    rotate(radians(medirGrav));
    image(flecha, 0, 0);
    popMatrix();
    popStyle();
  } else if (perdiste == true) {
    for (Bola target : targets) {
      world.remove(target);
    }
    targets.clear();
    nuevaBola = null;    
    sonido5.stop();
    sonido3.play();
    segundos = 120;
    puntos = 0;
    sumapuntaje = 0;
    nuevaBola = null;
    //println("PERDISTE");
    juego = false;
    inicio = false;
    perdisteimg.resize(width, height);
    background(perdisteimg);
    //text("PERDISTE", 40, 40);
    if (mousePressed) {
      inicio=true;
    }
  } else if (ganaste == true) {
    for (Bola target : targets) {
      world.remove(target);
    }
    targets.clear();
    nuevaBola = null;    
    sonido5.stop();
    sonido4.play();
    sonido.amp(0.1);
    segundos = 120;
    puntos = 0;
    sumapuntaje = 0;
    nuevaBola = null;
    //println("GANASTE");
    juego = false;
    inicio = false;
    ganasteimg.resize(width, height);
    background(ganasteimg);
    textSize(50);
    fill(50, 255, 50);
    textMode(CENTER);
    text("GANASTE", width/2, height/2);
    if (mousePressed) {
      ganaste=false;
      inicio=true;
    }
  }

  println("puntos: "+sumapuntaje);
  println("tiempo: "+segundos);
  noCursor();
  noStroke();
  fill(255, 0, 0, 100);
  ellipse(mouseX, mouseY, 30, 30);
}


void mousePressed() {
  if (juego == true) {
    nuevaBola = generarNuevaBola(Valor);
    if (nuevaBola != null) {
      // Verificar si la nueva bola no está en la misma posición que otras bolas
      boolean nuevaBolaValida = true;
      for (Bola target : targets) {
        float distancia = dist(nuevaBola.getX(), nuevaBola.getY(), target.getX(), target.getY());
        if (distancia < 2 * bolaRadio) {
          nuevaBolaValida = false;
          break;
        }
      }

      if (nuevaBolaValida) {
        sonido6.play();
        nuevaBola.setPosition(cannonPos.x, cannonPos.y - cannonHeight / 2 - bolaRadio);
        nuevaBola.setRestitution(0.6);
        nuevaBola.setDensity(nuevaBola.densidad);

        float velocityX = mouseX - cannonPos.x;
        float velocityY = mouseY - cannonPos.y;
        float forceMultiplier = map(mouseY, height, 0, 1, 3);
        velocityX *= forceMultiplier;
        velocityY *= forceMultiplier;
        nuevaBola.setVelocity(velocityX, velocityY);

        world.add(nuevaBola);
        targets.add(nuevaBola);
      }
    }
  }
  if (inicio == true && mousePressed) {
    sonido1.play();
    sonido.amp(1.0);
    juego = true;
    inicio = false;
  }
}


Bola generarNuevaBola(int Valor) {
  Bola nuevaBola = null;
  if (Valor == 1) {
    nuevaBola = new Duran();
    tipoDeBolaActual = "Tipo 1";
  } else if (Valor == 2) {
    nuevaBola = new Cabeza();
    ingredientes[0].resize(50, 80);
    tipoDeBolaActual = "Tipo 2";
  } else if (Valor == 3) {
    nuevaBola = new Tentaculo();
    ingredientes[2].resize(40, 60);
    tipoDeBolaActual = "Tipo 3";
  } else if (Valor == 4) {
    nuevaBola = new Ojo();
    tipoDeBolaActual = "Tipo 4";
  }
  return nuevaBola;
}
