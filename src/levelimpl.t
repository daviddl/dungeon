% Authors:  David Delisle-Lalancette
unit
class LevelImpl
    implement Level in "level.t"
    import  xml in "xml.t", 
            Layer in "layer.t", 
            ErrorHelper in "errorhelper.t", 
            constants in "constants.t", 
            Trigger in "trigger.t",
            MonsterObject in "monsterobject.t", 
            SoundManager in "soundmanager.t",
            Tuple2i in "tuple2i.t",
            Mobile in "mobile.t",
            Monster in "monster.t",
            SpriteSheetManager in "spritesheetmanager.t",
            Avatar in "avatar.t",
            Camera in "camera.t"
            
    var width : int := 0
    var height : int := 0
    var font1 := Font.New ("serif:14")
    
    var triggers : flexible array 0 .. -1 of ^ Trigger
    var monsterObjects : flexible array 0 .. -1 of ^ MonsterObject
    var spawnedMonsters : flexible array 0 .. -1 of ^ Mobile
    var tilePropertyObjects : array 0 .. 639 of ^ TilePropertyObject
    var avatar : ^ Mobile := nil
    var uiManager : ^ UIManager
    var camPos : ^ Tuple2i
    var camera : ^ Camera
    
    %---------------------------------------------------------------------------
    % authors: Richard Lalancette
    body procedure create()
	    fork SoundManager.ambience( constants.sfxAmbienceForestHighDay )
        for i : 0 .. upper( tilePropertyObjects )
            tilePropertyObjects( i ) := nil
        end for
        gameMessage := ""
        new Avatar, avatar
        new Camera, camera
        camera->create(0,0)

    end create
    
    %---------------------------------------------------------------------------
    % authors: Richard Lalancette
    body procedure destroy()
    
        if( camera not= nil ) then
            camera->destroy()
            free Camera, camera
            camera := nil
        end if
    
        if( avatar not= nil ) then
            avatar->destroy()
            free Avatar, avatar
            avatar := nil
        end if
        
        for i : cFirstLayer .. cLastLayer
            layers(i) -> destroy()
            free Layer, layers(i)
            layers(i) := nil
        end for

        for i : 0 .. upper( triggers )
            if( triggers( i ) not= nil ) then
                free triggers( i )
                triggers( i ) := nil
            end if
        end for
        new triggers, -1
        
        for i : 0 .. upper( monsterObjects )
            if( monsterObjects( i ) not= nil ) then
                free monsterObjects( i )
                monsterObjects( i ) := nil
            end if
        end for
        new monsterObjects, -1

        for i : 0 .. upper( spawnedMonsters )
            if( spawnedMonsters( i ) not= nil ) then
                spawnedMonsters( i )->destroy()
                free spawnedMonsters( i )
                spawnedMonsters( i ) := nil
            end if
        end for
        new spawnedMonsters, -1

        for i : 0 .. upper( tilePropertyObjects )
            %Font.Draw ( tilePropertyObjects( i )->toString(), 50, 230, font1, white)
           if( tilePropertyObjects( i ) not= nil ) then
               free tilePropertyObjects( i )
               tilePropertyObjects( i ) := nil
           end if
        end for
    end destroy
    
    %---------------------------------------------------------------------------
    % authors: Richard Lalancette
    body procedure update()
        for i : 0 .. upper (spawnedMonsters)
            if( spawnedMonsters(i) not= nil ) then
                spawnedMonsters(i)->update()
                
            end if
        end for
        avatar -> update()
        avatar -> checkTriggers()
        camera -> update()
        
    end update

    %---------------------------------------------------------------------------
    % authors: Richard Lalancette
    body procedure spawnMonster( monsterObject : ^ MonsterObject )
        var monster : ^ Monster
        var pmonster : ^ Monster := nil
        new Monster, monster
        var gid : int := monsterObject->getGid()
        
        monster -> create( monsterObject->getX(), monsterObject->getY() ) % TODO finish this
        monster -> loadObjectGid( gid, tilePropertyObjects( gid-1 ) )
        monster -> setLevel(self)
        
        new spawnedMonsters, upper( spawnedMonsters ) + 1
        spawnedMonsters( upper( spawnedMonsters ) ) := monster
    end spawnMonster
    
    %---------------------------------------------------------------------------
    body function isInsideLevel( tileX : int, tileY : int ) : boolean
        result tileX >= 0 and tileY >= 0 and tileX < width and tileY < height
    end isInsideLevel

    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    %           David Delisle-Lalancette
    body function createNewLevel( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        var lastIndex : int := xml.findLine( levelData, "<map ", 0 )
        var levelPropertyWidth : string := ""
        var levelPropertyHeight : string := ""
        
        if( lastIndex >= 0 ) then
            levelPropertyWidth := xml.findProperty( levelData, "width", lastIndex )
            levelPropertyHeight := xml.findProperty( levelData, "height", lastIndex )
            width := strint( levelPropertyWidth )
            height := strint( levelPropertyHeight )
        
            for i : cFirstLayer .. cLastLayer
                new Layer, layers(i)
                layers(i) -> create(width,height)
            end for    
        else
            % error
            success := false
        end if
        
        result success
    end createNewLevel

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body function prepareFloorLayer( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        layers(cFloorLayer) -> loadTiles ( levelData, "floor" , width, height )
        result success
    end prepareFloorLayer

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body function prepareWallLayer( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        layers(cWallLayer) -> loadTiles ( levelData, "walls", width, height )
        result success
    end prepareWallLayer

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body function prepareFurnitureLayer( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        layers(cFurnitureLayer) -> loadTiles ( levelData, "furniture", width, height )
        result success
    end prepareFurnitureLayer

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body function prepareDecorationLayer( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        layers(cDecorationLayer) -> loadTiles ( levelData, "decoration", width, height )
        result success
    end prepareDecorationLayer

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body function preparePickableLayer( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        layers(cPickableLayer) -> loadTiles ( levelData, "pickable", width, height )
        result success
    end preparePickableLayer

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body function prepareInteractedLayer( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        layers(cInteractedLayer) -> loadTiles ( levelData, "interacted", width, height )
        result success
    end prepareInteractedLayer

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body function prepareInteractableLayer( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        layers(cInteractableLayer) -> loadTiles ( levelData, "interactable", width, height )
        result success
    end prepareInteractableLayer
    
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body function prepareUILayer( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        layers(cUILayer) -> loadTiles ( levelData, "ui", width, height )
        result success
    end prepareUILayer
    
    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    body function prepareMonsterGroup( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        
        var lastIndex : int := xml.findLine( levelData, '<objectgroup name="monsters', 0 )
        var oneMonsterObject : string := ""
        var gidValue : string := ""
        var xValue : string := ""
        var yValue : string := ""
        var gid : int := 0
        var x : int := 0
        var y : int := 0
        var foundEndOfObjectList : boolean := false
        var monsterObject : ^ MonsterObject := nil
        
        if( lastIndex = -1 ) then
            result true % no monster group found
        end if
        
        lastIndex += 1 % get to the next line where our object list starts
        
        if( lastIndex > 0 ) then
            loop
            oneMonsterObject := levelData( lastIndex )
            
            if( index( oneMonsterObject, '</objectgroup>' ) > 0 ) then
                foundEndOfObjectList := true
            end if
            
            exit when foundEndOfObjectList = true
            
            gidValue := xml.findProperty( levelData, "gid", lastIndex )
            xValue := xml.findProperty( levelData, "x", lastIndex )
            yValue := xml.findProperty( levelData, "y", lastIndex )
            
            gid := strint( gidValue )
            x := strint( xValue )
            y := height * 32 - strint( yValue )
            
            new MonsterObject, monsterObject
            monsterObject->create( "name", "no type", gid, x, y )
            
            new monsterObjects, upper( monsterObjects ) + 1
            monsterObjects( upper( monsterObjects ) ) := monsterObject
            
            spawnMonster(monsterObject)
            
            lastIndex += 1 % next line...
            end loop
        end if

        result success
    end prepareMonsterGroup

    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    body function prepareTriggerGroup( levelData : array 0 .. * of string) : boolean
        var success : boolean := true
        
        var lastIndex : int := xml.findLine( levelData, '<objectgroup name="triggers', 0 )
        var oneTriggerObject : string := ""
        var gidValue : string := ""
        var xValue : string := ""
        var yValue : string := ""
        var gid : int := 0
        var x : int := 0
        var y : int := 0
        var triggerType : string := ""
        var foundEndOfObjectList : boolean := false
        var trigger : ^ Trigger := nil
        
        if( lastIndex = -1 ) then
            result true % no trigger group found
        end if
        
        lastIndex += 1 % get to the next line where our object list starts
        
        if( lastIndex > 0 ) then
            loop
            oneTriggerObject := levelData( lastIndex )
            
            if( index( oneTriggerObject, '</objectgroup>' ) > 0 ) then
                foundEndOfObjectList := true
            end if
            
            exit when foundEndOfObjectList = true
            
            gidValue := xml.findProperty( levelData, "gid", lastIndex )
            xValue := xml.findProperty( levelData, "x", lastIndex )
            yValue := xml.findProperty( levelData, "y", lastIndex )
            triggerType := xml.findProperty( levelData, "type", lastIndex )
            
            gid := strint( gidValue )
            x := strint( xValue )
            y := height * 32 - strint( yValue )
            
            % createTrigger here
            new Trigger, trigger
            trigger->create( gid, x, y, triggerType )
            
            new triggers, upper( triggers ) + 1
            triggers( upper( triggers ) ) := trigger
            
            lastIndex += 1 % next line...
            end loop
        end if

        result success
    end prepareTriggerGroup

    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    body function prepareTileProperties( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        
        var lastIndex : int := xml.findLine( levelData, '<tileset ', 0 )
        var nextLine : string := ""
        var oneProperty : string := ""
        var idValue : string := "" % not Gid. No need to substract firstgid
        var name : string := ""
        var value : string := ""
        var id : int := 0 % not Gid. No need to substract firstgid
        var foundEndOfObjectList : boolean := false
        var foundEndOfPropertyList : boolean := false
        var tilePropertyObject : ^ TilePropertyObject := nil
        
        if( lastIndex = -1 ) then
            result true % no tileset properties found
        end if

        lastIndex += 1
        
        if( lastIndex > 0 ) then
            
            loop % all tiles
                lastIndex := xml.findLine( levelData, '<tile ', lastIndex )
                
                if( lastIndex = -1 ) then
                    foundEndOfObjectList := true
                end if
                exit when foundEndOfObjectList = true
                
                idValue := xml.findProperty( levelData, "id", lastIndex )
                id := strint( idValue )
                
                lastIndex += 1
                nextLine := levelData( lastIndex )
                
                if( index( nextLine, '<properties>' ) > 0 ) then
                
                    new TilePropertyObject, tilePropertyObject
                    tilePropertyObject->create()
                    
                    foundEndOfPropertyList := false
                    loop % all property
                        lastIndex += 1
                        nextLine := levelData( lastIndex )
                        
                        foundEndOfPropertyList := ( index( nextLine, '</properties>' ) > 0 )
                        
                        exit when foundEndOfPropertyList = true
                        
                        if( index( nextLine, '<property ' ) > 0 ) then
                        
                            name := xml.findProperty( levelData, "name", lastIndex )
                            value := xml.findProperty( levelData, "value", lastIndex )
                            
                            if( name ='name' ) then
                                tilePropertyObject->setName( value )
                            elsif ( name = 'firstcell' ) then
                                tilePropertyObject->setFirstCell( value )
                            elsif ( name = 'sheet' ) then
                                tilePropertyObject->setSheet( value )
                            end if
                        end if
                    end loop

                    tilePropertyObjects( id ) := tilePropertyObject
                    
                    lastIndex += 1
                end if
            end loop
        end if

        result success
    end prepareTileProperties

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body procedure updateWalkableLayer
        for k: 0 .. height - 1
            for j: 0 .. width - 1
                if  layers(cWallLayer)-> tiles(j,k) = 0 and 
                    layers(cFurnitureLayer)-> tiles(j,k) = 0 and 
                    layers(cInteractableLayer)-> tiles(j,k) = 0 and
                    layers(cInteractedLayer)-> tiles(j,k) = 0 then
                    layers(cWalkableLayer)-> tiles(j,k) := 0 % La tuile peut etre traversee
                else
                layers(cWalkableLayer)-> tiles(j,k) := 1 %  La tuile ne peut pas etre traversee
                end if
            end for
        end for
            
	end updateWalkableLayer
    
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body procedure updateWalkableTile (targetTileX : int , targetTileY : int )
        if  layers(Level.cWallLayer)-> tiles(targetTileX,targetTileY) = 0 and 
            layers(Level.cFurnitureLayer)-> tiles(targetTileX,targetTileY) = 0 and 
            layers(Level.cInteractableLayer)-> tiles(targetTileX,targetTileY) = 0 and 
            layers(Level.cInteractedLayer)-> tiles(targetTileX,targetTileY) = 0 then
            layers(Level.cWalkableLayer)-> tiles(targetTileX,targetTileY) := constants.cWalkable % La tuile peut etre traversee
        else
            layers(Level.cWalkableLayer)-> tiles(targetTileX,targetTileY) := constants.cNotWalkable %  La tuile ne peut pas etre traversee
        end if
    end updateWalkableTile

    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    procedure prepareAvatar()
        avatar->create(320,384)
        avatar -> setLevel(self)
        avatar -> loadObjectGid( SpriteSheetManager.monsterShadowSoldier, getTilePropertyObject( SpriteSheetManager.monsterShadowSoldier ) )
    end prepareAvatar
    
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    body function prepareLevel( levelData : array 0 .. * of string ) : boolean
        var success : boolean := true
        
        success := createNewLevel( levelData )
        if( not success ) then
            ErrorHelper.displayError("Problem creating new level")
        end if
        
        success := prepareTileProperties( levelData )
        assert success
        if( not success ) then
            ErrorHelper.displayError("Problem loading tileset tile properties")
        end if
        
        success := prepareFloorLayer( levelData )
        assert success
        if( not success ) then
            ErrorHelper.displayError("Problem creating floor layer")
        end if
        
        success := prepareWallLayer( levelData )
        assert success
        if( not success ) then
            ErrorHelper.displayError("Problem creating wall layer")
        end if
        
        success := prepareFurnitureLayer( levelData )
        assert success
        if( not success ) then
            ErrorHelper.displayError("Problem creating furniture Layer")
        end if
        
        success := prepareDecorationLayer( levelData )
        assert success
        if( not success ) then
            ErrorHelper.displayError("Problem creating decoration Layer")
        end if

        success := preparePickableLayer( levelData )
        assert success
        if( not success ) then
            ErrorHelper.displayError("Problem creating pickable Layer")
        end if
        
        success := prepareInteractedLayer( levelData )
        assert success
        if( not success ) then
            ErrorHelper.displayError("Problem creating Interacted Layer")
        end if

        success := prepareInteractableLayer( levelData )
        assert success
        if( not success ) then
            ErrorHelper.displayError("Problem creating Interactable Layer")
        end if
        
        success := prepareUILayer( levelData )
        assert success
        if( not success ) then
            ErrorHelper.displayError("Problem creating Interactable Layer")
        end if

        success := prepareMonsterGroup( levelData )
        if( not success ) then
           ErrorHelper.displayError("Problem loading monsters")
        end if
        
        success := prepareTriggerGroup( levelData )
        assert success
        if( not success ) then
           ErrorHelper.displayError("Problem loading triggers")
        end if
        
        updateWalkableLayer()
        
        prepareAvatar()
        
        camera -> setTarget( avatar )
        
        result success
    end prepareLevel
    
    %---------------------------------------------------------------------------
    % Note: Si un fichier TMX a une ligne contenant plus de 255 characteres, 
    % cette function risk fortement de ne pas fonctinonner. RL.
    %
    % Authors:  David Delisle-Lalancette
    body function loadLevel( tilesetName: string, level : string ) : boolean
        var success : boolean := true
        
        SpriteSheetManager.loadTilesetFromXY(tilesetName)

        %Placer les tuiles en les prenant du array "Tileset" si la fonction "PNG" n'est pas prete.
        var levelData : flexible array 0 .. 1 of string
        var levelFile : int 
        var levelText, allText : string
        open : levelFile, "../res/levels/" + level + ".tmx", get
        var line : string
        var counter : int := 0
        
        loop
            exit when eof (levelFile)  % Il-y-a t'il plus de characteres?
            get : levelFile, levelData(counter) : *
            counter += 1
            if counter >= upper (levelData) then
            %Si, au besion, nous pouvons augmenter la taille du tableau.
            new levelData, upper (levelData) + 250
            end if
        end loop
        
        close : levelFile
        new levelData, counter % tidy up
        
        success := prepareLevel( levelData )
        
        if( not success ) then
            ErrorHelper.displayError("Problem loading level")
        end if
        
        result success
    end loadLevel

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    %           Richard Lalancette
    body procedure drawLevel()
    
        % TODO remove this and give camera to the level with another way.
        camPos := camera->getPosition()
        
        %Dessiner le niveau en placant les tuiles et objets a leur place
        %Ceci utilise la valeur pic (array qui contient les tuiles) defini dans loadTileset/loadJPEGIntoArray
        
        var floorLayerTiles : array 0 .. constants.cMaxLayerSize, 0.. constants.cMaxLayerSize of int
        floorLayerTiles := layers(cFloorLayer)->getTiles()
        
        var wallLayerTiles : array 0 .. constants.cMaxLayerSize, 0.. constants.cMaxLayerSize of int
        wallLayerTiles := layers(cWallLayer)->getTiles()
        
        var furnitureLayerTiles : array 0 .. constants.cMaxLayerSize, 0.. constants.cMaxLayerSize of int
        furnitureLayerTiles := layers(cFurnitureLayer)->getTiles()
        
        var decorationLayerTiles : array 0 .. constants.cMaxLayerSize, 0.. constants.cMaxLayerSize of int
        decorationLayerTiles := layers(cDecorationLayer)->getTiles()
        
        var pickableLayerTiles : array 0 .. constants.cMaxLayerSize, 0.. constants.cMaxLayerSize of int
        pickableLayerTiles := layers(cPickableLayer)->getTiles()
        
        var interactableLayerTiles : array 0 .. constants.cMaxLayerSize, 0.. constants.cMaxLayerSize of int
        interactableLayerTiles := layers(cInteractableLayer)->getTiles()
        
        var interactedLayerTiles : array 0 .. constants.cMaxLayerSize, 0.. constants.cMaxLayerSize of int
        interactedLayerTiles := layers(cInteractedLayer)->getTiles()

        var uiLayerTiles : array 0 .. constants.cMaxLayerSize, 0.. constants.cMaxLayerSize of int
        uiLayerTiles := layers(cUILayer)->getTiles()
        
        var cameraX : int := camPos->x - maxx div 2 
        var cameraY : int := camPos->y - maxy div 2
        var tileToDraw : int := 0;
        var checkInteractable : int := 0
        var widthToDraw : int := 16
        var heightToDraw : int := 9
        var xStart :  int := camPos->x div 32 - widthToDraw
        var xEnd :  int := camPos->x div 32 + widthToDraw
        var yStart :  int := camPos->y div 32 - heightToDraw
        var yEnd :  int := camPos->y div 32 + heightToDraw

        if ( xStart < 0 ) then
            xStart := 0
        elsif ( xStart > width-1 ) then
            xStart := width-1
        end if
        
        if ( xEnd < 0 ) then
            xEnd := 0
        elsif ( xEnd > width-1 ) then
            xEnd := width-1
        end if

        if ( yStart < 0 ) then
            yStart := 0
        elsif ( yStart > height-1 ) then
            yStart := height-1
        end if
        
        if ( yEnd < 0 ) then
            yEnd := 0
        elsif ( yEnd > height-1 ) then
            yEnd := height-1
        end if

        for k: yStart .. yEnd
            for j: xStart .. xEnd
                
                tileToDraw := floorLayerTiles( j, k ) - 1
                
                if( tileToDraw > 0 ) then
                    Pic.Draw ( SpriteSheetManager.tileset( tileToDraw ), j * constants.cTilesize - cameraX, k * constants.cTilesize - cameraY, picCopy )
                end if

                tileToDraw := wallLayerTiles( j, k ) - 1
                
                if( tileToDraw > 0 ) then
                    Pic.Draw ( SpriteSheetManager.tileset( tileToDraw ), j * constants.cTilesize - cameraX, k * constants.cTilesize - cameraY, picCopy )
                end if
                
                tileToDraw := furnitureLayerTiles( j, k ) - 1
                
                if( tileToDraw > 0 ) then
                    Pic.Draw ( SpriteSheetManager.tileset( tileToDraw ), j * constants.cTilesize - cameraX, k * constants.cTilesize - cameraY, picMerge )
                end if
                
                tileToDraw := decorationLayerTiles( j, k ) - 1
                
                if( tileToDraw > 0 ) then
                    Pic.Draw ( SpriteSheetManager.tileset( tileToDraw ), j * constants.cTilesize - cameraX, k * constants.cTilesize - cameraY, picMerge )
                end if

                tileToDraw := pickableLayerTiles( j, k ) - 1
                
                if( tileToDraw > 0 ) then
                    Pic.Draw ( SpriteSheetManager.tileset( tileToDraw ), j * constants.cTilesize - cameraX, k * constants.cTilesize - cameraY, picMerge )
                end if

                tileToDraw := interactableLayerTiles( j, k ) - 1
                checkInteractable := interactableLayerTiles( j, k )
                
                if( tileToDraw > 0 ) then
                    Pic.Draw ( SpriteSheetManager.tileset( tileToDraw ), j * constants.cTilesize - cameraX, k * constants.cTilesize - cameraY, picMerge )
                end if
                
                tileToDraw := interactedLayerTiles( j, k ) - 1
                
                if( tileToDraw > 0 and checkInteractable = 0) then
                    Pic.Draw ( SpriteSheetManager.tileset( tileToDraw ), j * constants.cTilesize - cameraX, k * constants.cTilesize - cameraY, picMerge )
                end if
                
                if( constants.debugDisplayWalkableLayer ) then
                    tileToDraw := layers(cWalkableLayer)->tiles( j, k ) + 32
                    if( tileToDraw > 0 ) then
                    Pic.Draw ( SpriteSheetManager.tileset( tileToDraw ), j * constants.cTilesize - cameraX, k * constants.cTilesize - cameraY, picCopy )
                    end if
                end if

            end for  
        end for
        
        % Triggers
        var x : int
        var y : int
        var heightInPixels : int := height * constants.cTilesize
        var objectHeightFromBottom : int := 0
        
        for i : 0 .. upper (triggers)
            tileToDraw := triggers(i) -> getGid() - 1
            x := triggers(i) -> getX() - cameraX
            y := triggers(i) -> getY() - cameraY
            if( tileToDraw > 0 and x >= 0 and y >= 0 ) then
                Pic.Draw (SpriteSheetManager.tileset( tileToDraw ), x, y, picMerge)
            end if
        end for
        for i : 0 .. upper (spawnedMonsters)
            spawnedMonsters(i)->drawObject(camPos)
        end for
        
        avatar -> drawObject(camPos)
        var mousex, mousey, button : int
        mousewhere( mousex, mousey, button )
        % UI
        for h : height - 5 ..height
            for w : 0..5
                tileToDraw := uiLayerTiles( w, h ) - 1
                if( tileToDraw > 0 ) then
                    Pic.Draw ( SpriteSheetManager.tileset( tileToDraw ), w * constants.cTilesize, maxy - (height - h) * 32, picMerge )
                end if
            end for
        end for
        
    end drawLevel
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    body function getWalkableLayer() : ^ Layer
        result layers(cWalkableLayer)
    end getWalkableLayer
    
    body function getPickableLayer() : ^ Layer
        result layers(cPickableLayer)
    end getPickableLayer
    
    body function getInteractableLayer() : ^ Layer
        result layers(cInteractableLayer)
    end getInteractableLayer

    %---------------------------------------------------------------------------
    body function getTilePropertyObject( id : int ) : ^TilePropertyObject
        result tilePropertyObjects( id )
    end getTilePropertyObject
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    body procedure checkTriggers( position : ^ Tuple2i )
    var triggerType : string := ""
        for i : 0 .. upper(triggers)
            triggerType := triggers(i) -> getType()
            if position -> x = triggers(i) -> getX() and 
            position -> y = triggers(i) -> getY() and 
            triggerType = "exit" then
            %For now, both entrances and exits will bring to the next level.
            gameMessage := "go to next level"
            end if
        end for
    end checkTriggers
    
    %---------------------------------------------------------------------------
    body procedure moveAvatar( position : ^ Tuple2i, transitPosition : ^ Tuple2i )
    %Appeler cette fonction lorsque le niveau change pour que l'avatar se trouve a la droite de l'entre du niveau.
        var newAvatarX : int := 0
        var newAvatarY : int := 0
        newAvatarX := triggers(0) -> getX() + constants.cTilesize
        newAvatarY := triggers(0) -> getY()
        transitPosition -> x := newAvatarX
        transitPosition -> y := newAvatarY
        position -> x := newAvatarX
        position -> y := newAvatarY
    end moveAvatar
    
    %---------------------------------------------------------------------------
    body procedure setUIManager( newUIManager : ^ UIManager )
        uiManager := newUIManager
    end setUIManager
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette, Richard Lalancette
    body procedure avatarAttack()
            % Ne peut pas attaquer tant que cooldown n'est pas <= 0
            if( avatar ->getAttackCooldown() > 0 ) then
                return
            end if
            
            % Entiers au hazard
            var damageVariation : int
            var randomSound : int
            var randomFloatingTextX : int
            var randomFloatingTextY : int
            
            
            var targetTile : ^ Tuple2i := avatar -> attackInDirection()
            randint (damageVariation, -3, 3)
            var randomizedDamage : int := avatar -> damage + damageVariation
            if targetTile not= nil then
                for i : 0 .. upper(spawnedMonsters)
                    if spawnedMonsters(i) not= nil then
                        if spawnedMonsters(i) -> getPosition() -> equals( targetTile ) and spawnedMonsters(i) -> isAlive() then
                            % Le monstre a ete toucher par l'attaque du joueur
                            spawnedMonsters(i) -> loseHealth( randomizedDamage )
                            if spawnedMonsters(i) -> health <= 0 and spawnedMonsters(i) -> mobileStateTime = 0 then
                                avatar -> score := avatar -> score + (15 + damageVariation)
                            end if
                            randint( randomFloatingTextX, -30, 30 )
                            randint( randomFloatingTextY, 0, 30+randomizedDamage )
                            randint( randomSound, 0, 2 )
                            fork SoundManager.weaponswing( constants.sfxm1hswordhitplate1a + randomSound )
                            var blah : int := uiManager -> addFloatingObject( maxx div 2, maxy div 2, 
                                                                            maxx div 2 + randomFloatingTextX, maxy div 2 + 50 + randomFloatingTextY, 
                                                                            intstr( avatar -> damage + damageVariation ), 1,  1, 1 )
                            avatar -> setAttackCooldown( constants.cBaseAttackCooldown )
                        end if
                    end if
                end for
                free Tuple2i, targetTile
            end if
    end avatarAttack
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    body procedure monsterAttack()
            for i : 0 .. upper(spawnedMonsters)
                if spawnedMonsters(i) -> isAvatarInFront(avatar -> position) then
                    % Ne peut pas attaquer tant que cooldown n'est pas <= 0
                    if( spawnedMonsters(i) -> getAttackCooldown() > 0 ) or spawnedMonsters(i) -> health <= 0 then
                        return
                    end if
                    
                    % Entiers au hazard
                    var damageVariation : int
                    var randomSound : int
                    var targetTile : ^ Tuple2i := spawnedMonsters(i) -> attackInDirection()
                    randint (damageVariation, -3, 3)
                    var randomizedDamage : int := spawnedMonsters(i) -> damage + damageVariation
                    
                    if targetTile not= nil then
                        if avatar -> getPosition() -> equals( targetTile ) and avatar -> isAlive() then
                            % Le joueur a ete toucher par l'attaque du monstre
                            avatar -> loseHealth( randomizedDamage )
                            randint( randomSound, 0, 2 )
                            fork SoundManager.weaponswing( constants.sfxm1hswordhitplate1a + randomSound )
                            var splash : int := uiManager -> addFloatingObject( maxx div 2, maxy div 2, 
                                                                                maxx div 2, maxy div 2 - 50, 
                                                                                intstr( spawnedMonsters(i) -> damage + damageVariation ), 2,  1, 1 )
                            spawnedMonsters(i) -> setAttackCooldown( constants.cBaseAttackCooldown )
                        end if
                        free Tuple2i, targetTile
                    end if
                end if
            end for
    end monsterAttack
    
    %---------------------------------------------------------------------------
    body function getCameraPosition() : ^ Tuple2i
        result camera -> getPosition()
    end getCameraPosition
    
    %---------------------------------------------------------------------------
    body function processInput( inputEvent : int ) : boolean
        var inputProcessed : boolean := avatar->processInput( inputEvent )
        
        if( not inputProcessed ) then
            case inputEvent of
            % Direction sur le clavier (AWSD)
            label constants.ButtonB         :
            result true
            label constants.ButtonX         : 
            result true
            label constants.ButtonY         :
            result true
            end case
        end if
        result false
    end processInput
    
    %---------------------------------------------------------------------------
    body function isMobileAt( dx:int, dy:int ) : boolean
        for i : 0 .. upper(spawnedMonsters)
            if spawnedMonsters(i) not= nil then
                if spawnedMonsters(i) -> getPosition() -> equalsXY( dx, dy ) and spawnedMonsters(i) -> isAlive() then
                    result true
                end if
            end if
        end for
        if( avatar -> getPosition() -> equalsXY( dx, dy ) ) then
            result true
        end if
        result false
    end isMobileAt
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    body function getAvatarScore() : int
        result avatar -> score
    end getAvatarScore
    
    body function getAvatarHealth() : int
        result avatar -> health
    end getAvatarHealth
    
    body procedure setAvatarScore(newAvatarScore : int)
        avatar -> setScore(newAvatarScore)
    end setAvatarScore
    
    body procedure setAvatarHealth(newAvatarHealth : int)
        avatar -> health := newAvatarHealth
    end setAvatarHealth
    
end LevelImpl
