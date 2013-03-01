% Authors:  Richard Lalancette
unit

%---------------------------------------------------------------------------
% "Layer est une couche de "level", qui en contient plusieurs. Il est constituer de tuiles(Images)
class Layer
    
    import xml in "xml.t", constants in "constants.t"
    export create, destroy, loadTiles, getTiles, var tiles

    var tiles : array 0 .. constants.cMaxLayerSize, 0 .. constants.cMaxLayerSize of int
    var width : int := 0
    var height : int := 0
    
    %---------------------------------------------------------------------------
    % Constructeur
    procedure create(newWidth:int, newHeight:int)
        for j : 0 .. constants.cMaxLayerSize
            for k : 0 .. constants.cMaxLayerSize
                tiles( j, k ) := 0
            end for
        end for
        width := newWidth
        height := newHeight
    end create

    %---------------------------------------------------------------------------
    % Destructeur
    procedure destroy()
        for j : 0 .. constants.cMaxLayerSize
            for k : 0 .. constants.cMaxLayerSize
                tiles( j, k ) := 0
            end for
        end for
        width := 0
        height := 0
    end destroy
    
    %---------------------------------------------------------------------------
    % Distribue les tuiles trouvees dans un "layer" specifie
    function getTiles : array 0 .. constants.cMaxLayerSize, 0 .. constants.cMaxLayerSize of int
        result tiles
    end getTiles
    
    %---------------------------------------------------------------------------
    % Charge les tuiles dans un tableau
    % Note: l'editeur Tiled sauvegarde les "layer" a l'envers
    % La premiere rangee de donnees est en fait la derniere du "layer"
    procedure loadTiles ( levelData : array 0 .. * of string, layerName : string, layerWidth : int, layerHeight : int )        
    
        width := layerWidth
        height := layerHeight
        
        var layerTileData : int := 0
        var layerTileRowData : int := 0
        var propertyValue : string := ""
        var tileValue : string := "0"
        var commaIndex : int
        
        layerTileData := xml.findLine (levelData, '<layer name="' + layerName, 0 )
        if( layerTileData not= -1 ) then
            layerTileRowData := layerTileData + 2
            for k : 0 .. height - 1
                propertyValue := levelData(layerTileRowData + k)
                for j : 0 .. width - 1
                    commaIndex := index( propertyValue, ',' )
                    if commaIndex = 0 then
                        tileValue := propertyValue( 1 .. * )
                    else
                        tileValue := propertyValue( 1 .. commaIndex - 1 )
                    end if
                    tiles(j, height - 1 - k) := strint( tileValue )
                    propertyValue := propertyValue( index( propertyValue, ',' ) + 1 .. * )
                end for
            end for
        else
        end if
    end loadTiles

end Layer 
