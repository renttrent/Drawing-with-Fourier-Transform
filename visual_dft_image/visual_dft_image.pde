// path to image
String path = "shape.png";

// delta x or time
PImage img;
float dx = 0;
ArrayList<PVector> wave = new ArrayList<PVector>();
int c = 0;

// complex input
ArrayList<Complex> input = new ArrayList<Complex>();
ArrayList<Complex> output = new ArrayList<Complex>();

float scale;

// Holding complex numbers
class Complex {
  float re, im;
  Complex(float x, float y) {
    this.re = x;
    this.im = y;
  }
  void sum(Complex other) {
    this.re += other.re;
    this.im += other.im;
  }
  Complex dotmult(Complex other) {
    float rv_re = this.re * other.re - this.im * other.im;
    float rv_im = this.re * other.im + this.im * other.re;
    return new Complex(rv_re, rv_im);
  }
}

// class for holding some values (complex number, freq, amp, phase)
class Signal {
  Complex complex;
  float freq, amp, phase;
  Signal(Complex complex, float freq, float amp, float phase) {
    this.complex = complex;
    this.freq = freq;
    this.amp = amp;
    this.phase = phase;
  }
}
// array of fourier transform values
Signal ft[];

// discrete fourier transform function
Signal[] dft(ArrayList<Complex> nrs) {
  c++;
  int N = nrs.size();
  Signal rv[] = new Signal[N]; // will hold N elements
  // looping through signal
  for (int k = 0; k < N; k++) {
    Complex sum = new Complex(0, 0);
    for (int n = 0; n < N; n++) {
      Complex num =  new Complex(cos(2*PI*k*n/N), -sin(2*PI*k*n/N));
      sum.sum(nrs.get(n).dotmult(num));
    }
    sum.re = sum.re / N;
    sum.im = sum.im / N;

    float freq = k;
    float amp = sqrt(sum.re*sum.re + sum.im*sum.im); // magnitude of a vector (pythogorian)
    float phase = atan2(sum.im, sum.re);

    rv[k] = new Signal(sum, freq, amp, phase);
  }

  return rv;
}

PVector drawFourier(float x, float y, float rotation, Signal[] ft) {
  for (int i = 1; i < min(ft.length, 500); i++) {
    float oldx = x;
    float oldy = y;

    float freq = ft[i].freq;
    float radius = ft[i].amp/2;
    float phase = ft[i].phase;
    x += radius * cos(freq * dx + phase + rotation);
    y += radius * sin(freq * dx + phase + rotation);
    stroke(255, 40);
    noFill();
    circle(oldx, oldy, radius*2);

    fill(25, 25, 250);
    circle(x, y, 8);

    stroke(25, 220, 100);
    line(oldx, oldy, x, y);
  }
  return new PVector(x, y);
}

void sort(int index)
{
  if (output.size() == input.size()) {
    println("return 1");
    return;
  }
  Complex nr = input.get(index);
  float x = nr.re;
  float y = nr.im;
  int minIndex = -1;
  float minDistance = img.width *  img.width + img.height * img.height;
  nr.re = -1;
  nr.im = -1;
  for (int j = 0; j < input.size(); j++)
  {
    if (input.get(j).re == -1)
      continue;
    float xDistance = x - input.get(j).re;
    float yDistance = y - input.get(j).im;
    float distance = xDistance * xDistance + yDistance * yDistance;
    if (distance < minDistance)
    {
      minDistance = distance;
      minIndex = j;
    }
  }
  if (minIndex == -1) {
    println("return 2");
    return;
  }
  if (minDistance > 200.0f * scale * scale) {
    println("return 3");
    return;
  }
  minDistance *= 1.5f;
  for (int k = 0; k < input.size(); k++)
  {
    if (input.get(k).re == -1 || k == minIndex)
      continue;
    float xDistance = x - input.get(k).re;
    float yDistance = y - input.get(k).im;
    float distance = xDistance * xDistance + yDistance * yDistance;
    if (distance <= minDistance)
    {
      input.get(k).re = -1;
      input.get(k).im = -1;
    }
  }
  output.add(new Complex(x, y));
  sort(minIndex);
}

void setup() {
  size(800, 800);
  img = loadImage(path);
  scale = 2 * 800 / img.width;
  for (int y = 0; y < img.height; y++)
  {
    for (int x = 0; x < img.width; x++)
    {
      if (img.pixels[x + y * img.width] == color(0, 0, 0))
      {
        input.add(new Complex(x * scale, y * scale));
      }
    }
  }
  sort(0);
  ft = dft(output);
  int size = ft.length;
  for (int i = 0; i < size - 1; i++)
  {
    int swapIndex = i;
    for (int j = i + 1; j < size; j++)
    {
      if (ft[swapIndex].amp < ft[j].amp)
        swapIndex = j;
    }
    if (swapIndex != i)
    {
      Signal temp = ft[i];
      ft[i] = ft[swapIndex];
      ft[swapIndex] = temp;
    }
  }
  println("Circles "+ft.length);
}

boolean stopped = false;
float r = random(255), g = random(255), b = random(255);
void draw() {
  frameRate(30);
  background(0);
  if (stopped) {
    beginShape();
    stroke(220, 200, 220, 150);
    fill(r, g, b, 150);
    for (PVector vertex : wave) {
      vertex(vertex.x, vertex.y);
    }
    endShape();
  } else {
    PVector v = drawFourier(width/2, height/2, 0, ft);
    wave.add(0, v);
    beginShape();
    stroke(220, 200, 220, 150);
    noFill();
    for (PVector vertex : wave) {
      vertex(vertex.x, vertex.y);
    }
    endShape();
    if (dx > TWO_PI) {
      stopped = true;
    }
    float dt = TWO_PI / ft.length;
    dx += dt;
  }
  //saveFrame("####-italy.png");
}
