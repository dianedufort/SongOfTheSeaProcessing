/**
///////////////////////////////////////////////
The MIT License (MIT)

Copyright (c) 2016 Diane Dufort

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

TO DO : each seal sollow the precedent one
////////////////////////////////////////////////

Comments below are in English but the variables and function names are in French 

**/


var nbPas = 50; //when the user clicks, the seals reach the mouse position in a given number of frames

/*******************************************************************************
SEAL CLASS
********************************************************************************/
class Phoque {

	/*****************************
	 @constructor
	 * @classdesc Seal 
	***************************/
	constructor() {

		//SEAL VARIABLES

		//position and motion
		this.position = createVector(Math.round(random(width)), Math.round(random(height)));
		this.acceleration = createVector(0, 0);
		this.vitesse = createVector(0, 0); //motion speed
		this.angle = 0;

		//seals are curious creatures, they chase clicks but stay away from the click or other seals
		this.rMax = Math.round(random(40, 60));
		this.distanceSeparation =  this.rMax;
		this.maxforce = 2; // Maximum steering force
		this.maxspeed = 5; // Maximum speed

		//DRAWING VARIABLES
		//Seals look almost the same with little differences : length of the tail, length of the head, color, ...
		this.color = Math.round(random(255)); //for now, a shade of grey
		this.nbNoeuds = Math.round(random(17, 23)); //nb of "nodes" for the tail
		this.hauteurQueue = Math.round(random(90, 110)); //height of the largest part of the tail
		this.longueurTete = Math.round(random(90, 110)); //distance between an anchor point and its control point 
		//for the bezier curve of the head

		//DRAWING VARIABLES FOR THE TAIL : a tail is made of 2 sine curves
		//the curves are made of vectors, the latter being objects described with (among others) 
		//components (x,y coordinates of the base point), magnitude and direction

		//x distance between 2 base points of vectors
		this.decalageSegmentsX = Math.round(random(9, 10));
		this.longueurQueue = this.nbNoeuds * this.decalageSegmentsX;

		//y distance between the base points of two opposite vertices (i.e. one of each curve) of the tail : 
		this.decalageSegmentsY = Math.round((this.hauteurQueue / 2) / this.nbNoeuds);

		//DRAWING VARIABLES FOR THE SINE CURVES
		// y(t) = amplitude * sin (angularFrequency * t + phase) with angularFrequency = 2 * PI * frequency = 2 * PI / period
		this.amplitude = Math.round(random(1, 5)); //amplitude, the quicker the seal swims, the higher the amplitude.
		this.amplitudeDepart = this.amplitude; //so I need to store the initial amplitude in a variable to set it back to normal 
		//at the end of the seal's motion

		this.periode = Math.round(random(17, 23)); //period  
		this.omega = TWO_PI / this.periode; // omega is the angularFrequency
		this.phase = random(-HALF_PI, HALF_PI);

		//array of vectors, init phase
		this.tabVecteurs = new Array();

		//beginning with the "head" side of the tail so the head of the seal is at the reference point (some sort of gravity point) 
		// within the seal. It is not about the seal's position in the canvas but about the seal's tail position in the seal itself
		// (the seal's position itseft will be managed with translate)
		this.tabVecteurs[this.nbNoeuds - 1] = createVector(0, 0);
		for (var i = this.nbNoeuds - 2; i >= 0; i--)
			this.tabVecteurs[i] = createVector(this.tabVecteurs[i + 1].x - this.decalageSegmentsX, 0);

	}


	/*****************************
	 @function actualiseCoordonneesQueue
	 * @description updates coodinates of the tail. The tail is made of several vectors, updated in every frame in order to follow a sinusoidal curve
	***************************/
	actualiseCoordonneesQueue() { //updates the vectors information

		//calculate new y coordinate of the seal
		var newYTail = Math.round(this.amplitude * sin(frameCount * this.omega + this.phase));

		//so, the position of each vector is based on the following vector in the array but from the precedent iteration
		for (var i = 0; i < this.nbNoeuds - 1; i++) {
			this.tabVecteurs[i].set(this.tabVecteurs[i + 1]); //copies the position, velocity, ...
			this.tabVecteurs[i].x -= this.decalageSegmentsX;
			this.tabVecteurs[i].y += this.decalageSegmentsY;
		}

		//set the last vector, the nearest of the seal's head 
		this.tabVecteurs[this.nbNoeuds - 1].set(0, newYTail - (this.hauteurQueue / 2));


	}

	/*****************************
	 @function dessineCorps
	 * @description draws the body of the seal, this function only takes care of the shape drawing which is independant of 
	the transformations applied to the seal itself
	***************************/
	dessineCorps() {
		this.actualiseCoordonneesQueue();

		var i;
		fill(this.color);
		beginShape(); //body

		//draws the curve of the shape that goes from the head to the tip of the tail
		for (i = this.nbNoeuds - 1; i >= 0; i--) {
			vertex(this.tabVecteurs[i].x, this.tabVecteurs[i].y);

		}

		//draws the curve of the shape that goes from the tip of the tail to the head
		for (i = 0; i < this.nbNoeuds; i++) {
			vertex(this.tabVecteurs[i].x, this.tabVecteurs[i].y + (2 * this.decalageSegmentsY * i));

		}

		//draws the head	
		i = this.nbNoeuds - 1;
		bezierVertex(this.tabVecteurs[i].x + this.longueurTete, this.tabVecteurs[i].y + (2 * this.decalageSegmentsY * i), this.tabVecteurs[i].x + this.longueurTete, this.tabVecteurs[i].y, this.tabVecteurs[i].x, this.tabVecteurs[i].y);

		endShape(CLOSE); //closes the shape

		/*	beginShape() ;//fin 1
				vertex(this.tabVecteurs[i].x, this.tabVecteurs[i].y);	
				bezierVertex(this.tabVecteurs[i].x  + this.longueurTete, this.tabVecteurs[i].y + (2*this.decalageSegmentsY * i), this.tabVecteurs[i].x  + this.longueurTete, this.tabVecteurs[i].y  ,this.tabVecteurs[i].x, this.tabVecteurs[i].y);

			endShape(CLOSE);	*/
		noFill();
	}


	/*****************************
	 @function miseAjourPosition
	 * @description updates the position of the seal 
	  First I evaluate a temporary position for the seal depending on its speed and position
	  Then, I calculate the distance between this potential position and the seal's target 
	  If this distance is important enough, the seal can move. If not, it stays where it is 
	***************************/
	miseAjourPosition() {

		this.vitesse.add(this.acceleration);
		// Limit speed
		this.vitesse.limit(this.maxspeed);
		
		
		var tmp = createVector(0,0);
		tmp.set(this.position);
		tmp.add(this.vitesse);
		
		//gap between potential position and target
		var deltaX = mouseX - tmp.x;
		var deltaY = mouseY - tmp.y;
		//console.log(this.position.x);

		//if the seal is not curious enough to get closer, it stays where it is
		if (deltaX >= -this.rMax && deltaX <= this.rMax) {
			tmp.x = this.position.x;
		}
		if (deltaY >= -this.rMax && deltaY <= this.rMax) {
			tmp.y = this.position.y;
		}
		this.position.set(tmp);
		
	
		
		// Reset accelertion to 0 each cycle
		this.acceleration.mult(0);

	}


	/*****************************
	 @function dessinePhoque
	 * @description draws the seal with its transformations
	***************************/
	dessinePhoque() {
		push();
		translate(this.position.x, this.position.y); //moves the seal as a block
		scale(0.5, 0.5);
		this.angle = this.vitesse.heading();

		rotate(this.angle); //rotation
		this.dessineCorps(); //draws body 
		pop();

	}

	/*****************************
	 @function separe
	 * @description checks for nearby seals
	***************************/
	separe(phoques) {
		
		var deplacement = createVector(0, 0);
		var compteur = 0;
		
		// For every boid in the system, check if it's too close
		for (var i = 0; i < phoques.length; i++) {
			var d = this.position.dist(phoques[i].position);
			
			// If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
		/*	if ((d > 0) && (d < this.distanceSeparation)) {
				// Calculate vector pointing away from neighbor
				var diff = this.position.sub(phoques[i].position).normalize().div(d);
				//diff.normalize();
				//diff.div(d); // Weight by distance
				deplacement.add(diff);
				compteur++; // Keep track of how many
			}*/
		}

		return deplacement;
	}


  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  seek() {
  	
  	var target = createVector(mouseX, mouseY);
    var desired = createVector(0,0);
    desired = target.sub(this.position);  // A vector pointing from the location to the target
    
	// Scale to maximum speed
    desired.normalize();
    desired.mult(this.maxspeed);

    // Steering = Desired minus Velocity
    var steer = createVector(0,0);
    steer = desired.sub(this.vitesse);
    steer.limit(this.maxforce);  // Limit to maximum steering force
    
	return steer;
  }


	/*****************************
	 @function deplacePhoque
	 * @param {Array} phoques - array of seals
	 * @description animates the seal : manages flocking effect, drawing of the body, and border crossing
	***************************/

	deplacePhoque(phoques) {
		this.flock(phoques);
		this.miseAjourPosition();
		// borders();
		this.dessinePhoque();
	}

	/*****************************
	 @function flock
	 * @param {Array} phoques - array of seals
	 * @description animates the seal : manages flocking effect, drawing of the body, and border crossing
	***************************/
	flock(phoques) {
		var sep = this.separe(phoques); // Separation
		var coh = this.seek(); 
		
		// Arbitrarily weight these forces
		coh.mult(1.0);

		// Add the force vectors to acceleration
	//	this.acceleration.add(sep);
		this.acceleration.add(coh);
	}


}

/*******************************************************************************
 * @name Groupe
 * @description Seal group, adapted from Craig Reynolds' and Daniel Shiffman "Flocking" behavior.
 * See: http://www.red3d.com/cwr/
 * Rules: Cohesion, Separation, Alignment
 * (from <a href="http://natureofcode.com">natureofcode.com</a>).
 *********************************************************************************/

class Groupe {

	/*****************************
	 @constructor
	 * @classdesc Group of seals
	 * @param {int} nb - number of seals in the group
	 * @description initialize the seals' array
	***************************/
	constructor(nb) {
		this.nbPhoques = nb;

		this.tabPhoques = new Array(); //to store the seals
		for (var i = 0; i < this.nbPhoques; i++) this.tabPhoques.push(new Phoque());
	}

	/*****************************
	 @function
	 * @description simulate awareness by sending all the seal's information to every single seal
	***************************/
	environnement() {
		for (var i = 0; i < this.nbPhoques; i++) this.tabPhoques[i].deplacePhoque(this.tabPhoques);

	}

}

/********************* MAIN PROGRAM *****************/
var imageFond; //background image
var groupe;

function preload() {
	imageFond = loadImage("assets/images/Fond.png");
}

function setup() {
	//frameRate(30);
	createCanvas(windowWidth, windowHeight);
	groupe = new Groupe(20);
}

function draw() {
	clear();
	image(imageFond, 0, 0, width, height);
	groupe.environnement();
}

/*
function mouseClicked() {
  //for (var i = 0; i < nbPhoques; i++) tabPhoques[i].changeCible(mouseX, mouseY);
}*/