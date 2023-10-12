
class Bola extends FCircle {
  float densidad; // Densidad de la bola
  int r, g, b; // Componentes RGB del color de la bola
  float radio; // Radio de la bola
  int tipo; // Variable para el tipo de bola
  boolean contacto = false;

  Bola(float radio, float densidad, int tipo) {
    super(radio);
    this.densidad = densidad;
    this.radio = radio;
    this.setDensity(densidad);
    this.tipo = tipo; // Establecer el tipo de bola
    if (contacto == true) {
      setStatic(true); // La torta no se moverá por la gravedad
    }
  }
}

class Cabeza extends Bola {
  Cabeza() {
    super(50, 1000, 1);
  }
}

class Ojo extends Bola {
  Ojo() {
    super(20, 200, 2);
  }
}

class Tentaculo extends Bola {
  Tentaculo() {
    super(40, 500, 3);
  }
}

class Duran extends Bola {
  Duran() {
    super(30, 400, 4);
  }
}
