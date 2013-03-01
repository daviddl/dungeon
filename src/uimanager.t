unit

%---------------------------------------------------------------------------
% Author David Delisle Lalancette, Richard Lalancette
% S'occupe d'afficher les nombres sur l'ecran
class UIManager
    import  Tuple2i in "tuple2i.t",
            SpriteSheetManager in "spriteSheetManager.t",
            constants in "constants.t"
    
    export create, destroy, update,
    drawUI, addFloatingObject, addFloatingXYObject,
    removeString, sFloatingObject,
    drawAvatarScore, drawAvatarHealth,
    drawFinalScore
    
    var fontCritFront, fontCritBack, fontNormalFront, fontNormalBack, fontUI,fontUIBold : int % standard font
    var timeToUpdate : int := 10
    var success : boolean
    
    type sFloatingObject :
	record
        value : string              % Texte a afficher
        icon : int                  % Icon to display. Icon comes from spritesheet manager
        flag : int                  % Special flag: Crit, etc...
	    xpos : int                  % position abscisses
	    ypos : int                  % position ordonnees
	    xdpos : int                 % destination abscisses
	    ydpos : int                 % destination ordonnees
        anim : int                  % type d'animation 
        fontStyle : int             % style du font : "Outlined"?
	end record

    var floatingObjects : array 1..30 of sFloatingObject

    %---------------------------------------------------------------------------
    % Creation de fonts
    procedure create()
    
        for i: lower( floatingObjects ) .. upper( floatingObjects )
            floatingObjects( i ).value := ""
        end for
	
        fontCritFront := Font.New ("porky's:24")
        assert fontCritFront > 0
        fontCritBack := Font.New ("porky'sol:24:bold")
        assert fontCritBack > 0
        fontNormalFront := Font.New ("porky's:24")
        assert fontNormalFront > 0
        fontNormalBack := Font.New ("porky'sol:24:bold")
        assert fontNormalBack > 0
        fontUI := Font.New ("constanb:18")
        assert fontUI > 0
        fontUIBold := Font.New ("constanb:18:bold")
        assert fontUIBold > 0
    end create
    
    %---------------------------------------------------------------------------
    % Liberation de cases de donnees des fonts
    procedure destroy()
        for i: lower( floatingObjects ) .. upper( floatingObjects )
            floatingObjects( i ).value := ""
        end for
        Font.Free (fontCritFront)
        Font.Free (fontCritBack)
        Font.Free (fontNormalFront)
        Font.Free (fontNormalBack)
        Font.Free (fontUI)
        Font.Free (fontUIBold)
        
    end destroy
    
     %---------------------------------------------------------------------------
    procedure drawAvatarScore (score : int)
        Font.Draw (intstr(score), 2 * constants.cTilesize + 9, maxy - 3 * constants.cTilesize - 18, fontUIBold, black)
        Font.Draw (intstr(score), 2 * constants.cTilesize + 8, maxy - 3 * constants.cTilesize - 16, fontUI, white)
    end drawAvatarScore
    
    procedure drawAvatarHealth (health : int)
        Font.Draw (intstr(health), 3 * constants.cTilesize - 3, maxy - 2 * constants.cTilesize - 2, fontUIBold, black)
        Font.Draw (intstr(health), 3 * constants.cTilesize - 4, maxy - 2 * constants.cTilesize, fontUI, white)
    end drawAvatarHealth
    
    %---------------------------------------------------------------------------
    % Ajout des chaines de characteres a dessiner a l'ecran
    function addFloatingObject(   xpos : int,                  
                                ypos : int,
                                xdpos : int,                 
                                ydpos : int,                 
                                value : string,
                                flag : int,                  
                                anim : int,                  
                                fontStyle : int ) : int
                                    
        for i: lower( floatingObjects ) .. upper( floatingObjects )
            if( floatingObjects( i ).value ="" ) then
                floatingObjects( i ).value := value
                floatingObjects( i ).icon := 0
                floatingObjects( i ).flag := flag
                floatingObjects( i ).xpos := xpos
                floatingObjects( i ).ypos := ypos
                floatingObjects( i ).xdpos := xdpos
                floatingObjects( i ).ydpos := ydpos
                floatingObjects( i ).anim := anim
                floatingObjects( i ).fontStyle := fontStyle
            result i
            end if
        end for
	result 0
    end addFloatingObject
    
    %---------------------------------------------------------------------------
    % Ajout des chaines de characteres a dessiner a l'ecran
    function addFloatingXYObject( xpos : int,                  
                              ypos : int,
                              value : string ) : int
        
            for i: lower( floatingObjects ) .. upper( floatingObjects )
                if( floatingObjects( i ).value ="" ) then
                    floatingObjects( i ).value := value
                    floatingObjects( i ).icon := 0
                    floatingObjects( i ).flag := 1
                    floatingObjects( i ).xpos := xpos
                    floatingObjects( i ).ypos := ypos
                    floatingObjects( i ).xdpos := xpos
                    floatingObjects( i ).ydpos := ypos + 40
                    floatingObjects( i ).anim := 1
                    floatingObjects( i ).fontStyle := 1
                result i
                end if
            end for
        result 0
    end addFloatingXYObject
    
    
    %---------------------------------------------------------------------------
    % Enleve le texte dans l'espace de la table contenant le texte.
    procedure removeString( stringId : int )
        if( stringId >= lower( floatingObjects ) and  stringId <= upper( floatingObjects )) then
            floatingObjects( stringId ).value := ""
        end if
    end removeString

    %---------------------------------------------------------------------------
    % Mise a jour du texte a afficher, incluant la position
    %---------------------------------------------------------------------------
    procedure update(avatarScore : int, avatarHealth : int)
        timeToUpdate -= 1
        var dx : int
        var dy : int
        if( timeToUpdate <= 0 ) then
            timeToUpdate := 10
            for i: lower( floatingObjects ) .. upper( floatingObjects )
                if( floatingObjects( i ).value not= "" ) then
                    dx := ( floatingObjects( i ).xdpos +  floatingObjects( i ).xpos) div 2
                    dy := ( floatingObjects( i ).ydpos +  floatingObjects( i ).ypos) div 2
                    
                    if( abs( floatingObjects( i ).xdpos - dx ) <= 1  and abs( floatingObjects( i ).ydpos - dy ) <= 1 ) then
                        floatingObjects( i ).value := ""
                    end if
                        
                    floatingObjects( i ).xpos := dx
                    floatingObjects( i ).ypos := dy
                    % floatingObjects( i ).value := intstr( floatingObjects( i ).xdpos - dx ) +":"+intstr(floatingObjects( i ).ydpos - dy)
                end if
            end for
        end if
        drawAvatarScore ( avatarScore )
        drawAvatarHealth ( avatarHealth )
    end update

    %---------------------------------------------------------------------------
    % Dessine le texte a l'ecran ainsi que tout l'interface d'utilisateur
    proc drawUI(cameraPosition : ^Tuple2i)
    
        %var cameraX : int := cameraPosition->x - maxx div 2 
        %var cameraY : int := cameraPosition->y - maxy div 2
    
        for i: lower( floatingObjects ) .. upper( floatingObjects )
            if( floatingObjects( i ).value not= "" ) then
                %Font.Draw (floatingObjects( i ).value, floatingObjects( i ).xpos - cameraX, floatingObjects( i ).ypos - cameraY, fontCritBack, black)
                %Font.Draw (floatingObjects( i ).value, floatingObjects( i ).xpos - cameraX, floatingObjects( i ).ypos - cameraY, fontCritFront, yellow)
                Font.Draw (floatingObjects( i ).value, floatingObjects( i ).xpos, floatingObjects( i ).ypos, fontCritBack, black)
                
                if ( floatingObjects( i ).flag = 1 ) then
                    Font.Draw (floatingObjects( i ).value, floatingObjects( i ).xpos, floatingObjects( i ).ypos, fontCritFront, white)
                elsif ( floatingObjects( i ).flag = 2 ) then
                    Font.Draw (floatingObjects( i ).value, floatingObjects( i ).xpos, floatingObjects( i ).ypos, fontCritFront, brightred)
                else
                    Font.Draw (floatingObjects( i ).value, floatingObjects( i ).xpos, floatingObjects( i ).ypos, fontCritFront, white)
                end if
                % This won't work for some reason...Pic.Draw ( SpriteSheetManager.tileset( 32 ), floatingObjects( i ).xpos - constants.cTilesize*2, floatingObjects( i ).ypos, picCopy )
            end if
        end for
    end drawUI
    
    proc drawFinalScore( finalScore : int, state : string )
    if state = "dead" then
        Font.Draw ( "Tu est mort...", maxx div 2 - 250, maxy div 2 + 100, fontCritFront, white)
    elsif state = "alive" then
        Font.Draw ( "Tu est vainceur!", maxx div 2 - 250, maxy div 2 + 100, fontCritFront, white)        
    end if
    Font.Draw ( "Ton pointage final est: " + intstr (finalScore), maxx div 2 - 250, maxy div 2, fontCritFront, white)  
    
    end drawFinalScore
    
end UIManager
