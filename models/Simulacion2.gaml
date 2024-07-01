/**
* Name: Simulacion2
* Based on the internal skeleton template. 
* Author: Reymon
* Tags: 
*/
model Simulacion2

global {
/** Insert the global definitions, variables and actions here */
	file shapefile_roads <- file("../includes/roads.shp");
	file shapefile_points <- file("../includes/points.shp");
	csv_file posicion_entradas <- csv_file("../includes/Entradas.csv", true);
	geometry shape <- envelope(shapefile_roads);
	graph road_network;
	list<point> entradas;
	map<road, float> current_weights;

	//Probabilidades
	init {
		create road from: shapefile_roads;
		road_network <- as_edge_graph(road);
		// Create another road in the opposite direction

		//create point from:shapefile_points;
		//at the begining of the simulation, we add to the people agent the desire to go to their target.
		create people number: 100 {
			location <- any_location_in(one_of(road));
			do add_desire(at_target);
			// we give the agent a random charisma and receptivity (built-in variables linked to the emotions)
			charisma <- rnd(1.0);
			receptivity <- rnd(1.0);
			road_network <- as_edge_graph(road);
		}

		
		//current_weights <- road as_map (each::each.shape.perimeter);
		
		create entrada from: posicion_entradas with: [lat::float(get("latitude")), lon::float(get("longitude"))] {
			location <- to_GAMA_CRS({lon, lat}, "EPSG:4326").location;
			add location to: entradas;
			write entradas;
		}

	}

}

species people skills: [moving] control: simple_bdi {
	bool carnet <- true;
	bool noCarnet <- true;
	point target;
	bool noTarget <- true;
	//we set this built-in variable to true to use the emotional process
	bool use_emotions_architecture <- true;
	//EL AGENTE TIENE UN OBJETIVO (ENTRADA)
	predicate at_target <- new_predicate("at_target");
	predicate has_target <- new_predicate("has target");

	aspect base {
		draw file("../includes/person_walking.png") size: 0.0001;
		//draw circle(20) color:#red;
	}

}

species road {

	aspect default {
		draw shape color: #black;
	}

}

species entrada {
	float lat;
	float lon;
	point ent;
	aspect base {
		//draw file("../includes/red_car.png") size: 50;
		draw circle(30000) color: rgb(#gamablue,0.8) border: #gamablue depth:10;
	}

}

experiment Simulacion2 type: gui {
/** Insert here the definition of the input and output of the model */
	float minimum_cycle_duration <- 0.02;
	output {
		display map type: 3d {
		//species people aspect: base;
			species entrada aspect:base;
			species road ;
		species people aspect:base;
		}

	}

}
