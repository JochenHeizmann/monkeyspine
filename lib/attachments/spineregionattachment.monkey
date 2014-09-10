'see license.txt for source licenses
Strict

Import spine

'SpineAttachment that displays a texture region. 
Class SpineRegionAttachment Extends SpineAttachment
	Const X1:= 0
	Const Y1:= 1
	Const X2:= 2
	Const Y2:= 3
	Const X3:= 4
	Const Y3:= 5
	Const X4:= 6
	Const Y4:= 7

	Field X:Float
	Field Y:Float
	Field ScaleX:Float = 1.0
	Field ScaleY:Float = 1.0
	Field Rotation:Float
	Field Width:Float
	Field Height:Float
	
	Field RegionOffsetX:Float
	Field RegionOffsetY:Float
	Field RegionWidth:Float
	Field RegionHeight:Float
	Field RegionOriginalWidth:Float
	Field RegionOriginalHeight:Float

	Field Offset:Float[8]
	Field UVs:Float[8]
	
	Field R:Float
	Field G:Float
	Field B:Float
	Field A:Float
	
	Field Path:String
	Field RendererObject:SpineAtlasRegion
	
	'these are so we have a place to update state at runtime
	Field Vertices:Float[8]
	Field WorldX:Float
	Field WorldY:Float
	Field WorldRotation:Float
	Field WorldScaleX:Float
	Field WorldScaleY:Float
	Field WorldR:Float
	Field WorldG:Float
	Field WorldB:Float
	Field WorldAlpha:Float

	'constructor
	Method New(name:String)
		Super.New(name)
		Type = SpineAttachmentType.region
	End

	'api
	Method SetUVs:Void(u:Float, v:Float, u2:Float, v2:Float, rotate:Bool)
		If rotate
			UVs[X2] = u
			UVs[Y2] = v2
			UVs[X3] = u
			UVs[Y3] = v
			UVs[X4] = u2
			UVs[Y4] = v
			UVs[X1] = u2
			UVs[Y1] = v2
		Else
			UVs[X1] = u
			UVs[Y1] = v2
			UVs[X2] = u
			UVs[Y2] = v
			UVs[X3] = u2
			UVs[Y3] = v
			UVs[X4] = u2
			UVs[Y4] = v2
		EndIf
	End
	
	Method UpdateOffset:Void()
		Local regionScaleX:Float = Width / RegionOriginalWidth * ScaleX
		Local regionScaleY:Float = Height / RegionOriginalHeight * ScaleY
		Local localX:Float = -Width / 2.0 * ScaleX + RegionOffsetX * regionScaleX
		Local localY:Float = -Height / 2.0 * ScaleY + RegionOffsetY * regionScaleY
		Local localX2:Float = localX + RegionWidth * regionScaleX
		Local localY2:Float = localY + RegionHeight * regionScaleY
		'Local radians:Float = Rotation * PI / 180
		'Local cos:Float = Cosr(radians)
		'Local sin:Float = Sinr(radians)
		Local cos:Float = Cos(Rotation)
		Local sin:Float = Sin(Rotation)

		Local localXCos:Float = localX * cos + X
		Local localXSin:Float = localX * sin
		Local localYCos:Float = localY * cos + Y
		Local localYSin:Float = localY * sin
		Local localX2Cos:Float = localX2 * cos + X
		Local localX2Sin:Float = localX2 * sin
		Local localY2Cos:Float = localY2 * cos + Y
		Local localY2Sin:Float = localY2 * sin

		Offset[X1] = localXCos - localYSin
		Offset[Y1] = localYCos + localXSin
		Offset[X2] = localXCos - localY2Sin
		Offset[Y2] = localY2Cos + localXSin
		Offset[X3] = localX2Cos - localY2Sin
		Offset[Y3] = localY2Cos + localX2Sin
		Offset[X4] = localX2Cos - localYSin
		Offset[Y4] = localYCos + localX2Sin
	End
	
	Method ComputeWorldVertices:Void(bone:SpineBone, worldVertices:Float[])
		Local x:Float = bone.Skeleton.x + bone.WorldX
		Local y:Float = bone.Skeleton.y + bone.WorldY
		Local m00:Float = bone.M00
		Local m01:Float = bone.M01
		Local m10:Float = bone.M10
		Local m11:Float = bone.M11

		worldVertices[X1] = Offset[X1] * m00 + Offset[Y1] * m01 + x
		worldVertices[Y1] = Offset[X1] * m10 + Offset[Y1] * m11 + y
		worldVertices[X2] = Offset[X2] * m00 + Offset[Y2] * m01 + x
		worldVertices[Y2] = Offset[X2] * m10 + Offset[Y2] * m11 + y
		worldVertices[X3] = Offset[X3] * m00 + Offset[Y3] * m01 + x
		worldVertices[Y3] = Offset[X3] * m10 + Offset[Y3] * m11 + y
		worldVertices[X4] = Offset[X4] * m00 + Offset[Y4] * m01 + x
		worldVertices[Y4] = Offset[X4] * m10 + Offset[Y4] * m11 + y
	End
	
	' --- glue
	
	Method Update:Void(slot:SpineSlot)
		' --- this will perform updates on teh state of the attachment ---
		#rem
		'vertices
		Vertices[X1] = Offset[X1] * slot.Bone.M00 + Offset[Y1] * slot.Bone.M01 + slot.Bone.WorldX
		Vertices[Y1] = Offset[X1] * slot.Bone.M10 + Offset[Y1] * slot.Bone.M11 + slot.Bone.WorldY
		Vertices[X2] = Offset[X2] * slot.Bone.M00 + Offset[Y2] * slot.Bone.M01 + slot.Bone.WorldX
		Vertices[Y2] = Offset[X2] * slot.Bone.M10 + Offset[Y2] * slot.Bone.M11 + slot.Bone.WorldY
		Vertices[X3] = Offset[X3] * slot.Bone.M00 + Offset[Y3] * slot.Bone.M01 + slot.Bone.WorldX
		Vertices[Y3] = Offset[X3] * slot.Bone.M10 + Offset[Y3] * slot.Bone.M11 + slot.Bone.WorldY
		Vertices[X4] = Offset[X4] * slot.Bone.M00 + Offset[Y4] * slot.Bone.M01 + slot.Bone.WorldX
		Vertices[Y4] = Offset[X4] * slot.Bone.M10 + Offset[Y4] * slot.Bone.M11 + slot.Bone.WorldY
		
		'world
		WorldX = slot.Bone.WorldX + X * slot.Bone.M00 + Y * slot.Bone.M01
		WorldY = slot.Bone.WorldY + X * slot.Bone.M10 + Y * slot.Bone.M11
		WorldRotation = slot.Bone.WorldRotation + Rotation
		WorldScaleX = slot.Bone.WorldScaleX + ScaleX - 1.0
		WorldScaleY = slot.Bone.WorldScaleY + ScaleY - 1.0
		
		'do we need to flip it?
		If slot.Skeleton.FlipX Then
			WorldScaleX = -WorldScaleX
			WorldRotation = -WorldRotation
		End
		If slot.Skeleton.FlipY Then
			WorldScaleY = -WorldScaleY
			WorldRotation = -WorldRotation
		End
		
		'color
		WorldR = (slot.Skeleton.R * slot.R)
		WorldG = (slot.Skeleton.G * slot.G)
		WorldB = (slot.Skeleton.B * slot.B)
		WorldAlpha = slot.Skeleton.A * slot.A
		#end
	End
End
