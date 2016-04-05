package vgdev.stroll.support.graph 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_IMovable;
	import vgdev.stroll.support.ABST_Support;
	import vgdev.stroll.System;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class GraphMaster extends ABST_Support 
	{
		public var nodes:Array = [];
		public var nodeMap:Object;
		
		public var nodeDirections:Object = { };
		
		public function GraphMaster(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
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
					nodeMap["node_c"].connectNodes(["node_r", "node_b2", "node_u2", "node_t"]);
					nodeMap["node_r"].connectNodes(["node_c", "node_ur", "node_br"]);
					nodeMap["node_ur"].connectNodes(["node_r", "node_u0"]);
					nodeMap["node_u0"].connectNodes(["node_ur", "node_u1"]);
					nodeMap["node_u1"].connectNodes(["node_u0", "node_u2"]);
					nodeMap["node_u2"].connectNodes(["node_u1", "node_c"]);
					nodeMap["node_br"].connectNodes(["node_r", "node_b0"]);
					nodeMap["node_b0"].connectNodes(["node_br", "node_b1"]);
					nodeMap["node_b1"].connectNodes(["node_b0", "node_b2"]);
					nodeMap["node_b2"].connectNodes(["node_b1", "node_c"]);
				break;
			}
			
			initGraph();
		}
		
		public function addNode(mc:MovieClip):void
		{
			var node:GraphNode = new GraphNode(cg, this, mc);
			nodes.push(node);
			var n:String = mc.name;
			nodeMap[n] = node;
		}
		
		public function initGraph():void
		{
			var dist:Object = {};
			var node:GraphNode;
			var other:GraphNode;
			var i:int;
			var j:int;
			var k:int;
			
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
		
		public function getPath(origin:ABST_IMovable, destination:Point):Array
		{
			var start:GraphNode = getNearestValidNode(origin, new Point(origin.mc_object.x, origin.mc_object.y));
			var end:GraphNode = getNearestValidNode(origin, destination, true);
			if (nodeDirections[start.mc_object.name][end.mc_object.name] == null)
				return [];
			var path:Array = [start];
			while (start != end)
			{
				start = nodeDirections[start.mc_object.name][end.mc_object.name];
				path.push(start);
			}				
			return path;
		}
		
		public function getNearestValidNode(origin:ABST_IMovable, target:Point, ignoreWalls:Boolean = false ):GraphNode
		{
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
			
			return nearest;
		}
	}
}