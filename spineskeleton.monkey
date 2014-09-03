'see license.txt for source licenses
Strict

Import spine

Class SpineSkeleton
	Field Data:SpineSkeletonData
	Field Bones:SpineBone[]
	Field Slots:SpineSlot[]
	Field DrawOrder:SpineSlot[]
	Field IkConstraints:SpineIkConstraint[]
	Field Skin:SpineSkin
	Field R:Float
	Field G:Float
	Field B:Float
	Field A:Float
	Field Time:Float
	Field LastTime:Float
	Field FlipX:Bool
	Field FlipY:Bool
	
	Method RootBone:SpineBone()
		If Bones.Length() = 0 Return Null
		Return Bones[0]
	End

	Method New(data:SpineSkeletonData)
		If data = Null Throw New SpineArgumentNullException("data cannot be null.")
		Data = data

		Bones = New SpineBone[Data.Bones.Length()]
		Slots = New SpineSlot[Data.Slots.Length()]
		DrawOrder = New SpineSlot[Data.Slots.Length()]
		
		Local bonesIndex:Int
		Local parent:SpineBone
		Local boneData:SpineBoneData
		Local index:Int
		Local indexOf:Int
		Local bone:SpineBone
		Local slot:SpineSlot
		Local slotOrderIndex:Int
		
		For index = 0 Until Data.Bones.Length()
			'find bone data and parent
			boneData = Data.Bones[index]
			parent = Null
			If boneData.Parent
				For indexOf = 0 Until Data.Bones.Length()
					If Data.Bones[indexOf] = boneData.Parent
						parent = Bones[indexOf]
						Exit
					EndIf
				Next
			EndIf
			
			'create new bone
			Bones[bonesIndex] = New SpineBone(boneData, parent)
			Bones[bonesIndex].parentIndex = bonesIndex
			
			bonesIndex += 1
		Next

		For index = 0 Until Data.Slots.Length()
			bone = Null
			For indexOf = 0 Until Data.Bones.Length()
				If Data.Bones[indexOf] = Data.Slots[index].BoneData
					bone = Bones[indexOf]
					Exit
				EndIf
			Next
			
			'create new slot
			slot = New SpineSlot(Data.Slots[index], Self, bone)
			slot.parentIndex = slotOrderIndex
			
			Slots[slotOrderIndex] = slot
			DrawOrder[slotOrderIndex] = slot
			slotOrderIndex += 1
		Next

		R = 1
		G = 1
		B = 1
		A = 1
	End

	Method UpdateWorldTransform:Void()
		For Local i:= 0 Until Bones.Length()
			Bones[i].UpdateWorldTransform(FlipX, FlipY)
		Next
	End

	Method SetToBindPose:Void()
		SetBonesToBindPose()
		SetSlotsToBindPose()
	End

	Method SetBonesToBindPose:Void()
		For Local i:= 0 Until Bones.Length()
			Bones[i].SetToBindPose()
		Next
	End

	Method SetSlotsToBindPose:Void()
		For Local i:= 0 Until Slots.Length()
			Slots[i].SetToBindPose(i)
		Next
	End
	
	Method ResetSlotOrder:Void()
		For Local i:= 0 Until Slots.Length()
			DrawOrder[i] = Slots[i]
		Next
	End

	Method FindBone:SpineBone(boneName:String)
		If boneName.Length() = 0 Return Null
		For Local i:= 0 Until Bones.Length()
			If Bones[i].Data.Name = boneName Return Bones[i]
		Next
		return null
	End

	Method FindBoneIndex:Int(boneName:String)
		If boneName.Length() = 0 Return - 1
		For Local i:= 0 Until Bones.Length()
			If Bones[i].Data.Name = boneName Return i
		Next
		Return -1
	End

	Method FindSlot:SpineSlot(slotName:String)
		If slotName.Length() = 0 Return Null
		For Local i:= 0 Until Slots.Length()
			If Slots[i].Data.Name = slotName Return Slots[i]
		Next
		Return Null
	End

	Method FindSlotIndex:Int(slotName:String)
		If slotName.Length() = 0 Return - 1
		For Local i:= 0 Until Slots.Length()
			If Slots[i].Data.Name = slotName Return i
		Next
		Return -1
	End

	Method SetSkin:Void(skinName:String)
		Local skin:SpineSkin = Data.FindSkin(skinName)
		If skin = Null Throw New SpineException("Spine skin '" + skinName + "' not found")
		SetSkin(skin)
	End

	Method SetSkin:Void(newSkin:SpineSkin)
		If Skin <> Null And newSkin <> Null newSkin.AttachAll(Self, Skin)
		Skin = newSkin
	End

	Method GetAttachment:SpineAttachment(slotName:String, attachmentName:String)
		return GetAttachment(Data.FindSlotIndex(slotName), attachmentName)
	End

	Method GetAttachment:SpineAttachment(slotIndex:Int, attachmentName:String)
		If attachmentName.Length() = 0 Return Null
		If Skin <> Null
			Local attachment:SpineAttachment = Skin.GetAttachment(slotIndex, attachmentName)
			If attachment <> Null Return attachment
		EndIf
		If Data.DefaultSkin <> Null Return Data.DefaultSkin.GetAttachment(slotIndex, attachmentName)
		return null
	End

	Method SetAttachment:Void(slotName:String, attachmentName:String)
		If slotName.Length() = 0 Throw New SpineArgumentNullException("slotName cannot be empty.")

		For Local i:= 0 Until Slots.Length()
			If Slots[i].Data.Name = slotName
				Local attachment:SpineAttachment = Null
				If attachmentName <> ""
					attachment = GetAttachment(i, attachmentName)
					If attachment = Null Throw New SpineArgumentNullException("SpineAttachment not found: " + attachmentName + ", for slot: " + slotName)
				EndIf
				Slots[i].Attachment = attachment
				return
			EndIf
		Next
		throw new SpineException("SpineSlot not found: " + slotName)
	End

	Method Update:Void(delta:Float)
		LastTime = Time
		Time += delta
	End
End
