/* @pjs preload="assets/livemap2.png"; */

// @todo restructure this to use Processing JS's class inheritance (which is a bit quirky ...)
// constants
LIVE_MODE = 1; // kiva/live mode -- arcs are drawn and then erased
FREEZE_MODE = 2; // thank-you/receipt mode -- arcs are drawn and not erased

DRAWING = 1;
ERASING = 2;
NEW = 3;
OLD = 4;
FADING = 5;
FROZEN = 6;

// loan path types
LINE = 1;
ARC = 2;

FRAMERATE = 24;

LOAN_STROKEWEIGHT = 2;
LENDER_STROKEWEIGHT = 2;
BORROWER_STROKEWEIGHT = 2;

// Global variables
Loans ls;
Lenders lndrs;
Borrowers brwrs;
NewLoans newloans;
PImage bg;  
//Wwidth = 654;
//Wheight = 354;
Wwidth = abs_width;
Wheight = abs_height;

pixels_per_degree = Wwidth / 360;
if (longitude_center == null) { longitude_center = -122.4183333; }  // set to SF/Kiva HQ if missing
longitude_shift = -1 * (360 + longitude_center) * pixels_per_degree;

map_mode = draw_mode; // set in .js file, corresponds to LIVE_MODE or FREEZE_MODE
Pfont font;
total_loans = 0;
frozen_loans = 0;

// how loan lines are drawn -- LINE or ARC
pathmode = ARC;

// Setup the Processing Canvas
void setup(){
  size( Wwidth, Wheight );

  ls = new Loans();
  lndrs = new Lenders();
  brwrs = new Borrowers();
  newloans = new NewLoans();
  //cities = new Cities();

  frameRate( FRAMERATE );
  X = width / 2;
  Y = width / 2;
  nX = X;
  nY = Y;  
  bg = loadImage("assets/" + bg_map);

  xorig = 10;
  yorig = 10;
  xx = 10;
  yy = 10;
  //font = loadFont("Monaco-48.vlw");
  font = loadFont("Arial");

//if ( kv.proc_loaded ) {
//	kv.proc_loaded();
//}

}


void add_loans_purchased( activity, useLines ) {

    if (useLines){
        pathmode = LINE;
    }

	lender_lat = activity.lender.lat;
	lender_lon = activity.lender.lon;
	lender_name = activity.lender.name;
	if (lender_name == null) { lender_name = "Anonymous"; }
	
	Coords lender_c = latlngToXY(float(lender_lat), float(lender_lon));
	lx = (int) lender_c.x;
	ly = (int) lender_c.y;

	// quit if x or y <= 0 -- this means we got a null/bad geocode
	if (lx <= 0 || ly <= 0) { return; }

	lcolor = new kColor();
	lcolor.r = activity.color.r;
	lcolor.g = activity.color.g;
	lcolor.b = activity.color.b;

	lender_lifespan = 0;

	num_loans = activity.loans.length;

	birth_delay = 0;

	// iterate over each loan made by this lender
	for(int i = 0; i < num_loans; i++) {

		// stagger the loan births if there are more than 5 borrowers
		if (num_loans > 5) {
			birth_delay = birth_delay + 3;
		}

		borrower_lat = activity.loans[i].location.lat;
		borrower_lon = activity.loans[i].location.lon;
		borrower_name = activity.loans[i].name;
		status = activity.loans[i].status;

		Coords borrower_c = latlngToXY(float(borrower_lat), float(borrower_lon));
		bx = (int) borrower_c.x;
		by = (int) borrower_c.y;

		// quit if x or y <= 0 -- this means we got a null/bad geocode
		if (bx <= 0 || by <= 0) { return; }

		l_new = new Loan(lx, ly, bx, by, lcolor, birth_delay);
		ls.addLoan(l_new);
		lifespan = l_new.steps * 2 * 0.95;
		if (lifespan < 60) { lifespan = 60; }

		if (lifespan > lender_lifespan) {
			// make sure lender object lives until last loan is received by borrower
			lender_lifespan = lifespan;
		}

		brwr = new Borrower(bx, by, borrower_name, lcolor, lifespan, status, birth_delay);
		brwrs.addBorrower(brwr);
		total_loans++;
	}


	lndr = new Lender(lx, ly, lender_name, lcolor, lender_lifespan + birth_delay);
	lndrs.addLender(lndr);

}


void add_loan_purchased( lender_name,  lender_lat,  lender_lon,  borrower_name,  borrower_lat,  borrower_lon, status, cR, cG, cB, useLines) {
    if (useLines){
        pathmode = LINE;
    }
	Coords lender_c = latlngToXY(float(lender_lat), float(lender_lon));
	Coords borrower_c = latlngToXY(float(borrower_lat), float(borrower_lon));

	lx = (int) lender_c.x;
	ly = (int) lender_c.y;
	bx = (int) borrower_c.x;
	by = (int) borrower_c.y;

	lcolor = new kColor();
	lcolor.r = cR;
	lcolor.g = cG;
	lcolor.b = cB;

	if (lx != 0 && ly != 0 && bx != 0 && by != 0) {

		if (lx < 0) { lx = 0; }
		if (bx < 0) { bx = 0; }
		if (ly < 0) { ly = 0; }
		if (by < 0) { by = 0; }

		l_new = new Loan(lx, ly, bx, by, lcolor);
		ls.addLoan(l_new);
		lifespan = l_new.steps * 2 * 0.95;
		if (lifespan < 100) { lifespan = 100; }

		lndr = new Lender(lx, ly, lender_name, lcolor, lifespan);
		lndrs.addLender(lndr);

		brwr = new Borrower(bx, by, borrower_name, lcolor, lifespan, status);
		brwrs.addBorrower(brwr);
	}
}

void loan_registered(loan_name, loan_lat, loan_lon, cR, cG, cB){
	Coords loan_c = latlngToXY(float(loan_lat), float(loan_lon));
	lx = (int) loan_c.x;
	ly = (int) loan_c.y;

	loan_name = "NEW Loan\n" + loan_name;

	lcolor = new kColor();
	lcolor.r = cR;
	lcolor.g = cG;
	lcolor.b = cB;

	lifespan = 100;

	if (lx < 0) { lx = 0; }
	if (ly < 0) { ly = 0; }

	nloan = new NewLoan(lx, ly, loan_name, lcolor, lifespan, 10 * (newloans.size() - 1));
	newloans.addNewLoan(nloan);

}



void lender_registered(lender_name, lender_lat, lender_lon, cR, cG, cB){
	Coords lender_c = latlngToXY(float(lender_lat), float(lender_lon));
	lx = (int) lender_c.x;
	ly = (int) lender_c.y;

	lender_name = "NEW LENDER\n" + lender_name;

	lcolor = new kColor();
	lcolor.r = cR;
	lcolor.g = cG;
	lcolor.b = cB;

	lifespan = 100;
	lndr = new Lender(lx, ly, lender_name, lcolor, lifespan);
	lndrs.addLender(lndr);

}


void lender_joined_team(lender_name, lender_lat, lender_lon, team_name, cR, cG, cB){

	Coords lender_c = latlngToXY(float(lender_lat), float(lender_lon));
	lx = (int) lender_c.x;
	ly = (int) lender_c.y;

	lender_name = lender_name + " joined " + team_name.substring(0,20);

	lcolor = new kColor();
	lcolor.r = cR;
	lcolor.g = cG;
	lcolor.b = cB;

	lifespan = 100;
	lndr = new Lender(lx, ly, lender_name, lcolor, lifespan);
	lndrs.addLender(lndr);

}

// Main draw loop
void draw(){

	background(255);
	// shift tiled background map to correct loc
	image(bg, longitude_shift, 0);

	ls.run();
	lndrs.run();
	brwrs.run();
	newloans.run();
	//cities.run();
	if (map_mode == FREEZE_MODE && frozen_loans > 0 && frozen_loans >= total_loans) { 
		//println("stopping");
		noLoop(); // stop the animation, leaving the frozen loan arcs on the map
	}
}


class Lender
{
	int x, y, lifespan, mode, anim_counter, fade_counter, text_xoffset, text_yoffset;
	kColor mycolor;
	String lname, text_valign, text_halign;

	Lender(int xpos, int ypos, String name, kColor lcolor, float steps)
	{
		x = xpos;
		y = ypos;
		lname = formatText(name);
		mycolor = lcolor;
		mode = NEW;
		anim_counter = 0;
		lifespan = (int) steps;

		// randomly place text around 4 corners of lender dot
		// pseudo-random # based on fixed attribs of the loan
		// (to make sure name is always assigned to the same place)
		text_pos = (name.length() + int(steps)) % 4;

		switch(text_pos + 1) {
		  case 1:
			text_valign = BOTTOM;
			text_halign = RIGHT;
			text_xoffset = -3;
			text_yoffset = -3;
			break;
		  case 2:
			text_valign = BOTTOM;
			text_halign = LEFT;
			text_xoffset = 3;
			text_yoffset = -3;
			break;
		  case 3:
			text_valign = TOP;
			text_halign = LEFT;
			text_xoffset = 3;
			text_yoffset = 3;
			break;
		  case 4:
			text_valign = TOP;
			text_halign = RIGHT;
			text_xoffset = -3;
			text_yoffset = 3;
			break;
		}

	}

	void run() {
    	update();
    	render();
  }

  	void update() {
  		if (mode == NEW) {
 	 		anim_counter++;
 	 		if (anim_counter > 13) {
 	 			mode = OLD;
 	 		}
  		}
  		else if (mode == OLD) {
  			anim_counter--;
  			if (anim_counter < 6) {
  				fade_counter = lifespan;
				if (draw_mode == LIVE_MODE) {
  					mode = FADING;
				}
				else { // draw_mode == FREEZE_MODE
	  				mode = FROZEN;
				}
  			}
  		}
  		else if (mode == FADING) {
  			fade_counter--;
  			if (fade_counter < 12) {
  				anim_counter = fade_counter;
  			}
  		}
  	}

  	void render() {
  		stroke (mycolor.r, mycolor.g, mycolor.b);
  		strokeWeight(LENDER_STROKEWEIGHT);
  		arc (x, y, anim_counter, anim_counter, 0, TWO_PI);

		textsize = 12;
		if (mode == NEW) {
			textsize = anim_counter;
		}
		else if (mode == FADING) {
			textsize = max(1,min(12, fade_counter));
		}

  		textFont(font, textsize);

  		textAlign(text_halign, text_valign);
  		fill(mycolor.r, mycolor.g, mycolor.b);
		text(lname, x + text_xoffset, y + text_yoffset);
		noFill();
  	}

  	void dead() {
  		return (fade_counter < 0);
  	}
}

class Borrower
{
	int x, y, lifespan, mode, anim_counter, fade_counter, text_xoffset, text_yoffset, birth_delay;
	kColor mycolor;
	String bname, bstatus, text_valign, text_halign;

	Borrower(int xpos, int ypos, String name, kColor lcolor, float steps, status, delay)
	{
		x = xpos;
		y = ypos;
		bname = formatText(name);
		bstatus = status;
		mycolor = lcolor;
		mode = NEW;
		anim_counter = 0;
		lifespan = (int) steps;
		birth_delay = delay;

		//if (bstatus == "raised") { bname = "FULLY FUNDED\n" + name; }

		// randomly place text around 4 corners of lender dot
		// pseudo-random # based on fixed attribs of the loan
		// (to make sure name is always assigned to the same place)
		text_pos = (name.length() + int(steps)) % 4;

		switch(text_pos + 1) {
		  case 1:
			text_valign = BOTTOM;
			text_halign = RIGHT;
			text_xoffset = -3;
			text_yoffset = -3;
			break;
		  case 2:
			text_valign = BOTTOM;
			text_halign = LEFT;
			text_xoffset = 3;
			text_yoffset = -3;
			break;
		  case 3:
			text_valign = TOP;
			text_halign = LEFT;
			text_xoffset = 3;
			text_yoffset = 3;
			break;
		  case 4:
			text_valign = TOP;
			text_halign = RIGHT;
			text_xoffset = -3;
			text_yoffset = 3;
			break;
		}

	}

	void run() {
    	update();
    	if (birth_delay <= 0) {
    		render();
    	}
  }

  	void update() {
  		if (birth_delay > 0) { birth_delay--; }

  		else if (mode == NEW) {
 	 		anim_counter++;
 	 		if (anim_counter > 12) {
 	 			mode = OLD;
 	 		}
  		}
  		else if (mode == OLD) {
  			anim_counter--;
  			if (anim_counter < 6) {
  				fade_counter = lifespan;
				if (draw_mode == LIVE_MODE) {
	  				mode = FADING;
				}
				else { // draw_mode == FREEZE_MODE
	  				mode = FROZEN;
				}
  			}
  		}
  		else if (mode == FADING) {
  			fade_counter--;
  			if (fade_counter < 13) {
  				anim_counter = fade_counter;
  			}
  		}
  	}

  	void render() {
  		stroke (mycolor.r, mycolor.g, mycolor.b);
  		strokeWeight(BORROWER_STROKEWEIGHT);
  		if (bstatus == "raised") {
  			fill(mycolor.r, mycolor.g, mycolor.b);
  		}
  		rect(x - anim_counter/2, y - anim_counter/2, anim_counter, anim_counter);


		textsize = 12;
		if (mode == NEW) {
			textsize = anim_counter;
		}
		else if (mode == FADING) {
			textsize = max(1,min(12, fade_counter));
		}

  		textFont(font, textsize);
  		textAlign(text_halign, text_valign);
  		fill(mycolor.r, mycolor.g, mycolor.b);
		text(bname, x + text_xoffset, y + text_yoffset);
		noFill();
  	}

  	void dead() {
  		return (fade_counter < 0);
  	}
}


class NewLoan
{
	int x, y, lifespan, mode, anim_counter, fade_counter, text_xoffset, text_yoffset, birth_delay;
	kColor mycolor;
	String bname, bstatus, text_valign, text_halign;

	NewLoan(int xpos, int ypos, String name, kColor lcolor, float steps, delay)
	{
		x = xpos;
		y = ypos;
		bname = formatText(name);
		bstatus = status;
		mycolor = lcolor;
		mode = NEW;
		anim_counter = 0;
		lifespan = (int) steps;
		birth_delay = delay;

		// randomly place text around 4 corners of lender dot
		// pseudo-random # based on fixed attribs of the loan
		// (to make sure name is always assigned to the same place)
		text_pos = (name.length() + int(steps)) % 4;

		switch(text_pos + 1) {
		  case 1:
			text_valign = BOTTOM;
			text_halign = RIGHT;
			text_xoffset = -3;
			text_yoffset = -3;
			break;
		  case 2:
			text_valign = BOTTOM;
			text_halign = LEFT;
			text_xoffset = 3;
			text_yoffset = -3;
			break;
		  case 3:
			text_valign = TOP;
			text_halign = LEFT;
			text_xoffset = 3;
			text_yoffset = 3;
			break;
		  case 4:
			text_valign = TOP;
			text_halign = RIGHT;
			text_xoffset = -3;
			text_yoffset = 3;
			break;
		}

	}

	void run() {
    	update();
    	if (birth_delay <= 0) {
    		render();
    	}
  }

  	void update() {
  		if (birth_delay > 0) { birth_delay--; }

  		else if (mode == NEW) {
 	 		anim_counter++;
 	 		if (anim_counter > 12) {
 	 			mode = OLD;
 	 		}
  		}
  		else if (mode == OLD) {
  			anim_counter--;
  			if (anim_counter < 6) {
  				fade_counter = lifespan;
  				mode = FADING;
  			}
  		}
  		else if (mode == FADING) {
  			fade_counter--;
  			if (fade_counter < 13) {
  				anim_counter = fade_counter;
  			}
  		}
  	}

  	void render() {
  		stroke (mycolor.r, mycolor.g, mycolor.b);
  		strokeWeight(BORROWER_STROKEWEIGHT);
  		rect(x - anim_counter/2, y - anim_counter/2, anim_counter, anim_counter);


		textsize = 12;
		if (mode == NEW) {
			textsize = anim_counter;
		}
		else if (mode == FADING) {
			textsize = max(1,min(12, fade_counter));
		}

  		textFont(font, textsize);
  		textAlign(text_halign, text_valign);
  		fill(mycolor.r, mycolor.g, mycolor.b);
		text(bname, x + text_xoffset, y + text_yoffset);
		noFill();
  	}

  	void dead() {
  		return (fade_counter < 0);
  	}
}


class Loan 
{
  int x1, y1, x2, y2, xbegin, xend, ybegin, yend, xv, yv, birth_delay;
  int timer;
  int delta;
  int steps;
  int rcolor;
  int gcolor;
  int bcolor;
  float distance;
  color sectorcolor;
  int mode = DRAWING;
  float[] xi;
  float[] yi;

  Loan(int xorig, int yorig, int xdest, int ydest, kColor lcolor, delay)
  {
    xbegin = xorig;
    xend = xdest;
    ybegin = yorig;
    yend = ydest;

    x1 = xorig;
    y1 = yorig;
    x2 = xdest;
    y2 = ydest;
    rcolor = lcolor.r;
    gcolor = lcolor.g;
    bcolor = lcolor.b;

    int xdist = x1 - x2;
    int ydist = y2 - y1;
    distance = sqrt(xdist * xdist + ydist * ydist);
    birth_delay = delay;

    // how fast the loan moves -- higher divisors = faster
    steps = (int) round(distance / 6);

    // if distance between lender & borrower is too short, make sure it doesn't disappear too fast
    if (steps < 30) { steps = 30; }
    timer = steps;
    
    xv = (x2 - x1)/steps;
    yv = (y2 - y1)/steps;

	// pre-build bezier vertices
	xi = new float[0];
	yi = new float[0];

	midx = (xend - xbegin)/ 2 + xbegin;
	midy = (yend - ybegin)/ 2 + ybegin;

	random_seed = 0;
	if (map_mode == FREEZE_MODE) { // we're only showing each loan once, so let's randomize them a bit (better spread/aesthetics)
		random_seed = int(random(10));
	}

	unique_seed = rcolor + random_seed + xdest + ydest;

	// bezier curve is built using a point that's offset from the midpoint of a straight line between lender & borrower.
	// the offset is perpendicular to the line at the midpoint, and randomized in direction and distance 
	angle = atan2(y2 - y1,x2 - x1); // angle from lender to borrower in radians
	angle_degrees = angle * 180 / PI; // angle in degrees

	// pseudo-deterministic-randomness to put the bezier control point on one side of the line or the other
	if ( unique_seed / 2 == int(unique_seed / 2) ) { direction = 1; }
	else { direction = -1; }

	angle_offset = angle_degrees + (90 + (unique_seed % 80) - 40) * direction;  // 90 would be right-angle perpendicular; give it a spread
	
	bezier_offset = distance/3 % (xend/2 + rcolor/2 + random_seed) ; // how far away is anchor point

	bezier_x = round(midx + bezier_offset * cos(radians(angle_offset)));
	bezier_y = round(midy + bezier_offset * sin(radians(angle_offset)));

	// make sure loan path doesn't go outside map boundary
	if (bezier_x < 0) { bezier_x = 0; }
	if (bezier_y < 0) { bezier_y = 0; }
	if (bezier_x > Wwidth) { bezier_x = Wwidth; }
	if (bezier_y > Wheight) { bezier_y = Wheight; }

	//bezier(xbegin, ybegin, bezier_x, bezier_y, bezier_x, bezier_y, xend, yend);

	xi[0] = xbegin;
	yi[0] = ybegin;
	ssteps = round(steps);

	for (int i = 1; i <= ssteps; i++) {

		float t = float(i) / float(steps);
		xi[i] = bezierPoint(xbegin, bezier_x, bezier_x, xend, t);
		yi[i] = bezierPoint(ybegin, bezier_y, bezier_y, yend, t);
	}
	xi[ssteps] = xend;
	yi[ssteps] = yend;

  }

  void run() {
    update();
    if (birth_delay <= 0) {
    	render();
    }
  }

  // Method to update location  
  void update() {

  if (birth_delay > 0) {
  		birth_delay--;
  }
  else if (mode == DRAWING) {
		//x2 += xv;
		//y2 += yv;
		x2 = x1 + xv * (steps - timer);
		y2 = y1 + yv * (steps - timer);
		timer--;
		if(timer < 0 && mode == DRAWING) {
			//timer = steps;
			timer = 0;
			if (draw_mode == LIVE_MODE) {
				mode = ERASING;
			}
			else { // draw_mode == FREEZE_MODE
				mode = FROZEN;
				frozen_loans++;
			}
		}
    }
    else if (mode == ERASING) { 
    	//x1 += xv;
		//y1 += yv;
		y2 = yend;
		x2 = xend;
		x1 = x2 - xv * (steps - timer);
		y1 = y2 - yv * (steps - timer);
		timer++;
	}
  } 

  // Method to display  
  void render() {  
	strokeWeight( LOAN_STROKEWEIGHT );
    stroke( rcolor, gcolor, bcolor );



    if (pathmode == LINE) {
    	line(x1, y1, x2, y2);
   	}
	else { // pathmode == ARC

		beginShape();
		if (mode == ERASING) {
			for (kk = yi.length; kk >= (timer); kk--) {
				curveVertex(xi[kk], yi[kk]);
			}
			//curveVertex(xi[xi.length], yi[yi.length]);
		}
		else {
			curveVertex(xi[0], yi[0]); // weird, but necessary to make sure curve begins at lender origin
			
			for (kk = 0; kk <= (steps - timer); kk++) {
				curveVertex(xi[kk], yi[kk]);
			}

			if (kk == xi.length) { curveVertex(xi[xi.length-1], yi[yi.length-1]); } // last segment of curve to borrower
		}
		endShape();


	}

  }

  void dead() {
	if (timer > steps && mode == ERASING) {
      return true;
    } else {
      return false;
    }
  }
}


class Loans
{
ArrayList loans;

  Loans() {
    loans = new ArrayList();              // Initialize the arraylist
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = loans.size()-1; i >= 0; i--) {
      Loan l = (Loan) loans.get(i);
      l.run();
      if (l.dead()) {
        loans.remove(i);
      }
    }
  }

  void addLoan(Loan l) {
    loans.add(l);
  }

  // A method to test if the loans system still has loans
  boolean dead() {
    if (loans.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

}

class Lenders
{
ArrayList lenders;

  Lenders() {
    lenders = new ArrayList();              // Initialize the arraylist
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = lenders.size()-1; i >= 0; i--) {
      Lender l = (Lender) lenders.get(i);
      l.run();
      if (l.dead()) {
        lenders.remove(i);
        //println("lender gone.");
      }
    }
  }

  void addLender(Lender l) {
    lenders.add(l);
  }

  // A method to test if the lenders system still has lenders
  boolean dead() {
    if (lenders.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

}

class Borrowers
{
ArrayList borrowers;

  Borrowers() {
    borrowers = new ArrayList();              // Initialize the arraylist
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = borrowers.size()-1; i >= 0; i--) {
      Borrower b = (Borrower) borrowers.get(i);
      b.run();
      if (b.dead()) {
        borrowers.remove(i);
        //println("borrower gone.");
      }
    }
  }

  void addBorrower(Borrower b) {
    borrowers.add(b);
  }

  // A method to test if the borrowers system still has borrowers
  boolean dead() {
    if (borrowers.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }
}

class City
{
	int x, y, lat, lng;
	String name;

	City(String name1, float lat1, float lng1)
	{
		name = name1;
		lat = lat1;
		lng = lng1;
		Coords c = latlngToXY(lat, lng);
		x = c.x;
		y = c.y;

	}

	void run() {
    	//update();
    	render();
  }

  	void update() {
  		if (mode == NEW) {
 	 		anim_counter++;
 	 		if (anim_counter > 13) {
 	 			mode = OLD;
 	 		}
  		}
  		else {
  			anim_counter--;
  			if (anim_counter < 4) {
  				anim_counter = 4;
  			}
  		}
  	}

  	void render() {
  		stroke (230, 230, 230, 50);
  		textFont(font, 12);
  		textAlign(CENTER);
  		//textSize(2);
		text(name, x, y - 7);
		ellipse(x,y,2,2);
  	}

  	void dead() {
  		return false;
  	}
}

class NewLoans
{
ArrayList nloans;

  NewLoans() {
    nloans = new ArrayList();              // Initialize the arraylist
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = nloans.size()-1; i >= 0; i--) {
      NewLoan b = (NewLoan) nloans.get(i);
      b.run();
      if (b.dead()) {
        nloans.remove(i);
        //println("new loan  gone.");
      }
    }
  }

  void addNewLoan(NewLoan b) {
    nloans.add(b);
  }

  // A method to test if the new loanws system still has borrowers
  boolean dead() {
    if (nloans.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

  int size() {
      return nloans.size();
  }
}

class Cities
{
ArrayList cities;

  Cities() {
    cities = new ArrayList();              // Initialize the arraylist
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = cities.size()-1; i >= 0; i--) {
      City c = (City) cities.get(i);
      c.run();
      if (c.dead()) {
        cities.remove(i);
        //println("city gone.");
      }
    }
  }

  void addCity(City c) {
    cities.add(c);
  }

  // A method to test if the cities system still has cities
  boolean dead() {
    if (cities.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

}

class Coords {
 int x;
 int y;

 Coords(int xm, int ym) {
    x = xm;
    y = ym;
 }
}

 Coords latlngToXY(float lat, float lng) {
	// Mercator projection
	// longitude shift = # pixels map is moved to the left

	// compensate for map-cropping vertical asymmetry
	map_y_adjust = Wheight / 7.08;

	// longitude: just scale and shift

	x = (Wwidth * (180 + lng) / 360.0) % Wwidth + longitude_shift;

	// there's a better way to do this, but this works for now
	if (x < 0) { x = x + Wwidth; }
	if (x < 0) { x = x + Wwidth; }

	lat = lat * PI / 180.0;
	// convert from degrees to radians
	y = log(tan((lat/2.0) + (PI/4.0)));

	y = (Wheight / 2.0) - (Wwidth * y / (2.0 * PI));

	x = round(x);
	y = round(y + map_y_adjust);
	coords = new Coords(x,y);
	return coords;
	}

class kColor {
  int r;
  int g;
  int b;

  kColor(int red, int green, int blue) {
  	r = red;
  	g = green;
  	b = blue;
  }
}

String formatText(String txt) {
// break apart txt & add \n's appropriately

	int max_line_len = 13;
	int curr_line_len = 0;
	String return_txt = "";

	String[] words = splitTokens(txt, " -");

	// if txt == empty string, return an empty string
	if (words == undefined) {
		return "";
	}

	for (i = 0; i <= (words.length() - 1); i++) {
		return_txt = return_txt + words[i];
		curr_line_len += words[i].length();

		// add a space or \n ?
		if (i < (words.length() - 1)) {
			if ((curr_line_len + words[i].length + 1) >= max_line_len) {
				return_txt += "\n";
				curr_line_len = 0;
			}
			else {
				return_txt += " ";
				curr_line_len++;
			}
		}
	}
	return return_txt;
}
