'see license.txt for source licenses
'This example demonstrates how we can use a different atlas loader. The atlas loade we are using will load seperate images instead of loading packed images.
Import mojo
Import skn3.monkeyspine

Function Main:Int()
	New MyApp
	Return 0
End

Class MyApp Extends App
	Field timestamp:Int
	Field spineBoy:SpineEntity
	
	Method OnCreate:Int()
		' --- create the app ---
		'setup runtime
		SetUpdateRate(60)
		timestamp = Millisecs()
		
		'load spineboy
		Try
			spineBoy = New SpineEntity("spineboy.json", "spineboy_seperate", SpineSeperateFileAtlasLoader.instance)
			spineBoy.SetPosition(DeviceWidth() / 2, DeviceHeight() -100)
			spineBoy.SetAnimation("walk", True)
			
		Catch exception:SpineException
			Error("Exception: " + exception)
		End
		
		'must alwasy return
		Return 0
	End
	
	Method OnRender:Int()
		' --- render the app ---
		Cls(128, 128, 128)
		
		'simples! render current item
		spineBoy.Render()
		
		'must alwasy return
		Return 0
	End
	
	Method OnUpdate:Int()
		' --- update the app ---
		'check for quit
		If KeyHit(KEY_ESCAPE) OnClose()
		
		'update time/delta
		Local newTimestamp:Int = Millisecs()
		Local deltaInt:Int = newTimestamp - timestamp
		Local deltaFloat:Float = deltaInt / 1000.0
		timestamp = newTimestamp
		
		'update item entity
		spineBoy.Update(deltaFloat)
		
		'must alwasy return
		Return 0
	End
End