'see license.txt for source licenses
Strict

Import spine

Interface SpineAttachmentLoader
	'return May be null to not load any attachment. 
	Method NewRegionAttachment:SpineRegionAttachment(skin:SpineSkin, name:String)
	Method NewMeshAttachment:SpineMeshAttachment(skin:SpineSkin, name:String)
	Method NewSkinnedMeshAttachment:SpineSkinnedMeshAttachment(skin:SpineSkin, name:String)
	Method NewBoundingBoxAttachment:SpineBoundingBoxAttachment(skin:SpineSkin, name:String)
End
