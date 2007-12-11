﻿/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/


package TestBed{
	
	
	
	import Engine.Dynamics.*;
	import Engine.Collision.*;
	import Engine.Collision.Shapes.*;
	import Engine.Dynamics.Joints.*;
	import Engine.Dynamics.Contacts.*;
	import Engine.Common.*;
	import Engine.Common.Math.*;
	import Main;
	import General.Input;
	
	import flash.utils.getTimer
	import flash.display.*;
	
	
	
	public class Test{
		
		public function Test(){
			
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.minVertex.Set(-100.0, -100.0);
			worldAABB.maxVertex.Set(100.0, 100.0);
			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			
			// Construct a world object
			m_world = new b2World(worldAABB, gravity, doSleep);
			
			m_sprite = Main.m_sprite;
			
			// Create border of boxes
			var wallSd:b2BoxDef = new b2BoxDef();
			var wallBd = new b2BodyDef();
			wallBd.AddShape(wallSd);
			
			// Left
			wallSd.extents.Set(100/m_physScale, 1000/m_physScale/2);
			wallBd.position.Set(-95 / m_physScale, 1000/m_physScale/2);
			m_world.CreateBody(wallBd);
			// Right
			wallBd.position.Set((1000+120) / m_physScale, 1000/m_physScale/2);
			m_world.CreateBody(wallBd);
			// Top
			wallSd.extents.Set(1500/m_physScale/2, 100/m_physScale);
			wallBd.position.Set(1000/m_physScale/2, -95/m_physScale);
			m_world.CreateBody(wallBd);
			// Right0
			wallBd.position.Set(1000/m_physScale/2, (750+95)/m_physScale);
			m_world.CreateBody(wallBd);
		}
		
		
		public function Update(){
			
			// Update mouse joint
			UpdateMouseWorld()
			MouseDrag();
			
			// Update physics
			var physStart:uint = getTimer();
			m_world.Step(m_timeStep, m_iterations);
			//Main.m_fpsCounter.updatePhys(physStart);
			
			// Render
			// joints
			for (var jj:b2Joint = m_world.m_jointList; jj; jj = jj.m_next){
				DrawJoint(jj);
			}
			// bodies
			for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next){
				for (var s:b2Shape = bb.GetShapeList(); s != null; s = s.GetNext()){
					DrawShape(s);
				}
			}
			
		}
		
		
		//======================
		// Member Data 
		//======================
		public var m_world:b2World;
		public var m_bomb:b2Body;
		public var m_mouseJoint:b2MouseJoint;
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1/30;
		public var m_physScale:Number = 100;
		// world mouse position
		static public var mouseXWorldPhys:Number;
		static public var mouseYWorldPhys:Number;
		static public var mouseXWorld:Number;
		static public var mouseYWorld:Number;
		// Sprite to draw in to
		public var m_sprite:Sprite;
		
		
		
		//======================
		// Update mouseWorld
		//======================
		public function UpdateMouseWorld(){
			mouseXWorldPhys = (Input.mouseX)/m_physScale; 
			mouseYWorldPhys = (Input.mouseY)/m_physScale; 
			
			mouseXWorld = (Input.mouseX); 
			mouseYWorld = (Input.mouseY); 
		}
		
		
		
		//======================
		// Mouse Drag 
		//======================
		public function MouseDrag(){
			// mouse press
			if (Input.mouseDown && !m_mouseJoint){
				
				var body:b2Body = GetBodyAtMouse();
				
				if (body)
				{
					var md:b2MouseJointDef = new b2MouseJointDef();
					md.body1 = m_world.m_groundBody;
					md.body2 = body;
					md.target.Set(mouseXWorldPhys, mouseYWorldPhys);
					md.maxForce = 1000.0 * body.m_mass;
					md.timeStep = m_timeStep;
					m_mouseJoint = m_world.CreateJoint(md) as b2MouseJoint;
					body.WakeUp();
				}
			}
			
			
			// mouse release
			if (!Input.mouseDown){
				if (m_mouseJoint)
				{
					m_world.DestroyJoint(m_mouseJoint);
					m_mouseJoint = null;
				}
			}
			
			
			// mouse move
			if (m_mouseJoint)
			{
				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
				m_mouseJoint.SetTarget(p2);
			}
		}
		
		
		
		//======================
		// GetBodyAtMouse
		//======================
		private var mousePVec:b2Vec2 = new b2Vec2();
		public function GetBodyAtMouse(includeStatic:Boolean=false):b2Body{
			// Make a small box.
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.minVertex.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.maxVertex.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			
			// Query the world for overlapping shapes.
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i)
			{
				if (shapes[i].m_body.IsStatic() == false || includeStatic)
				{
					var inside:Boolean = shapes[i].TestPoint(mousePVec);
					if (inside)
					{
						body = shapes[i].m_body;
						break;
					}
				}
			}
			return body;
		}
		
		
		//======================
		// Draw Pairs
		//======================
		public function DrawPairs(){
			
			var bp:b2BroadPhase = m_world.m_broadPhase;
			var invQ:b2Vec2 = new b2Vec2();
			invQ.Set(1.0 / bp.m_quantizationFactor.x, 1.0 / bp.m_quantizationFactor.y);
			
			for (var i:int = 0; i < bp.m_pairManager.m_pairCount; ++i)
			{
				var pair:b2Pair = bp.m_pairManager.m_pairs[ i ];
				var id1:uint = pair.proxyId1;
				var id2:uint = pair.proxyId2;
				var p1:b2Proxy = bp.m_proxyPool[ id1 ];
				var p2:b2Proxy = bp.m_proxyPool[ id2 ];
				
				var b1:b2AABB = new b2AABB();
				var b2:b2AABB = new b2AABB();
				b1.minVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p1.lowerBounds[0]].value;
				b1.minVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p1.lowerBounds[1]].value;
				b1.maxVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p1.upperBounds[0]].value;
				b1.maxVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p1.upperBounds[1]].value;
				b2.minVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p2.lowerBounds[0]].value;
				b2.minVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p2.lowerBounds[1]].value;
				b2.maxVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p2.upperBounds[0]].value;
				b2.maxVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p2.upperBounds[1]].value;
				
				var x1:b2Vec2 = b2Math.MulFV(0.5, b2Math.AddVV(b1.minVertex, b1.maxVertex) );
				var x2:b2Vec2 = b2Math.MulFV(0.5, b2Math.AddVV(b2.minVertex, b2.maxVertex) );
				
				m_sprite.graphics.lineStyle(1,0xff2222,1);
				m_sprite.graphics.moveTo(x1.x * m_physScale, x1.y * m_physScale);
				m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
			}
			
		}
		
		//======================
		// Draw Contacts
		//======================
		public function DrawContacts(){
			for (var c:b2Contact = m_world.m_contactList; c; c = c.m_next)
			{
				var ms:Array = c.GetManifolds();
				for (var i:int = 0; i < c.GetManifoldCount(); ++i)
				{
					var m:b2Manifold = ms[ i ];
					//this.graphics.lineStyle(3,0x11CCff,0.7);
					
					for (var j:int = 0; j < m.pointCount; ++j)
					{	
						m_sprite.graphics.lineStyle(m.points[j].normalImpulse,0x11CCff,0.7);
						var v:b2Vec2 = m.points[j].position;
						m_sprite.graphics.moveTo(v.x * m_physScale, v.y * m_physScale);
						m_sprite.graphics.lineTo(v.x * m_physScale, v.y * m_physScale);
						
					}
				}
			}
		}
		
		
		//======================
		// Draw Shape 
		//======================
		public function DrawShape(shape:b2Shape){
			switch (shape.m_type)
			{
			case b2Shape.e_circleShape:
				{
					var circle:b2CircleShape = shape as b2CircleShape;
					var pos:b2Vec2 = circle.m_position;
					var r:Number = circle.m_radius;
					var k_segments:Number = 16.0;
					var k_increment:Number = 2.0 * Math.PI / k_segments;
					m_sprite.graphics.lineStyle(1,0xffffff,1);
					m_sprite.graphics.moveTo((pos.x + r) * m_physScale, (pos.y) * m_physScale);
					var theta:Number = 0.0;
					
					for (var i:int = 0; i < k_segments; ++i)
					{
						var d:b2Vec2 = new b2Vec2(r * Math.cos(theta), r * Math.sin(theta));
						var v:b2Vec2 = b2Math.AddVV(pos , d);
						m_sprite.graphics.lineTo((v.x) * m_physScale, (v.y) * m_physScale);
						theta += k_increment;
					}
					m_sprite.graphics.lineTo((pos.x + r) * m_physScale, (pos.y) * m_physScale);
					
					m_sprite.graphics.moveTo((pos.x) * m_physScale, (pos.y) * m_physScale);
					var ax:b2Vec2 = circle.m_R.col1;
					var pos2:b2Vec2 = new b2Vec2(pos.x + r * ax.x, pos.y + r * ax.y);
					m_sprite.graphics.lineTo((pos2.x) * m_physScale, (pos2.y) * m_physScale);
				}
				break;
			case b2Shape.e_polyShape:
				{
					var poly:b2PolyShape = shape as b2PolyShape;
					var tV:b2Vec2 = b2Math.AddVV(poly.m_position, b2Math.b2MulMV(poly.m_R, poly.m_vertices[i]));
					m_sprite.graphics.lineStyle(1,0xffffff,1);
					m_sprite.graphics.moveTo(tV.x * m_physScale, tV.y * m_physScale);
					
					for (i = 0; i < poly.m_vertexCount; ++i)
					{
						v = b2Math.AddVV(poly.m_position, b2Math.b2MulMV(poly.m_R, poly.m_vertices[i]));
						m_sprite.graphics.lineTo(v.x * m_physScale, v.y * m_physScale);
					}
					m_sprite.graphics.lineTo(tV.x * m_physScale, tV.y * m_physScale);
				}
				break;
			}
		}
		
		
		//======================
		// Draw Joint 
		//======================
		public function DrawJoint(joint:b2Joint)
		{
			var b1:b2Body = joint.m_body1;
			var b2:b2Body = joint.m_body2;
			
			var x1:b2Vec2 = b1.m_position;
			var x2:b2Vec2 = b2.m_position;
			var p1:b2Vec2 = joint.GetAnchor1();
			var p2:b2Vec2 = joint.GetAnchor2();
			
			m_sprite.graphics.lineStyle(1,0x44aaff,1/1);
			
			switch (joint.m_type)
			{
			case b2Joint.e_distanceJoint:
			case b2Joint.e_mouseJoint:
				m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
				m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
				break;
				
			case b2Joint.e_pulleyJoint:
				var pulley:b2PulleyJoint = joint as b2PulleyJoint;
				var s1:b2Vec2 = pulley.GetGroundPoint1();
				var s2:b2Vec2 = pulley.GetGroundPoint2();
				m_sprite.graphics.moveTo(s1.x * m_physScale, s1.y * m_physScale);
				m_sprite.graphics.lineTo(p1.x * m_physScale, p1.y * m_physScale);
				m_sprite.graphics.moveTo(s2.x * m_physScale, s2.y * m_physScale);
				m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
				break;
				
			default:
				if (b1 == m_world.m_groundBody){
					m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
					m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
				}
				else if (b2 == m_world.m_groundBody){
					m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
					m_sprite.graphics.lineTo(x1.x * m_physScale, x1.y * m_physScale);
				}
				else{
					m_sprite.graphics.moveTo(x1.x * m_physScale, x1.y * m_physScale);
					m_sprite.graphics.lineTo(p1.x * m_physScale, p1.y * m_physScale);
					m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
					m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
				}
			}
		}
	}
	
}