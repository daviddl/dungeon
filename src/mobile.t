unit

%---------------------------------------------------------------------------
% Authors:  David Delisle-Lalancette
% Classe de base pour tout les object/personages qui peuvent bouger
% Cette class est une class de base pour tout les objects qui bougent ayant une animation. ("Avatar" et "Monster")
class Mobile
    import  Layer in "layer.t", 
            constants in "constants.t", 
            SoundManager in "soundmanager.t", 
            Level in "level.t",
            Tuple2i in "tuple2i.t",
            SpriteSheet in "spritesheet.t",
            SpriteSheetManager in "spritesheetmanager.t",
            Trigger in "trigger.t", 
            TilePropertyObject in "tilepropertyobject.t"
    
    export  create, destroy,
            drawObject, 
            loadObject, 
            loadObjectGid,
            moveInDirection, 
            action, 
            update, 
            setSpeed,
            setLevel, 
            setPosition, getPosition,
            checkTriggers,
            attackInDirection,
            loseHealth,
            gainHealth,
            isAlive,
            isAvatarInFront,
            setScore,
            var health,
            var damage,
            var score,
            var speed,
            mobileState,
            mobileStateEnum,
            mobileStateTime,
            getAttackCooldown,
            setAttackCooldown,
            processInput,
            position
            
    
    var sprites : array 0 .. 11  of int
    var spriteSheet : ^ SpriteSheet
    var position : ^ Tuple2i := nil
    var transitPosition : ^ Tuple2i := nil
    
    var direction: int := 0
    var footstep: int := 0
    var walkableLayer : ^ Layer := nil
    var pickableLayer : ^ Layer := nil
    var interactableLayer : ^ Layer := nil
    var triggerList : flexible array 0 .. 0 of ^ Trigger
    var currentLevel : ^ Level := nil
    
    %Variables du Jeu
    var health : int := 100 % Par defaut 100
    var speed : int := 4 % Devrait etre un multiple de 2 et <=16
    var damage : int := 10 % Par defaut 10
    type mobileStateEnum : enum (alive, attacking, dying, dead, gone)
    var mobileState : mobileStateEnum := mobileStateEnum.alive % Par defaut "alive"
    var mobileStateTime : int := 0
    var score : int := 0
    var attackCooldown : int := 0
    
    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    procedure create(x:int, y:int)
        new Tuple2i, position
        new Tuple2i, transitPosition
        
        position->x := x
        position->y := y
        transitPosition->x := x
        transitPosition->y := y
        
    end create

    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    procedure destroy()
        currentLevel := nil
        if( position not= nil ) then
            free Tuple2i, position
            position := nil
        end if
        if( transitPosition not= nil ) then
            free Tuple2i, transitPosition
            transitPosition := nil
        end if
    end destroy

    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    procedure loadObject ( spriteSheetName : string, spriteFirstFrame : int)
        spriteSheet := SpriteSheetManager.loadSpriteSheet( spriteSheetName, spriteFirstFrame )
    end loadObject
    
    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    procedure loadObjectGid ( gid : int, tileProperty:^TilePropertyObject )
        spriteSheet := SpriteSheetManager.loadSpriteSheetGid( gid, tileProperty )
    end loadObjectGid
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    deferred procedure setScore(newScore : int)
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    % Use enum for avatar states (Alive, dead, poisoned... etc)
    procedure loseHealth ( damage: int)
        health := health - damage
        if health <= 0 and mobileState = mobileStateEnum.alive then
            mobileState := mobileStateEnum.dying
            mobileStateTime := 0
        end if
    end loseHealth
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    procedure gainHealth ( healing: int)
        if mobileState = mobileStateEnum.alive then
        health := health + healing
        end if
    end gainHealth

    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    procedure setPosition( x:int, y:int )
        position->x := x
        position->y := y
    end setPosition
    
    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    function getPosition() : ^ Tuple2i
        result position
    end getPosition

    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    function isInsideLevel( tileX : int, tileY : int ) : boolean
        result currentLevel-> isInsideLevel( tileX, tileY )
    end isInsideLevel

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure setSpeed( newSpeed : int )
        speed := newSpeed
    end setSpeed
    
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure drawObject( cameraPosition : ^Tuple2i )
        var frame : int := direction * 3 + footstep
        
        var cameraX : int := cameraPosition->x - maxx div 2 
        var cameraY : int := cameraPosition->y - maxy div 2
        
        if( mobileState = mobileStateEnum.dying ) then
            %if mobileStateTime = 0 then
            %   avatar -> score := avatar -> score + monster -> score
            %end if
            var angle : int := mobileStateTime * 8
            if angle > 90 then
                angle := 90
            end if
            var dyingPicture := Pic.Rotate( spriteSheet->sprites(frame), angle, -1, -1 )
            Pic.Draw (dyingPicture, position->x - cameraX, position->y + constants.cTilesize div 4 - cameraY, picMerge)
            Pic.Free( dyingPicture )
            if( mobileStateTime > 360 ) then
                mobileState := mobileStateEnum.dead
                loadObject( "m04", 52 )
            end if
        else
            Pic.Draw (spriteSheet->sprites(frame), position->x - cameraX, position->y + constants.cTilesize div 4 - cameraY, picMerge)
        end if
    end drawObject
    
    %---------------------------------------------------------------------------
    % Authors:  Richard Lalancette
    procedure playFootstepSfx()
        var randomFootstep : int
        randint( randomFootstep, 0, 4 )
        
        var groundType : int := 2
        
        if( groundType = 0 ) then
            fork SoundManager.footstep( constants.sfxSmallFootstepStoneA + randomFootstep  )
        elsif ( groundType = 1 ) then
            fork SoundManager.footstep( constants.sfxSmallFootstepDirtA + randomFootstep )
        elsif ( groundType = 2 ) then
            fork SoundManager.footstep( constants.sfxSmallFootstepGrassA + randomFootstep )
        end if
    end playFootstepSfx
    
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure playGoldPickupSfx()
        var randomGoldPickup : int
        randint( randomGoldPickup , 0, 1 )
            fork SoundManager.goldPickup( constants.sfxlootcoinsmall + randomGoldPickup )
    end playGoldPickupSfx
    
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure moveInDirection( newDirection : int )
        %donne une nouvelle cible a notre objet : "Mobile".
        var dx : int := position->x
        var dy : int := position->y
        var tileX : int := 0
        var tileY : int := 0
        
        if position->x = transitPosition->x and position->y = transitPosition->y then
            case newDirection of
                label constants.cSouth: dy := position->y - constants.cTilesize
                      direction := constants.cSouth
                label constants.cWest: dx := position->x - constants.cTilesize
                      direction := constants.cWest
                label constants.cEast: dx := position->x + constants.cTilesize
                      direction := constants.cEast
                label constants.cNorth: dy := position->y + constants.cTilesize
                      direction := constants.cNorth
            end case
            if currentLevel -> layers(Level.cWalkableLayer) not= nil then
                var isMobileObjectThere : boolean := currentLevel->isMobileAt( dx, dy )
                tileX := dx div constants.cTilesize
                tileY := dy div constants.cTilesize
                var layerWidth : int := upper( walkableLayer->tiles, 1 )
                var layerHeight : int := upper( walkableLayer->tiles, 2 )
                
                %TODO add a flag so that playFootstepSfx does not interupt playGoldPickupSfx.
                
                if isInsideLevel( tileX, tileY ) then
                    if( walkableLayer -> tiles(tileX, tileY) = constants.cWalkable and
                        not isMobileObjectThere ) then
                        transitPosition->x := dx
                        transitPosition->y := dy
                        playFootstepSfx()
                    end if
                end if
            else
                
            end if
        end if
        
    end moveInDirection
    
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure action()
    end action

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure checkPickables 
        var dx : int := position->x
        var dy : int := position->y
        var tileX : int := 0
        var tileY : int := 0
        var pickableLayerTile : int := 0
        var variation : int := 0
        randint (variation, -5, 5)

        if( pickableLayer not= nil ) then
            %Le tresore sur le sol peut etre ramasser.
            tileX := dx div constants.cTilesize
            tileY := dy div constants.cTilesize
            var layerWidth : int := upper( pickableLayer -> tiles, 1 )
            var layerHeight : int := upper( pickableLayer -> tiles, 2 )
                    
            if tileX >= 0 and tileY >= 0 and tileX < layerWidth and tileY < layerHeight then
                pickableLayerTile := pickableLayer -> tiles(tileX, tileY)
                if pickableLayerTile > 0 then %Le tresore est ramasser si la case est pleine de tresore.
                        pickableLayer -> tiles(tileX, tileY ) := 0
                        score := score + (10 + variation)
                        playGoldPickupSfx()
                        %TODO Dire au score du joueur qu'il peut rajouter des points.
                end if
            end if
        else
        end if
    end checkPickables
 
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure updateWalkableTile (targetTileX : int , targetTileY : int )
        currentLevel -> updateWalkableTile( targetTileX, targetTileY )
    end updateWalkableTile
 
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure pickupInteractableItem( interactableItem : int )
        % Chacun peut completer une tache specifique a partir d'ici.
        var variation : int := 0
        if interactableItem = constants.interactableLog or
            interactableItem = constants.interactableLogpile or
            interactableItem = constants.interactableStump or
            interactableItem = constants.interactablePinkflowers or
            interactableItem = constants.interactableBookonshelf or 
            interactableItem = constants.interactableBagshelf or 
            interactableItem = constants.interactableDragonstatuepillar or
            interactableItem = constants.interactableWallgrate then
            randint (variation, -5, 5)
            score := score + (7 + variation)
            
        elsif interactableItem = constants.interactableBrownchest or 
        interactableItem = constants.interactableCrystalballtable then
        randint (variation, -5, 5)
        score := score + (30 + variation)
        
        elsif interactableItem = constants.interactablePotatoCrate or
        interactableItem = constants.interactableTomatoCrate or
        interactableItem = constants.interactableCornCrate or
        interactableItem = constants.interactableFishCrate or
        interactableItem = constants.interactableBottlesShelf or
        interactableItem = constants.interactableTomatoBasket or
        interactableItem = constants.interactableWaterBucket or
        interactableItem = constants.interactableChickenDish or
        interactableItem = constants.interactableFishDish or
        interactableItem = constants.interactableBottlesOfBeer then
            health := health + 10
            if health >= 125 then
                health := 125
            end if
        elsif interactableItem > 0 then
            randint (variation, -5, 5)
        score := score + (10 + variation)
        end if
   end pickupInteractableItem
 
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    %
    function getTileInDirection( position : ^ Tuple2i ) : ^ Tuple2i
        var targetTileX : int
        var targetTileY : int
        if direction = constants.cNorth then
            targetTileX := position->x
            targetTileY := position->y + constants.cTilesize
        elsif direction = constants.cSouth then
            targetTileX := position->x
            targetTileY := position->y - constants.cTilesize
        elsif direction = constants.cEast then
            targetTileX := position->x + constants.cTilesize
            targetTileY := position->y 
        elsif direction = constants.cWest then
            targetTileX := position->x - constants.cTilesize
            targetTileY := position->y 
        end if
            var targetTile : ^ Tuple2i
            new Tuple2i, targetTile
            targetTile -> createXY( targetTileX, targetTileY )
            result targetTile
    end getTileInDirection
 
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure checkInteractableInDirection ()
        var targetTileX : int
        var targetTileY : int
        var layerWidth : int := upper( pickableLayer -> tiles, 1 )
        var layerHeight : int := upper( pickableLayer -> tiles, 2 )
        var targetTile : ^ Tuple2i
        
    % Use direction to determin which tile is faced by avatar.
        if interactableLayer not= nil then
            targetTile := getTileInDirection( position )
            var tileX := targetTile -> x div constants.cTilesize
            var tileY := targetTile -> y div constants.cTilesize
        
            if isInsideLevel( tileX, tileY ) then
                %TODO Dire au score du joueur qu'il peut rajouter des points ( ceci depend sur le type de contenant. )
                pickupInteractableItem( interactableLayer -> tiles(tileX, tileY) )
                interactableLayer -> tiles(tileX, tileY ) := 0
                updateWalkableTile ( tileX, tileY )
            end if    
            free Tuple2i, targetTile
        end if
    end checkInteractableInDirection
    
    %---------------------------------------------------------------------------
    deferred procedure placeAvatar()
    body procedure placeAvatar()
    end placeAvatar
    
    %---------------------------------------------------------------------------
    deferred procedure checkTriggers()
    
    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    deferred procedure update()
    body procedure update()
        attackCooldown -= 1
        mobileStateTime += 1
        case mobileState of
            label mobileStateEnum.alive : 
            label mobileStateEnum.dying : 
            label mobileStateEnum.dead : 
        end case
        
        if( mobileState = mobileStateEnum.alive ) then
            if position -> x > transitPosition -> x then
                position -> x := position -> x - speed
                direction := constants.cWest
                footstep := ( footstep + 1 ) mod 3
            elsif position -> x < transitPosition->x then
                position -> x += speed
                direction := constants.cEast
                footstep := ( footstep + 1 ) mod 3
            end if
            
            if position -> y > transitPosition -> y then
                position -> y -= speed
                direction := constants.cSouth
                footstep := ( footstep + 1 ) mod 3
            elsif position -> y < transitPosition -> y then
                position -> y += speed
                direction := constants.cNorth
                footstep := ( footstep + 1 ) mod 3
            end if
            
            checkPickables()
        end if
        
    end update

    %---------------------------------------------------------------------------
    % Authors:  David Delisle-Lalancette
    procedure setLevel ( level : ^ Level )
        currentLevel := level
        walkableLayer := currentLevel -> layers(Level.cWalkableLayer)
        pickableLayer := currentLevel -> layers(Level.cPickableLayer)
        interactableLayer := currentLevel -> layers(Level.cInteractableLayer)
        placeAvatar()
    end setLevel
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    % Atttaque le monstre situer devant le joueur
    deferred function attackInDirection() : ^ Tuple2i
    body function attackInDirection() : ^ Tuple2i
        % TODO? Must add this for monsters
    end attackInDirection
    
    %---------------------------------------------------------------------------
    function getAttackCooldown() : int
        result attackCooldown
    end getAttackCooldown
    
    %---------------------------------------------------------------------------
    procedure setAttackCooldown( newAttackCooldown : int )
        attackCooldown := newAttackCooldown
    end setAttackCooldown
    
    %---------------------------------------------------------------------------
    deferred function processInput( inputEvent : int ) : boolean
    body function processInput( inputEvent : int ) : boolean
        result false
    end processInput
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    function isAlive() : boolean
        if mobileState = mobileStateEnum.alive or mobileState = mobileStateEnum.attacking then
            result true
        end if
        result false
    end isAlive
    
    deferred function isAvatarInFront(avatarPosition : ^ Tuple2i) : boolean
    
end Mobile