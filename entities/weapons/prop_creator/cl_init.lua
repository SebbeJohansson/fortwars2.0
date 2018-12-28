 include ("shared.lua")
 
 -- Below is Code for the scrolling text on the toolguns screen.  Grabbed from cl_viewscreen.lua
local matScreen   = Material( "models/weapons/v_toolgun/screen" )
local txidScreen  = surface.GetTextureID( "models/weapons/v_toolgun/screen" )
local txRotating  = surface.GetTextureID( "pp/fb" )
local txBackground  = surface.GetTextureID( "models/weapons/v_toolgun/screen_bg" )

-- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local RTTexture   = GetRenderTarget( "GModToolgunScreen", 256, 256 )


surface.CreateFont( "GModToolScreen", {
	font = "Arial Black",
	extended = false,
	size = 82,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local function DrawScrollingText( text, y, texwide )
  local w, h = surface.GetTextSize( text  )
  w = w + 64
  local x = math.fmod( CurTime() * 200, w ) * -1;
  
  while ( x < texwide ) do
    surface.SetTextColor( 0, 0, 0, 255 )
    surface.SetTextPos( x + 3, y + 3 )
    surface.DrawText( text )
    surface.SetTextColor( 255, 255, 255, 255 )
    surface.SetTextPos( x, y )
    surface.DrawText( text )
    x = x + w
  end
end

/*---------------------------------------------------------
  We use this opportunity to draw to the toolmode 
    screen's rendertarget texture.
---------------------------------------------------------*/
function SWEP:RenderScreen()
  local TEX_SIZE = 256
  local name   = self.Owner:GetNWString("PropName")
  local NewRT = RTTexture
  local oldW = ScrW()
  local oldH = ScrH()
  
  -- Set the material of the screen to our render target
  matScreen:SetTexture( "$basetexture", NewRT )
  
  local OldRT = render.GetRenderTarget();
  
  -- Set up our view for drawing to the texture
  render.Clear(0,0,0,255)
  render.SetRenderTarget( NewRT )
  render.SetViewPort( 0, 0, TEX_SIZE, TEX_SIZE )
  cam.Start2D()
  
  -- Background
  surface.SetDrawColor( 255, 255, 255, 255 )
  surface.SetTexture( txBackground )
  surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )

  surface.SetFont( "GModToolScreen" )
  DrawScrollingText( name, 64, TEX_SIZE )

  cam.End2D()
  render.SetRenderTarget( OldRT )
  render.SetViewPort( 0, 0, oldW, oldH )
end