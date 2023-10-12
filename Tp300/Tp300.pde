import processing.sound.*;
import fisica.*;
import netP5.*;
import oscP5.*;

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
OscP5 osc;

int milisegundos = 0;
int segundos ;//CAMBIAR
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

boolean seTocan=false;

boolean manoDetectada = false;
int TManoDetectada = 0; // Guarda el tiempo en que se detectó la mano
int tEspera = 4000; // 5000 milisegundos = 5 segundos
boolean dedosTocandose = false;
int tiempoInicioToqueDedos = 0;
boolean seTocanAnterior = false;
boolean dedosPresionados = false;

float umbralDistancia = 98898;
PVector indice;
PVector pulgar;
PVector mano;

int contSonido2;
int contSonido;

void setup() {
  size(1000, 650);
  osc = new OscP5(this, 8008);
  indice = new PVector(0, 0);
  pulgar = new PVector(width, height);
  mano = new PVector(0, 0);

  seTocan=false;
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

  contSonido=0;
  contSonido2=0;
}


void draw() {
  if (inicio == true) {

    segundos=100;/////////////////////________-------------------------SEGUNDO
    juego = false;
    perdiste = false;
    ganaste = false;
    nuevaBola = null;
    puntos = 0;

    background(inicioimg);
    //println("INICIO");
    if (dedosTocandose && tiempoInicioToqueDedos != 0) {
      int tiempoActual = millis();
      if (tiempoActual - tiempoInicioToqueDedos >= 3000) { // 3 segundos en milisegundos
        tiempoInicioToqueDedos = 0; // Reiniciar el tiempo de inicio
      }
    } else {
      tiempoInicioToqueDedos = 0; // Reiniciar el tiempo si los dedos se sueltan
    }
  }

  if (juego == true) {//-----------------------------------------------JUEGO
    manoDetectada=false;
    textSize(25);
    if (frameCount % 150 == 0) {
      gravedad = int(random(-300, 300));
      world.setGravity(0, gravedad); // Actualizar la gravedad
      // println("Nueva gravedad: " + gravedad);
    }
    medirGrav = map(gravedad, -300, 300, 0, 360);
    // segundos=120;
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
    textSize(25);
    text("Tiempo:" + segundos, 50, 50);
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

    mapFuerza = map(pulgar.x, pulgar.y, width, height, 265);
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

    cannon.display(); //dibujar canon
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
    text("Puntos: " + sumapuntaje, 50, 85);
    
    if (segundos < 0 && sumapuntaje  <= 4) {
      perdiste = true;
      juego = false;
      inicio=false;
      
    }
    if (sumapuntaje >= 4) {
      ganaste = true;
      juego = false;
      inicio=false;
    }
    pushStyle();
    image(gravMed, width - 150, 150);
    pushMatrix();
    translate(width - 150, 150);
    rotate(radians(medirGrav));
    image(flecha, 0, 0);
    popMatrix();
    popStyle();
  }
  if (perdiste == true) { //----------------------------------------PERDISTE
    for (Bola target : targets) {
      world.remove(target);
    }
    targets.clear();
    nuevaBola = null;
   

    sonido3.play();
    contSonido++;
    if (contSonido>=7) {
      sonido3.stop();
    }

    sonido.amp(1.0);
    segundos = 120;
    puntos = 0;
    sumapuntaje = 0;
    nuevaBola = null;

    //println("PERDISTE");
    juego = false;
    inicio = false;
    perdisteimg.resize(width, height);
    background(perdisteimg);
  } else if (ganaste == true) {
    for (Bola target : targets) {
      world.remove(target);
    }
    targets.clear();
    nuevaBola = null;
    sonido5.stop();
    sonido2.stop();
    sonido3.stop();
    sonido1.stop();
    
    sonido4.play();  ///////////////////////////////////////------------/GANASTE 4
    sonido.amp(0.1);
    contSonido2++;
    if (contSonido2>=7) {
      sonido4.stop();
    }
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
  }

  //println("puntos: "+sumapuntaje);
  //println("tiempo: "+segundos);
  noCursor();
  noStroke();
  fill(255, 0, 0, 100);
  ellipse(pulgar.x, pulgar.y, 30, 30);
}

void oscEvent(OscMessage m) {
  if (m.addrPattern().equals("/annotations/thumb")) { //pulgar
    // Actualiza las coordenadas del pulgar
    pulgar.x = map(m.get(0).floatValue(), 0, 1, 0, width);
    pulgar.y = map(m.get(1).floatValue(), 0, 1, 0, height);
  }

  if (m.addrPattern().equals("/annotations/indexFinger")) {
    // Actualiza las coordenadas del dedo índice
    indice.x = map(m.get(0).floatValue(), 0, 1, 0, width);
    indice.y = map(m.get(1).floatValue(), 0, 1, 0, height);
    float distanciaDedos = dist(indice.x, indice.y, pulgar.x, pulgar.y);

    if (distanciaDedos < umbralDistancia) {
      dedosTocandose = true;
      println(dedosTocandose);

      if (tiempoInicioToqueDedos == 0) {
        tiempoInicioToqueDedos = millis();
        inicioMano();
      }
    } else {
      dedosTocandose = false;
      tiempoInicioToqueDedos = 0;
    }
    println(distanciaDedos);
  }

  if (m.addrPattern().equals("/annotations/palmBase")) {
    // Actualiza las coordenadas de la base de la mano
    mano.x = map(m.get(0).floatValue(), 0, 1, 0, width);
    mano.y = map(m.get(1).floatValue(), 0, 1, 0, height);
    if (!manoDetectada) {
      manoDetectada = true;
      TManoDetectada = millis();
    } else {
      if (millis() - TManoDetectada >= tEspera && inicio==true) {
        juego = true;
        inicio = false;
      }
      if (millis() - TManoDetectada >= tEspera && perdiste==true) {
        perdiste=false;
        inicio=true;
      }
      if (millis() - TManoDetectada >= tEspera && ganaste==true) {
        ganaste=false;
        inicio=true;
      }
    }
  }
}

void inicioMano() {
  if (dedosTocandose==true) {
    //if (juego == true) {
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

        float velocityX = mano.x - cannonPos.x;
        float velocityY = mano.y - cannonPos.y;
        float forceMultiplier = map(pulgar.x, 0, height, 1, 3);
        if (dedosTocandose==true) {
          velocityX *= forceMultiplier;
          velocityY *= forceMultiplier;
          nuevaBola.setVelocity(velocityX, velocityY);
        }
        world.add(nuevaBola);
        targets.add(nuevaBola);
      }
    }
    //}
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
