static int W = 960; 
static int H = 593;
PImage fond; 

//int nbSelkies = 1;
//Phoque[] selkies = new Phoque[nbSelkies];

Phoque test;

void setup() {
 
  size(960,593);
  frameRate(24);
  
  fond = loadImage("data/images/Fond.png");
  background(fond);  
  
 /* for(int i=0; i <nbSelkies ; i++ ){
    selkies[i] = new Phoque();
  }*/
  
  test = new Phoque();
  test.affiche(1);
}

void draw() {
 clear();
 
 /*//sans action de ma part, les phoques choisissent toutes les X secondes (diff pour chacun), une nouvelle pos
 //println(frameCount + " frames et le frameRate est : " + frameRate);
 if(frameCount%floor(frameRate) == 0) {//une seconde s'est écoulée
     //println("Une seconde s'est écoulée");
    for(int i=0; i <nbSelkies ; i++ ){
      selkies[i].nouveauTemps();
    }
 }
 */
 background(fond); 
 test.affiche(frameCount);
  
  
/* for(int i=0; i <nbSelkies ; i++ ){
   selkies[i].affiche();
 }*/
    
}