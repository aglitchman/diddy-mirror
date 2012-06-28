#ANDROID_SCREEN_ORIENTATION="sensor"

Strict

Import diddy

Global screen:TestScreen

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		SetGraphics(320,480)
		SetScreenSize(960, 640, True)
		screen = New TestScreen()
		game.Start(screen)
		Return 0
	End
End

Class TestScreen Extends Screen
	Field logo:GameImage
	Field landscape:Int = True
	
	Method New()
		name = "title"
	End
		
	Method Start:Void()
		logo = game.images.Load("logo.png", "logo", False)
	End
	
	Method Render:Void()
		Cls
		logo.Draw(0,0)
	End
	
	Method ExtraRender:Void()
		Local starty% = 60
		Local height% = 20
		DrawText "Device Width x Height = "+DEVICE_WIDTH+" x "+DEVICE_HEIGHT, 0, DEVICE_HEIGHT - starty
		starty-=height
		DrawText "Virtual Width x Height = "+FormatNumber(SCREEN_WIDTH, 3)+" x "+FormatNumber(SCREEN_HEIGHT,3), 0, DEVICE_HEIGHT - starty
		starty-=height
		DrawText "Press Space to flip between landscape and portrait", 0, DEVICE_HEIGHT - starty
	End
	
	Method Update:Void()
		If KeyHit(KEY_SPACE) Then
			landscape = Not landscape
			If landscape
				SetGraphics(480, 320)
			Else
				SetGraphics(320, 480)
			End
			game.SetScreenSize(960, 640, True)
		End
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(game.exitScreen)
		End
	End
End 