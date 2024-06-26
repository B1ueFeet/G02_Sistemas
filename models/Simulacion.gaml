/**
* Name: Simulacion
* Simulación del flujo vehicular y peatonal en la Universidad Central del Ecuador 
* Author: G2
* Tags: 
*/
model Simulacion

global {
	float step <- 5.0;
	float speed_limit_vehicle;
	float speed_limit_human_run;
	float speed_limit_human_walk;
	file shapefile_roads <- file("../includes/roads.shp");
	file shapefile_point <- file("../includes/points.shp");
	geometry shape <- envelope(shapefile_roads);
	graph road_network;
	list<point> entradas;
	list<point> facultades;

	/*Para probar la congestión en los días lluviosos  y */
	bool rain;
	int vehicles;
	int humans;
	int counter <- 1;

	/*INICIAMOS EL ENTORNO */
	init {
		create road from: shapefile_roads with: [num_lanes::int(read("lanes"))] {
			create road {
				num_lanes <- myself.num_lanes;
				shape <- polyline(reverse(myself.shape.points));
				maxspeed <- myself.maxspeed;
				linked_road <- myself;
				myself.linked_road <- self;
			}

		}

		create intersection from: shapefile_point with: [is_traffic_signal::(read("type") = "traffic_signals")] {
			time_to_change <- 30 #s;
		}
		/*CREAR ARCHIVO CSV CON COLUMNAS DE LAT, LON Y TIPO DE ENTRADA*/
		create entrada from: entradas_csv with: [lat::float(get("Latitude")), lon::float(get("Longitude"))] {
			location <- to_GAMA_CRS({lon, lat}, "EPSG:4326").location;
			add location to: entradas;
		}
		/*CREAR ARCHIVO CSV CON COLUMNAS DE LAT, LON Y NOMBRE DE EDIFICIO*/
		create edificio from: edificios_csv with: [lat::float(get("Latitude")), lon::float(get("Longitude"))] {
			location <- to_GAMA_CRS({lon, lat}, "EPSG:4326").location;
			add location to: facultades;
		}
		// Create a graph representing the road network, with road lengths as weights
		map edge_weights <- road as_map (each::each.shape.perimeter);
		road_network <- as_driving_graph(road, intersection) with_weights edge_weights;

		// Initialize the traffic lights
		ask intersection {
			do initialize;
		}

		/*Definimos los atributos del vehículo al inicializarse */
		create vehicle_following_path number: vehiculos with: (vehicle_max_speed: vehicle_speed_limit);
		create human_following_path number: humans with: (human_max_speed: human_speed_limit);
	} }

species vehicle_following_path parent: base_vehicle {
	float timer <- 0.0 #minute; // Add a timer variable
	float vehicle_max_speed;

	init {
		vehicle_width <- 1.8 #m;
		if (rain) {
			max_speed <- rnd(20, 30, 40) / 3600;
		} else {
			max_speed <- (40, 50) / 3600;
		}

		max_acceleration <- 3.5;
	}
	/*DEfinimos los atributos de las personas al inicializarse */
	/*DEFINIR LOS CARROS EN EL MAPA EN POSICIONES ALEATORIAS */
	reflex select_next_path when: current_path = nil {
		list<intersection> dst_nodes <- [intersection[rnd(3017)], restaurantes[rnd(8)] as intersection, pedidos[rnd(32)] as intersection];
		do compute_path graph: road_network nodes: dst_nodes;
	}

	reflex commute when: current_path != nil {
		do drive;
		timer <- timer + step;
	}

	reflex stop when: current_path = nil {
		int t_final <- (timer / 60) as int;
		write ("Llego el auto " + num + " Tiempo: " + t_final + " minutos");
		do die;
	}

}
}

/*AQUÍ DEFINIMOS DÓNDE VAN A APARECER LOS AGENTES Y LOS PUNTOS DE LLEGADA */


	
	
	
	
