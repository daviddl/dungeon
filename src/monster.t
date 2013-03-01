unit

%---------------------------------------------------------------------------
% Par David Delisle Lalancette
% Cette classe controle les monstres(animation) et leur parametres.
class Monster
    inherit Mobile in "mobile.t"
    
    export setTargetObject
    
    var targetObject : ^ Mobile := nil
    var followAvatar : boolean := false
    var nextMove : int
    randint( nextMove, 120, 360 )
    
    var targetInSight : boolean := false
    var targetPosition : ^ Tuple2i := nil
    
    health := 30
    damage := 5

    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    procedure chaseAvatar (avatarPosition: ^ Tuple2i)
    var avatarX : int := 0
    var avatarY : int := 0
        if followAvatar and mobileState not= mobileStateEnum.dying and mobileState not= mobileStateEnum.dead then
            if (avatarPosition -> x > position -> x) then
                direction := constants.cEast
                moveInDirection(constants.cEast)
            elsif (avatarPosition -> x < position -> x) then
                direction := constants.cWest
                moveInDirection(constants.cWest)
            end if
            if (avatarPosition -> y > position -> y) then
                direction := constants.cNorth
                moveInDirection(constants.cNorth)
            elsif (avatarPosition -> y < position -> y) then
                direction := constants.cSouth
                moveInDirection(constants.cSouth)
            end if
        end if
    end chaseAvatar
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette, Richard Lalancette
    % Mise a jour du monstre
    body procedure update
        if not targetInSight then
            if( mobileState = mobileStateEnum.alive ) then
                if targetObject not= nil then
                    transitPosition->x := targetObject -> getPosition() -> x - 32
                    transitPosition->y := targetObject -> getPosition() -> y + 32
                else
                    nextMove -= 1
                    if( nextMove = 0 ) then
                        var newDirection : int 
                        randint( newDirection, constants.cSouth, constants.cNorth )
                        moveInDirection( newDirection )
                        randint( nextMove, 120, 360 )
                    end if
                end if
            end if
        end if
        Mobile.update()
        chaseAvatar(targetPosition)
        currentLevel -> monsterAttack()
    end update
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    body function isAvatarInFront(avatarPosition : ^ Tuple2i) : boolean
        if mobileState not= mobileStateEnum.dying or mobileState not= mobileStateEnum.dead or mobileState not= mobileStateEnum.gone then
            if getTileInDirection( position ) -> equals( avatarPosition ) then
                targetInSight := true
                followAvatar := true
                targetPosition := avatarPosition
                result true
            end if
            targetInSight := false
            result false
        end if
    end isAvatarInFront
    
    %---------------------------------------------------------------------------
    % Assigne une cible au monstre
    procedure setTargetObject( newTargetObject : ^ Mobile )
        targetObject := newTargetObject
    end setTargetObject
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    %
    body function attackInDirection() : ^ Tuple2i
        var targetTileX : int
        var targetTileY : int
        var tileX := position -> x div constants.cTilesize
        var tileY := position -> y div constants.cTilesize
            
        if isInsideLevel( tileX, tileY ) then
            result getTileInDirection( position )
        end if    
        result nil
    end attackInDirection
    
end Monster