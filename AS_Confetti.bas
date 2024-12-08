﻿B4i=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.45
@EndOfDesignText@
#If Documentation
Updates
V1.00
	-Release
#End If

#DesignerProperty: Key: BackgroundColor, DisplayName: Background Color, FieldType: Color, DefaultValue: 0x00FFFFFF, Description: Default is transparent
#DesignerProperty: Key: ParticleCount, DisplayName: ParticleCount, FieldType: Int, DefaultValue: 100, MinRange: 1
#DesignerProperty: Key: Gravity, DisplayName: Gravity, FieldType: String, DefaultValue: 0.2, Description: The value determines how fast an object accelerates when falling. The Default Value is 0.2 
#DesignerProperty: Key: SemiTransparentShapes, DisplayName: SemiTransparentShapes, FieldType: Boolean, DefaultValue: False, Description: The alpha value is determined randomly
#DesignerProperty: Key: CircleParticle, DisplayName: CircleParticle, FieldType: Boolean, DefaultValue: True
#DesignerProperty: Key: RectangleParticle, DisplayName: RectangleParticle, FieldType: Boolean, DefaultValue: True
#DesignerProperty: Key: StarParticle, DisplayName: StarParticle, FieldType: Boolean, DefaultValue: True
#DesignerProperty: Key: TriangleParticle, DisplayName: TriangleParticle, FieldType: Boolean, DefaultValue: False
#DesignerProperty: Key: HexagonParticle, DisplayName: HexagonParticle, FieldType: Boolean, DefaultValue: True
#DesignerProperty: Key: LightningParticle, DisplayName: LightningParticle, FieldType: Boolean, DefaultValue: False, Description: A zigzag shape can have a dynamic effect and brings movement into play

Sub Class_Globals
	Type AS_Confetti_Item (X As Float, Y As Float, VelocityX As Float, VelocityY As Float, Size As Float, Color As Int,Alpha As Int,ParticleType As String)
    
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Public mBase As B4XView
	Private xui As XUI 'ignore
	Public Tag As Object
    
	Private lstConfettiSets As List ' Liste für alle Konfetti-Sets
	Private xCanvas As B4XCanvas
	Private tmrMain As Timer
	Private lstParticleTypes As List
	Private lstColors As List
    
	Private m_BackgroundColor As Int
	Private m_ParticleCount As Int
	Private m_Gravity As Double
	Private m_SemiTransparentShapes As Boolean
	Private m_CircleParticle As Boolean
	Private m_RectangleParticle As Boolean
	Private m_StarParticle As Boolean
	Private m_TriangleParticle As Boolean
	Private m_HexagonParticle As Boolean
	Private m_LightningParticle As Boolean
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
	lstConfettiSets.Initialize
	lstParticleTypes.Initialize
	lstColors.Initialize
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
	Tag = mBase.Tag
	mBase.Tag = Me

	IniProps(Props)

	mBase.Color = m_BackgroundColor
	xCanvas.Initialize(mBase)
	tmrMain.Initialize("tmrMain", 16) ' ~60 FPS

	CreateParticleTypeList

	lstColors.Add(xui.Color_ARGB(255, 49, 208, 89))
	lstColors.Add(xui.Color_ARGB(255, 25, 29, 31))
	lstColors.Add(xui.Color_ARGB(255, 9, 131, 254))
	lstColors.Add(xui.Color_ARGB(255, 255, 159, 10))
	lstColors.Add(xui.Color_ARGB(255, 45, 136, 121))
	lstColors.Add(xui.Color_ARGB(255, 73, 98, 164))
	lstColors.Add(xui.Color_ARGB(255, 221, 95, 96))
	lstColors.Add(xui.Color_ARGB(255, 141, 68, 173))
	lstColors.Add(xui.Color_Magenta)
	lstColors.Add(xui.Color_Cyan)

    #If B4A
    Base_Resize(mBase.Width,mBase.Height)
    #End If
End Sub

Private Sub IniProps(Props As Map)
	m_BackgroundColor = xui.PaintOrColorToColor(Props.GetDefault("BackgroundColor", xui.Color_Transparent))
	m_ParticleCount = Props.GetDefault("ParticleCount",100)
	m_Gravity = Props.GetDefault("Gravity",0.2)
	m_SemiTransparentShapes = Props.GetDefault("SemiTransparentShapes",False)
	m_CircleParticle = Props.GetDefault("CircleParticle",True)
	m_RectangleParticle = Props.GetDefault("RectangleParticle",True)
	m_StarParticle = Props.GetDefault("StarParticle",True)
	m_TriangleParticle = Props.GetDefault("TriangleParticle",False)
	m_HexagonParticle = Props.GetDefault("HexagonParticle",True)
	m_LightningParticle = Props.GetDefault("LightningParticle",False)
End Sub

Private Sub CreateParticleTypeList
	lstParticleTypes.Clear
	If m_CircleParticle Then lstParticleTypes.Add("Circle")
	If m_RectangleParticle Then lstParticleTypes.Add("Rectangle") ' Neues Rechteck hinzufügen
	If m_StarParticle Then lstParticleTypes.Add("Star") ' Neuer Stern hinzufügen
	If m_TriangleParticle Then lstParticleTypes.Add("Triangle")
	If m_HexagonParticle Then lstParticleTypes.Add("Hexagon")
	If m_LightningParticle Then lstParticleTypes.Add("Lightning")
End Sub

Public Sub Base_Resize (Width As Double, Height As Double)
	mBase.SetLayoutAnimated(0, mBase.Left, mBase.Top, Width, Height)
	xCanvas.Resize(Width, Height)
End Sub

Public Sub GenerateConfetti
	Dim lstConfetti As List
	lstConfetti.Initialize
	For i = 1 To m_ParticleCount
		Dim Item As AS_Confetti_Item
		Item.Initialize
		lstConfetti.Add(UpdateItem(Item))
	Next
	lstConfettiSets.Add(lstConfetti)
	If Not(tmrMain.Enabled) Then tmrMain.Enabled = True ' Timer aktivieren, falls deaktiviert
End Sub

Private Sub UpdateItem(Item As AS_Confetti_Item) As AS_Confetti_Item
	Item.X = Rnd(0, mBase.Width)
	Item.Y = Rnd(-100dip, 0) ' Startpunkt etwas über dem Bildschirm
	Item.VelocityX = Rnd(-2, 3) ' Zufällige horizontale Bewegung
	Item.VelocityY = Rnd(3, 8) ' Zufällige vertikale Geschwindigkeit
	Item.Size = Rnd(5, 15) ' Größe des Partikels
	Item.Color = lstColors.Get(Rnd(0, lstColors.Size))
	Item.Alpha = IIf(m_SemiTransparentShapes,Rnd(30, 256),255)
	
	Select lstParticleTypes.Get(Rnd(0,lstParticleTypes.size))
		Case "Circle"
			Item.ParticleType = "Circle"
		Case "Rectangle"
			Item.ParticleType = "Rectangle"
		Case "Star"
			Item.ParticleType = "Star"
		Case "Triangle"
			Item.ParticleType = "Triangle"
		Case "Hexagon"
			Item.ParticleType = "Hexagon"
		Case "Lightning"
			Item.ParticleType = "Lightning"
	End Select
	
	Return Item
End Sub

Private Sub tmrMain_Tick
	xCanvas.ClearRect(xCanvas.TargetRect) ' Canvas löschen
    
	Dim ActiveSets As Int = 0 ' Zähler für aktive Sets
	Dim SetsToRemove As List
	SetsToRemove.Initialize

	For Each lstConfetti As List In lstConfettiSets
		Dim AllAtBottom As Boolean = True ' Annahme: Alle Partikel dieses Sets sind am Boden

		For Each Item As AS_Confetti_Item In lstConfetti
			' Aktualisiere die Position
			Item.X = Item.X + Item.VelocityX
			Item.Y = Item.Y + Item.VelocityY

			'Item.Alpha = Max(0, Item.Alpha - 5) ' Alpha-Wert verringern (langsames Verblassen)

			' Füge Schwerkraft hinzu
			Item.VelocityY = Item.VelocityY + m_Gravity

			Dim Color() As Int = GetARGB(Item.Color)

			Select Item.ParticleType
				Case "Circle"
					xCanvas.DrawCircle(Item.X, Item.Y, Item.Size, xui.Color_ARGB(Item.Alpha,Color(1),Color(2),Color(3)), True, 2dip)
				Case "Rectangle"
					Dim xRect As B4XRect
					xRect.Initialize(Item.X, Item.Y,Item.X + Item.Size,Item.Y + Item.Size)
					xCanvas.DrawRect(xRect, xui.Color_ARGB(Item.Alpha,Color(1),Color(2),Color(3)), True, 2dip)
				Case "Star"
					'Stern mit benutzerdefinierter Logik zeichnen
					DrawStar(Item.X, Item.Y, Item.Size, xui.Color_ARGB(Item.Alpha,Color(1),Color(2),Color(3)))
				Case "Triangle"
					DrawTriangle(Item.X, Item.Y, Item.Size, xui.Color_ARGB(Item.Alpha,Color(1),Color(2),Color(3)))
				Case "Hexagon"
					DrawHexagon(Item.X, Item.Y, Item.Size, xui.Color_ARGB(Item.Alpha,Color(1),Color(2),Color(3)))
				Case "Lightning"
					DrawLightning(Item.X, Item.Y, Item.Size, xui.Color_ARGB(Item.Alpha,Color(1),Color(2),Color(3)))
			End Select


			' Wenn das Partikel den Bildschirm verlässt, neu positionieren
			If Item.Y <= mBase.Height Then
				AllAtBottom = False
			End If
		Next

		' Wenn nicht alle am Boden sind, wird das Set als aktiv gezählt
		If AllAtBottom Then
			SetsToRemove.Add(lstConfetti)
		Else
			ActiveSets = ActiveSets + 1
		End If
	Next

	' Entfernen der markierten Sets
	For Each SetToRemove As List In SetsToRemove
		lstConfettiSets.RemoveAt(lstConfettiSets.IndexOf(SetToRemove))
	Next

	xCanvas.Invalidate ' Änderungen anzeigen

	' Timer stoppen, wenn keine aktiven Sets mehr vorhanden sind
	If ActiveSets = 0 Then
		StopEffect
	End If
End Sub


Private Sub DrawLightning(X As Float, Y As Float, Size As Float, Color As Int)
	Dim Path As B4XPath
	Path.Initialize(X, Y - Size / 2) ' Startpunkt oben

	' Zickzack zeichnen
	Path.LineTo(X + Size / 4, Y)
	Path.LineTo(X, Y + Size / 2)
	Path.LineTo(X - Size / 4, Y)
	Path.LineTo(X, Y - Size / 2)

	xCanvas.DrawPath(Path, Color, True, 2dip)
End Sub

Private Sub DrawHexagon(X As Float, Y As Float, Size As Float, Color As Int)
	Dim Path As B4XPath
	Dim Points As Int = 6
	Dim AngleStep As Float = 360 / Points
	Dim StartAngle As Float = -90 ' Startwinkel

	' Berechnung des Startpunkts
	Dim Angle As Float = StartAngle
	Dim StartX As Float = X + CosD(Angle) * Size
	Dim StartY As Float = Y + SinD(Angle) * Size
	Path.Initialize(StartX, StartY)

	' Hexagon zeichnen
	For i = 1 To Points
		Angle = Angle + AngleStep
		Dim Px As Float = X + CosD(Angle) * Size
		Dim Py As Float = Y + SinD(Angle) * Size
		Path.LineTo(Px, Py)
	Next

	' Schließen des Pfads
	Path.LineTo(StartX, StartY)

	xCanvas.DrawPath(Path, Color, True, 2dip)
End Sub


Private Sub DrawTriangle(X As Float, Y As Float, Size As Float, Color As Int)
	Dim Path As B4XPath
	Dim HalfSize As Float = Size / 2

	' Spitze oben
	Path.Initialize(X, Y - Size)
	' Linke Ecke
	Path.LineTo(X - HalfSize, Y + HalfSize)
	' Rechte Ecke
	Path.LineTo(X + HalfSize, Y + HalfSize)
	' Zurück zur Spitze
	Path.LineTo(X, Y - Size)

	xCanvas.DrawPath(Path, Color, True, 2dip)
End Sub


Private Sub DrawStar(X As Float, Y As Float, Size As Float, Color As Int)
	Dim Path As B4XPath
	Dim StartAngle As Float = -90 ' Startwinkel in Grad (oben)
	Dim Points As Int = 5 ' Anzahl der Sternspitzen
	Dim InnerRadius As Float = Size / 2 ' Innerer Radius des Sterns
	Dim OuterRadius As Float = Size ' Äußerer Radius des Sterns
	Dim AngleStep As Float = 360 / (Points * 2) ' Winkel zwischen den Punkten

	' Berechnung des Startpunkts
	Dim Angle As Float = StartAngle
	Dim StartX As Float = X + CosD(Angle) * OuterRadius
	Dim StartY As Float = Y + SinD(Angle) * OuterRadius
	Path.Initialize(StartX, StartY)

	' Schleife zum Zeichnen der Sternpunkte
	For i = 1 To Points * 2
		' Wechsel zwischen äußerem und innerem Radius
		Dim Radius As Float
		If i Mod 2 = 1 Then
			Radius = InnerRadius
		Else
			Radius = OuterRadius
		End If

		Angle = Angle + AngleStep
		Dim Px As Float = X + CosD(Angle) * Radius
		Dim Py As Float = Y + SinD(Angle) * Radius
		Path.LineTo(Px, Py)
	Next

	' Zurück zum Startpunkt, um den Pfad zu schließen
	Path.LineTo(StartX, StartY)

	' Stern zeichnen
	xCanvas.DrawPath(Path, Color, True, 2dip)
End Sub




Private Sub StopEffect
	tmrMain.Enabled = False
End Sub


#Region Properties

Public Sub setBackgroundColor(BackgroundColor As Int)
	m_BackgroundColor = BackgroundColor
End Sub

Public Sub getBackgroundColor As Int
	Return m_BackgroundColor
End Sub

Public Sub setCircleParticle(CircleParticle As Boolean)
	m_CircleParticle = CircleParticle
End Sub

Public Sub getCircleParticle As Boolean
	Return m_CircleParticle
End Sub

Public Sub setRectangleParticle(RectangleParticle As Boolean)
	m_RectangleParticle = RectangleParticle
End Sub

Public Sub getRectangleParticle As Boolean
	Return m_RectangleParticle
End Sub

Public Sub setStarParticle(StarParticle As Boolean)
	m_StarParticle = StarParticle
End Sub

Public Sub getStarParticle As Boolean
	Return m_StarParticle
End Sub

Public Sub setTriangleParticle(TriangleParticle As Boolean)
	m_TriangleParticle = TriangleParticle
End Sub

Public Sub getTriangleParticle As Boolean
	Return m_TriangleParticle
End Sub

Public Sub setHexagonParticle(HexagonParticle As Boolean)
	m_HexagonParticle = HexagonParticle
End Sub

Public Sub getHexagonParticle As Boolean
	Return m_HexagonParticle
End Sub

'A zigzag shape can have a dynamic effect and brings movement into play
Public Sub setLightningParticle(LightningParticle As Boolean)
	m_LightningParticle = LightningParticle
End Sub

Public Sub getLightningParticle() As Boolean
	Return m_LightningParticle
End Sub

'The alpha value is determined randomly
Public Sub setSemiTransparentShapes(SemiTransparentShapes As Boolean)
	m_SemiTransparentShapes = SemiTransparentShapes
End Sub

Public Sub getSemiTransparentShapes As Boolean
	Return m_SemiTransparentShapes
End Sub

'The value determines how fast an object accelerates when falling
'Default: 0.2 
Public Sub setGravity(GravityValue As Double)
	m_Gravity = GravityValue
End Sub

Public Sub getGravity As Double
	Return m_Gravity
End Sub

'<code>
'	Dim lst_Colors As List
'	lst_Colors.Initialize
'	lst_Colors.Add(xui.Color_ARGB(255, 49, 208, 89))
'	lst_Colors.Add(xui.Color_ARGB(255, 25, 29, 31))
'	lst_Colors.Add(xui.Color_ARGB(255, 9, 131, 254))
'	lst_Colors.Add(xui.Color_ARGB(255, 255, 159, 10))
'	lst_Colors.Add(xui.Color_ARGB(255, 45, 136, 121))
'	lst_Colors.Add(xui.Color_ARGB(255, 73, 98, 164))
'	lst_Colors.Add(xui.Color_ARGB(255, 221, 95, 96))
'	lst_Colors.Add(xui.Color_ARGB(255, 141, 68, 173))
'	lst_Colors.Add(xui.Color_Magenta)
'	lst_Colors.Add(xui.Color_Cyan)
'	AS_Confetti1.SetColors(lst_Colors)
'</code>
Public Sub SetColors(ColorList As List)
	lstColors = ColorList
End Sub

Public Sub getParticleCount As Int
	Return m_ParticleCount
End Sub

Public Sub setParticleCount(ParticleCount As Int)
	m_ParticleCount = ParticleCount
End Sub
#End Region

#Region Functions

Private Sub GetARGB(Color As Int) As Int()
	Dim res(4) As Int
	res(0) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff000000), 24)
	res(1) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff0000), 16)
	res(2) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff00), 8)
	res(3) = Bit.And(Color, 0xff)
	Return res
End Sub

#End Region