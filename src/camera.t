unit

%---------------------------------------------------------------------------
% David Delisle Lalancette, Richard Lalancette
% Change le point de vue du joueur
class Camera
    
    import Mobile in "mobile.t", Tuple2i in "tuple2i.t"
    
    export create, destroy, setTarget, update, setPosition, getPosition
    
    var position : ^ Tuple2i := nil
    var target : ^ Mobile := nil
    
    %---------------------------------------------------------------------------
    % Constructeur
    procedure create(x:int, y:int)
        new Tuple2i, position
        position->x := x
        position->y := y
    end create

    %---------------------------------------------------------------------------
    % Destructeur
    procedure destroy()
        if( position not= nil ) then
            free Tuple2i, position
            position := nil
        end if
    end destroy

    %---------------------------------------------------------------------------
    % Focus la camera sur le joueur
    procedure setTarget( newTarget : ^ Mobile )
        target := newTarget
    end setTarget
    
    %---------------------------------------------------------------------------
    % Mise a jour de la camera
    procedure update()
        if( target not= nil ) then
            var newX : int := ( ( target -> getPosition()->x + position->x ) ) div 2
            var newY : int := ( ( target -> getPosition()->y + position->y ) ) div 2

            if( abs(newX) < 2 ) then
                newX := target -> getPosition()->x
            end if
            if( abs(newY) < 2 ) then
                newY := target -> getPosition()->y
            end if

            position->x := newX 
            position->y := newY

        end if
    end update
    
    %---------------------------------------------------------------------------
    % Cherche et distribue la position de la camera
    procedure setPosition( x:int, y:int )
        position->x := x
        position->y := y
    end setPosition
    
    function getPosition() : ^ Tuple2i
        result position
    end getPosition

end Camera