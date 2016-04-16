package vgdev.stroll.support.graph 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_IMovable;
	import vgdev.stroll.support.ABST_Support;
	import vgdev.stroll.System;
	
	/**
	 * Helper class to manage the ship's pathfinding network
	 * @author Alexander Huynh
	 */
	public class GraphMaster extends ABST_Support 
	{
		public var nodes:Array = [];				// unordered list of nodes for iteration
		public var nodeMap:Object;					// map of MovieClip name to node object
		
		public var nodeDirections:Object = { };		// Floyd-Warshall directions
		
		public function GraphMaster(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		/**
		 * Manually add ship network nodes
		 * @param	shipName
		 */
		public function initShip(shipName:String):void
		{
			var ship:MovieClip = cg.game.mc_ship;
			nodeMap = { };
			
			switch (shipName)
			{
				case "Eagle":
					addNode(ship.node_f);
					addNode(ship.node_fh0);
					addNode(ship.node_fh1);
					addNode(ship.node_m0);
					addNode(ship.node_m1);
					addNode(ship.node_t);
					addNode(ship.node_c);
					addNode(ship.node_r);
					addNode(ship.node_cu);
					addNode(ship.node_ur);
					addNode(ship.node_u0);
					addNode(ship.node_u1);
					addNode(ship.node_u2);
					addNode(ship.node_br);
					addNode(ship.node_b0);
					addNode(ship.node_b1);
					addNode(ship.node_b2);
					
					nodeMap["node_f"].connectNodes(["node_fh1"]);
					nodeMap["node_fh0"].connectNodes(["node_m0", "node_fh1"]);
					nodeMap["node_fh1"].connectNodes(["node_f", "node_fh0"]);
					nodeMap["node_m0"].connectNodes(["node_m1", "node_fh0"]);
					nodeMap["node_m1"].connectNodes(["node_m0", "node_t"]);
					nodeMap["node_t"].connectNodes(["node_c", "node_m1"]);
					nodeMap["node_c"].connectNodes(["node_r", "node_b2", "node_cu", "node_t"]);
					nodeMap["node_r"].connectNodes(["node_c", "node_ur", "node_br"]);
					nodeMap["node_cu"].connectNodes(["node_c", "node_u2"]);
					nodeMap["node_ur"].connectNodes(["node_r", "node_u0"]);
					nodeMap["node_u0"].connectNodes(["node_ur", "node_u1"]);
					nodeMap["node_u1"].connectNodes(["node_u0", "node_u2"]);
					nodeMap["node_u2"].connectNodes(["node_u1", "node_cu"]);
					nodeMap["node_br"].connectNodes(["node_r", "node_b0"]);
					nodeMap["node_b0"].connectNodes(["node_br", "node_b1"]);
					nodeMap["node_b1"].connectNodes(["node_b0", "node_b2"]);
					nodeMap["node_b2"].connectNodes(["node_b1", "node_c"]);
				break;
				case "Kingfisher":
					addNode(ship.node_ff);
					addNode(ship.node_f);
					addNode(ship.node_c0);
					addNode(ship.node_c1);
					addNode(ship.node_c2);
					addNode(ship.node_c3);
					addNode(ship.node_l);
					addNode(ship.node_lr);
					addNode(ship.node_r0);
					addNode(ship.node_r1);
					addNode(ship.node_r2);
					addNode(ship.node_rr);
					
					nodeMap["node_ff"].connectNodes(["node_f"]);
					nodeMap["node_f"].connectNodes(["node_c0", "node_ff"]);
					nodeMap["node_c0"].connectNodes(["node_f", "node_c1", "node_r0"]);
					nodeMap["node_c1"].connectNodes(["node_c0", "node_c2", "node_l"]);
					nodeMap["node_c2"].connectNodes(["node_c3", "node_c1"]);
					nodeMap["node_c3"].connectNodes(["node_lr", "node_c2"]);
					nodeMap["node_l"].connectNodes(["node_c1"]);
					nodeMap["node_lr"].connectNodes(["node_c3", "node_r2"]);
					nodeMap["node_r0"].connectNodes(["node_c0", "node_r1", "node_rr"]);
					nodeMap["node_r1"].connectNodes(["node_r0", "node_r2"]);
					nodeMap["node_r2"].connectNodes(["node_r1", "node_lr", "node_rr"]);
					nodeMap["node_rr"].connectNodes(["node_r0", "node_r2"]);
				break;
				default:
					trace("[GraphMaster] Warning: Nothing defined for ship with name", shipName);
			}
			
			initGraph();
		}
		
		/**
		 * Add a node to the network
		 * @param	mc		MovieClip to be associated with the node
		 */
		public function addNode(mc:MovieClip):void
		{
			var node:GraphNode = new GraphNode(cg, this, mc);
			nodes.push(node);
			var n:String = mc.name;
			nodeMap[n] = node;
		}
		
		/**
		 * Populate the nodeDirections map using Floyd-Warshall
		 */
		public function initGraph():void
		{
			var dist:Object = {};
			var node:GraphNode; var other:GraphNode;
			var i:int; var j:int; var k:int;
			
			// initialization
			for each (node in nodes)
			{
				dist[node.mc_object.name] = { };
				nodeDirections[node.mc_object.name] = { };
				for each (other in nodes)
				{
					if (node.edges.indexOf(other) != -1)
					{
						dist[node.mc_object.name][other.mc_object.name] = node.edgeCost[other.mc_object.name];
						nodeDirections[node.mc_object.name][other.mc_object.name] = other;
					}
					else
					{
						dist[node.mc_object.name][other.mc_object.name] = 99999999;
						nodeDirections[node.mc_object.name][other.mc_object.name] = null;
					}
				}
			}
			
			// Floyd-Warshall
			var newDist:Number;
			for (k = 0; k < nodes.length; k++)
				for (i = 0; i < nodes.length; i++)
					for (j = 0; j < nodes.length; j++)
					{
						if (dist[nodes[i].mc_object.name][nodes[k].mc_object.name] + dist[nodes[k].mc_object.name][nodes[j].mc_object.name] < dist[nodes[i].mc_object.name][nodes[j].mc_object.name])
						{
							dist[nodes[i].mc_object.name][nodes[j].mc_object.name] = dist[nodes[i].mc_object.name][nodes[k].mc_object.name] + dist[nodes[k].mc_object.name][nodes[j].mc_object.name];
							nodeDirections[nodes[i].mc_object.name][nodes[j].mc_object.name] = nodeDirections[nodes[i].mc_object.name][nodes[k].mc_object.name];
						}
					}
		}
		
		/**
		 * Get a path of network nodes from an object to a destination
		 * @param	origin			ABST_IMovable that is requesting a path
		 * @param	destination		Point, place to go to
		 * @return					Ordered array of nodes
		 */
		public function getPath(origin:ABST_IMovable, destination:Point):Array
		{
			var start:GraphNode = getNearestValidNode(origin, new Point(origin.mc_object.x, origin.mc_object.y));
			var end:GraphNode = getNearestValidNode(origin, destination);
			if (start == null || end == null || nodeDirections[start.mc_object.name][end.mc_object.name] == null)
				return [];
			var path:Array = [start];
			while (start != end)
			{
				start = nodeDirections[start.mc_object.name][end.mc_object.name];
				path.push(start);
			}				
			return path;
		}
		
		/**
		 * Find the nearest node within LOS of the origin to the target
		 * @param	origin			ABST_IMovable to base LOS off of
		 * @param	target			Point of interest
		 * @param	ignoreWalls		true to ignore LOS check
		 * @return					The closest node (possibly within LOS)
		 */
		public function getNearestValidNode(origin:ABST_IMovable, target:Point, ignoreWalls:Boolean = false ):GraphNode
		{
			if (!origin || !target) return null;
			var originalPos:Point = new Point(origin.mc_object.x, origin.mc_object.y);
			origin.mc_object.x = target.x;
			origin.mc_object.y = target.y;
			var dist:Number = 99999;
			var nearest:GraphNode = null;
			var newDist:Number;
			for each (var node:GraphNode in nodes)
			{
				newDist = System.getDistance(target.x, target.y, node.mc_object.x, node.mc_object.y);
				if (newDist > dist) continue;
				if (ignoreWalls || System.hasLineOfSight(origin, new Point(node.mc_object.x, node.mc_object.y)))
				{
					dist = newDist;
					nearest = node;
				}
			}
			origin.mc_object.x = originalPos.x;
			origin.mc_object.y = originalPos.y;
			return nearest;
		}
	}
}