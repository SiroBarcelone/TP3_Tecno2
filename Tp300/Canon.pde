import fisica.*;

class Canon {
  FBox cannonBody;
  PVector position;
  float width;
  float height;
  float angle; // Ángulo del cañón
  PImage manga;

  Canon(float x, float y, float w, float h) {
    position = new PVector(x, y);
    manga = loadImage("manga.png");
    width = w;
    height = h;
    cannonBody = new FBox(width, height);
    cannonBody.setPosition(x, y);
    cannonBody.setStatic(true); // El cañón no se moverá por la gravedad
    cannonBody.setRestitution(0.6); // Coeficiente de restitución
    cannonBody.setDensity(1); // Densidad del cañón
  }

  void display() {
    // Calcula el ángulo basado en la posición del mouse
    angle = atan2(pulgar.y- position.y, pulgar.x -position.x);

    pushMatrix();
    translate(position.x, position.y);
    rotate(angle); // Aplica la rotación según el ángulo calculado
    fill(0);
    rectMode(CENTER);
    imageMode(CENTER);
    //rect(0, 0, 60, 30);
    image(manga, 0, 0, 60, 60);
    popMatrix();
  }
}
