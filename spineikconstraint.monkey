'see license.txt for source licenses
Strict

Import spine

Class SpineIkConstraint
	'Const radDeg:Float = 180.0 / Math.PI

	Field Data:IkConstraintData
	Field Bones:SpineBone[]
	Field Target:SpineBone
	Field BendDirection:Int = 1
	Field Mix:Float = 1.0

	Method New(data:SpineIkConstraintData, skeleton:SpineSkeleton)
		this.data = data
		mix = data.mix
		BendDirection = data.BendDirection

		Bones = New List<SpineBone>(data.Bones.Length())
		Local boneData:SpineBoneData
		For Local i:= 0 Until data.Bones.Length()
			boneData = data.Bones[i]
			Bones[i] = skeleton.FindBone(boneData.Name)
			Target = skeleton.FindBone(data.Target.Name)
		Next
	End

	Method Apply:Void()
		Select Bones.Length()
			case 1:
				Apply(Bones[0], Target.WorldX, Target.WorldY, Mix)
			Case 2:
				Apply(Bones[0], Bones[1], Target.WorldX, Target.WorldY, BendDirection, Mix)
		End
	End

	Method ToString:String()
		Return Data.Name
	End
	
	'<summary>Adjusts the bone rotation so the tip is as close to the Target position as possible. The Target is specified
	'in the world coordinate system.</summary>
	Function Apply:Void(bone:SpineBone, targetX:Float, targetY:Float, alpha:Float)
		Local parentRotation:Float
		If Not bone.Data.InheritRotation Or bone.Parent = Null
			parentRotation = 0.0
		Else
			parentRotation = bone.Parent.WorldRotation
		EndIf
		Local rotation:Float = Bone.Rotation
		'Local rotationIK:Float = ATan2(targetY - bone.WorldY, targetX - bone.WorldX) * radDeg - parentRotation
		Local rotationIK:Float = ATan2(targetY - bone.WorldY, targetX - bone.WorldX) - parentRotation
		bone.RotationIK = rotation + (rotationIK - rotation) * alpha
	End

	'<summary>Adjusts the parent and child bone rotations so the tip of the child is as close to the Target position as
	'possible. The Target is specified in the world coordinate system.</summary>
	'<param name="child">Any descendant bone of the parent.</param>
	Function Apply:Void(parent:SpineBone, child:SpineBone, targetX:Float, targetY:Float, bendDirection:Int, alpha:Float)
		Local childRotation:= child.Rotation
		Local parentRotation:= parent.Rotation
		if alpha = 0.0
			child.RotationIK = childRotation
			parent.RotationIK = parentRotation
			return
		EndIf
		
		Local positionXY:Float[2]
		Local parentParent:SpineBone = parent.Parent
		if parentParent
			parentParent.WorldToLocal(targetX, targetY, positionXY)
			targetX = (positionXY[0] - parent.X) * parentParent.WorldScaleX
			targetY = (positionXY[1] - parent.Y) * parentParent.WorldScaleY
		Else
			targetX -= parent.X
			targetY -= parent.Y
		EndIf
		
		If child.Parent = parent
			positionXY[0] = child.X
			positionXY[1] = child.Y
		else
			child.Parent.LocalToWorld(child.X, child.Y, positionXY)
			parent.WorldToLocal(positionXY[0], positionXY[1], positionXY)
		EndIf
		
		Local childX:Float = positionXY[0] * parent.WorldScaleX, childY = positionXY[1] * parent.WorldScaleY
		Local offset:float = ATan2(childY, childX)
		Local len1:Float = Sqrt(childX * childX + childY * childY)
		Local len2:Float = child.Data.Length * child.WorldScaleX
		
		'Based on code by Ryan Juckett with permission: Copyright (c) 2008-2009 Ryan Juckett, http://www.ryanjuckett.com/
		Local cosDenom:Float = 2.0 * len1 * len2
		If cosDenom < 0.0001
			'child.rotationIK = childRotation + ( (float) Math.Atan2(targetY, targetX) * radDeg - parentRotation - childRotation) * alpha;
			child.RotationIK = childRotation + (ATan2(targetY, targetX) - parentRotation - childRotation) * alpha
			return
		EndIf
		Local cos:Float = (targetX * targetX + targetY * targetY - len1 * len1 - len2 * len2) / cosDenom
		If cos < - 1.0
			cos = -1.0
		ElseIf cos > 1.0
			cos = 1.0
		EndIf
		
		Local childAngle:Float = ACos(cos) * bendDirection
		Local adjacent:Float = len1 + len2 * cos, opposite = len2 * Sin(childAngle)
		Local parentAngle = ATan2(targetY * adjacent - targetX * opposite, targetX * adjacent + targetY * opposite)
		'float rotation = (parentAngle - offset) * radDeg - parentRotation;
		Local rotation = (parentAngle - offset) - parentRotation
		If rotation > 180.0
			rotation -= 360.0
		ElseIf rotation < - 180.0
			rotation += 360.0
		EndIf
		parent.RotationIK = parentRotation + rotation * alpha
		'rotation = (childAngle + offset) * radDeg - childRotation;
		rotation = (childAngle + offset) - childRotation
		If rotation > 180.0
			rotation -= 360.0
		ElseIf rotation < - 180.0
			rotation += 360.0
		EndIf
		child.RotationIK = childRotation + (rotation + parent.WorldRotation - child.Parent.WorldRotation) * alpha
	End
End
