class Phoque {
  
 //position x et y du phoque
  int x, y;

  //position x et y de la cible de la trajectoire
  int cibleX, cibleY;

  // Queue
  PVector[] segmentsQueue;
  int nbSegments;
  int hauteurGrandSegment;
  int decalageSegmentsX;
  int decalageSegmentsY; 
  int amplitude ;//amplitude de la sinusoïdale
  int periode;
  float vX;
  float omega;
  
  public Phoque() {

      nbSegments = 20;
      amplitude = 5;
      hauteurGrandSegment = 150;
      periode = 20;
      vX = 0.2 ; 
      omega = 2*PI/periode;

      decalageSegmentsX = 10;
      decalageSegmentsY = round(hauteurGrandSegment/(nbSegments*2));
       
      x = round(SongOfTheSea.W/2 );
      y = round(SongOfTheSea.H/2);

      // init trails
      segmentsQueue = new PVector[nbSegments];
      for (int i = 0; i < nbSegments; i++) {
        segmentsQueue[i] = new PVector(0, 0);
      }
   
  }
  
  //========================================================================================================
  //                   BLOC AFFICHAGE
  //========================================================================================================  
  
  void affiche(int nbFrame) {
    afficheQueue(nbFrame); 
    afficheTete(); 
  }

  void afficheTete() {
        //(segmentsQueue[nbSegments-1].x   , segmentsQueue[nbSegments-1].y)   (segmentsQueue[nbSegments-1].x   , segmentsQueue[nbSegments-1].y + hauteurGrandSegment )
        line(segmentsQueue[j].x, segmentsQueue[j].y + (decalageSegmentsY * j), segmentsQueue[j+1].x, segmentsQueue[j+1].y + (decalageSegmentsY * (j+1)) );
        
    
  }
  
  void afficheQueue(int nbFrame) {

      y = round(y + (amplitude * sin(nbFrame * omega) ));
      
      // chaque segment de la tête (nbSeg - 1) à la queue est calculé à partir de la position précédente
      // this needs to happen before the trail head is set
      for (int i = 0; i < nbSegments-1; i++ ) {
        segmentsQueue[i].set(segmentsQueue[i+1]);
        segmentsQueue[i].x -= decalageSegmentsX;     
      }
      
      //la tête de la queue, si je puis dire
      segmentsQueue[nbSegments-1].set(x,y);
      
      
     for (int i = nbSegments-2; i >= 0; i-- ) {
        line(segmentsQueue[i].x, segmentsQueue[i].y, segmentsQueue[i+1].x, segmentsQueue[i+1].y );
     }
    
     for (int j = 0; j < nbSegments-1; j++ ) {
        line(segmentsQueue[j].x, segmentsQueue[j].y + (decalageSegmentsY * j), segmentsQueue[j+1].x, segmentsQueue[j+1].y + (decalageSegmentsY * (j+1)) );
     }
     
     
  }   

}