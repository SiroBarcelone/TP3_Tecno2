import fisica.*;

class Torta {
  FBox tortaBody;
  PImage tortaImg;

  Torta(float x, float y) {
    tortaImg = loadImage("torta.png");
    tortaBody = new FBox(300, 50);
    tortaBody.setStatic(true); // La torta no se moverá por la gravedad
    tortaBody.setPosition(x, y); // Establece la posición del FBox igual que la imagen
    tortaBody.setRestitution(0.6); // Coeficiente de restitución (opcional)
    tortaBody.setDensity(1); // Densidad de la torta (ajusta según sea necesario)
    tortaBody.setGrabbable(false);
  }

  void addToWorld(FWorld world) {
    world.add(tortaBody);
  }

  void display() {
    imageMode(CENTER);
    float posX = tortaBody.getX(); // Obtiene la posición X del FBox
    float posY = tortaBody.getY(); // Obtiene la posición Y del FBox
    image(tortaImg, posX, posY, 300, 200); // Ajusta el tamaño según sea necesario
  }
}
