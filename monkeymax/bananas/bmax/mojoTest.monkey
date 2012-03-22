Strict

'#if TARGET="bmax"
'Import mojomax
'#else
Import mojo
'#end

Global game:MyGame

Function Main:Int()
	game = New MyGame
	Return 0
End

Class MyGame Extends App
	Field spr:Ship
	Field img:Image
	
	Method OnCreate:Int()
		SetUpdateRate 60
		Print "millisec = "+Millisecs()
		spr = New Ship (LoadImage("Ship1.png", 64, 64, 6), 100, 100)
		img = LoadImage("Ship1.png")
		Return 0
	End
	
	Method OnUpdate:Int()
		spr.Update()
		Return 0		
	End
	
	Method OnRender:Int()
		Cls(100,100,100)
		DrawText("HELLO", DeviceWidth()/2, 10, .5, .5)
		DrawImage(img, 10, 64)
		SetColor(255,255,0)
		spr.Draw()
		SetColor(255,0,255)
		DrawLine(0, 0, DeviceWidth(), DeviceHeight())
		SetColor(0,255,255)
		DrawCircle(50, 200, 10)
		SetColor(255,255,0)
		Local tri#[]=[10.0,300.0,100.0,400.0,0.0,400.0]
		DrawPoly tri
		SetColor(255,0,0)
		DrawRect(100,300,100,50)
		SetColor(255,255,255)
		DrawImageRect(img, 10, 128, 32, 0, 64, 64)
		
		Return 0
	End
End

Class Sprite
	Field x#, y#
	Field img:Image
	Field frame%
	Field frameDelay%
	Field maxFrame%
	Field frameMaxDelay%
	Field pingpong% = True
	Field reverse:Bool = False
End

Class Ship Extends Sprite
	Method New(img:Image, x#, y#)
		Self.img = img
		Self.x = x
		Self.y = y
		Self.maxFrame = 5
		Self.frameMaxDelay = 5
	End
	
	Method Draw:Void()
		DrawImage img, x, y, frame
		DrawImage img, x, y + 64
	End
	
	Method Update:Void()
		frameDelay+=1
		If frameDelay>frameMaxDelay
			frameDelay = 0
			If Not reverse
				frame+=1
			Else
				frame-=1
			End
			
			If frame>maxFrame
				If Not pingpong
					frame = 0
				Else
					frame = maxFrame
					reverse = True
				End
			End
			If frame < 0
				frame = 0
				reverse = False
			End
		End
		x+=.5
		y+=.2
	End
End
