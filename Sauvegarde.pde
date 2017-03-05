 /* 
  //position x et y du phoque
  int x, y;

  //position x et y de la cible de la trajectoire
  int cibleX, cibleY;
 //vitesse de déplacement entre la pos et la cible et nb de pas pour atteindre la cible (c'est
  //avec ça que je calcule la vitesse)
  int vx,vy;
  int nbPas = 30; //30 itérations soit un peu plus d'1 sec pour atteindre la cible
  
  //coeff de direction de déplacement
  int sX, sY;   
  
  //rayon protégé autour de la cible
  int rMax;

  int bougeotte;  //écart entre deux changements de cible;
  int tempsAttente; //temps restant à attendre avant qu'il ne change de cible
  
  //Objet Pgraphics qui contiendra les images de phoques
  PGraphics graph;
  //PImage phoque; //image de base des phoques pour la phase sans animation
  int larg, haut; //dimensions
  int compteur ; //compteur de l'animation
  int sensAnim; //booléen indiquant si l'on est dans une phase croissante ou non
  
  float angle; //angle de rotation
  
  //////////////////////////////////////
  //Constructeur de la classe Phoque
  //Paramètres : aucun
  //Algo : 
   //  calcul aléatoire et affectation des positions et de la cible
   //  affectation des vitesses et sens de déplacement par défaut
   //  choix d'un temps aléatoire entre deux déplacements du phoque
   //  initialisation du temps restant avant le prochain déplacement
   //  choix d'un rayon pour la zone d'arrêt du phoque courant 
   //    histoire d'éviter qu'en rejoingnant un point, les phoques fusionnent
   // Création du PGraphics qui contiendra l'image du phoque
  ///////////////////////////////////////
  public Phoque() {

    //========================================================================================================
    //                   BLOC AFFICHAGE
    //========================================================================================================
    
    //chargement de l'image et initialisation de largeur et hauteur 
    larg = 147;
    haut = 64; 
    compteur = floor(random(SongOfTheSea.animation.length));//un point au hasard de l'animation
    sensAnim = 1;//sens croissant 
    
    //Création du PGraphics
    graph = createGraphics(larg, haut);

    //========================================================================================================
    //                   BLOC DEPLACEMENT
    //========================================================================================================
       
    //calcul de la position x et y au centre de la scène
    //initialisation de la cible à la position du phoque aléatoire pour un déplacement initial
    x = int(random(larg/2,SongOfTheSea.W-larg/2));
    cibleX = int(random(larg/2,SongOfTheSea.W-larg/2));
    y = int(random(haut/2,SongOfTheSea.H-haut/2));
    cibleY = int(random(haut/2,SongOfTheSea.H-haut/2)); 
  
    //vitesse et sens de déplacement
    vx = vy = 5;
    sX = sY = 1;
   
   bougeotte = round(random(3,12)) ;//un nombre de secondes compris entre 3 et 12
   tempsAttente = bougeotte;
   
   //rayon de la zone d'arrêt choisi aléatoirement
   rMax = 50; //round(random(10 , 40));
   
   //angle de rotation 
   angle = 0;
   
  }
  
  //========================================================================================================
  //                   BLOC AFFICHAGE
  //========================================================================================================
  
  //////////////////////////////////////
  //Fonction : affiche
  //Paramètres : aucun
  //Algo : dessine l'image. Le rendu du PGraphics est dans l'autre fonction. Celle ci se charge d'appeler 
  //la fonction de rendu au bon endroit et après avoir changé de trajectoire si besoin.
  //la rotation se calcule selon les modalités classiques. Soit un triangle rectagle formé par la cible, la position de l'objet et la projection, sur l'axe des absisses, 
  //de sa position. On garde deltaX comme étant le côté adjacent, deltaY étant le côté opposé. On en déduit que la tangente de l'angle est opp/adj. Du coup, l'angle est atan2(opp, adj).
  ///////////////////////////////////////
  public void affiche() {  
    
    changeTrajectoire() ;
    anime();
    
    pushMatrix();
      translate(x,y);
      
      //calcul de l'angle de rotation 
      angle = atan2(y-cibleY, x-cibleX);
      rotate(angle);//rotation
      
      dessineImage();
      image(graph, 0, 0); 
    popMatrix();
  }
  
  //////////////////////////////////////
  //Fonction : dessineImage
  //Paramètres : aucun
  //Algo : rendu du PGraphics
  ///////////////////////////////////////
  public void dessineImage() {        
       
     graph.beginDraw();
     // graph.imageMode(CENTER); 
      //graph.background(100);//temporaire : juste une couleur
      graph.clear();
      graph.image(SongOfTheSea.animation[compteur], 0,0);//le compteur est otujours correct
    //  graph.ellipse(0,haut/2,5,5);
     graph.endDraw();
   
  }
  
  //////////////////////////////////////
  //Fonction : anime
  //Paramètres : aucun
  //Algo : gère le compteur de l'anims
  ///////////////////////////////////////
  public void anime() {  
    int tmp = compteur + sensAnim; //donc compteur++ ou compteur-- selon le sens
    if(tmp >= 0 && tmp < SongOfTheSea.animation.length) {//le compteur est bon
      compteur = tmp;
      
    }
    else {// le compteur n'est pas bon, 
      if(tmp <0) {//on est descendu trop bas
         compteur = 1;
         sensAnim = 1; 
      }
      else {//on est allé trop haut
        compteur = SongOfTheSea.animation.length - 2;
        sensAnim = -1;
      }
      
    }
  }
  //========================================================================================================
  //                   BLOC DEPLACEMENT
  //========================================================================================================
  
  ////////////////////////////////////
  //Fonction : changeCible
  //Paramètres : ncx : nouvelle coordonnée x de la cible
  //             ncy : nouvelle coordonnée y de la cible 
  //Algo : simple affectation et calcul de la nouvelle vitesse. 
  //J'ai changé d'algo : avant, je faisais en sorte de mettre vmax dans la vitesse correspondant à l'écart le plus important 
  //mais c'est plus joli et rapide de déterminer un nombre de pas à l'avance 
  //et de calculer les deux vitesses en divisant la distance à parcourir par le nb de pas avec lequel on parcourt cette distance
  // le plus esthétique est que : plus la distance à parcourir est grande, plus l'objet sera rapide
  //le plus optimisation est qu'on a pas besoin de tests et de calculs intermédiaires
 ///////////////////////////////////// 
 private void changeCible (int ncx, int ncy) {
    cibleX = ncx;
    cibleY = ncy; 
    
   //écart en valeur absolue
   int deltaX = abs(cibleX - x);
   int deltaY = abs(cibleY - y);
   
   vx = round(deltaX/nbPas);
   vy = round(deltaY/nbPas);
      

 }
 
  ////////////////////////////////////
  //Fonction : nouveauTemps
  //Paramètres : aucun
  //Algo : une nouvelle seconde s'est écoulée
  // On modifie le temps d'attente
  // On teste si l'attente est écoulée
  //    Si OUI => on change de cible, on remets le compteur à sa valeur initiale
  //    Si NON => rien
  //s'il y a assez d'écart, on peut se déplacer donc x ou y prend la valeur tempporaire
  //sinon, on reste où on est
 /////////////////////////////////////  
 public void nouveauTemps() {
   
   //println("Appel nouveauTemps" + tempsAttente);
   if(--tempsAttente == 0) {
     println("Un selkie change de pos");
     //le temps d'attente est écoulé, on change de cible
     changeCible (int(random(larg/2,SongOfTheSea.W-larg/2)),int(random(haut/2,SongOfTheSea.H-haut/2))); 
     
     //on remets le compteur à sa valeur initiale
     tempsAttente =  bougeotte ;
   }
 }
 
  ////////////////////////////////////
  //Fonction : changeTrajectoire
  //Paramètres : aucun
  //Algo : modification de la position x,y en rapport avec la cible
  // En gros, on commence par calculer une pos temporaire pour x et y en fonction de la vitesse de déplacement
  // puis le delta : en gros, quel est l'écart entre cette pos temporaire et la cible
  //s'il y a assez d'écart, on peut se déplacer donc x ou y prend la valeur tempporaire
  //sinon, on reste où on est
 /////////////////////////////////////  
 private void changeTrajectoire() {
   
   int tmpX = x + vx*sX;
   int tmpY = y + vy*sY;

   //écart entre la pos temporaire (éventuel déplacement et la cible)
   int deltaX = cibleX - tmpX;
   int deltaY = cibleY - tmpY;
   
   //si on dépasse la zone d'arrêt de 30 px autoour du point d'arrivée, on arrête
   if(deltaX >= -rMax && deltaX <= rMax)  tmpX = x;
   if(deltaY >= -rMax && deltaY <= rMax)  tmpY = y;  
   
   //réaffectation des nouvelles coord : on s'est déplacé ou pas selon si 
   //l'écart était suffisamment important pour accepter ce déplacement.
   x = tmpX; 
   y = tmpY; 
   
   //calcul du nouveau sens de déplacement
   sX = sY = 1; 
   if(x > cibleX) sX = -1;
   if(y  > cibleY) sY = -1;
   
 }*/
