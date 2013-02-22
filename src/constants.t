
unit
%---------------------------------------------------------------------------
% Toutes les constantes sont stockees ici
module constants

%---------------------------------------------------------------------------
    export cMaxLayerSize, cMaxSpriteSheets, cNorth, cSouth, cWest, cEast, 
    cTilesize, 
    cBaseAttackCooldown,
    cBlackTile,
    cFootstepLeft, cFootstepIdle, cFootstepRight,
    cNotWalkable,
    cWalkable,
    DPadUp,
    DPadUpRight,
    DPadRight,
    DPadDownRight,
    DPadDown,
    DPadDownLeft,
    DPadLeft,
    DPadUpLeft,
    ButtonA,
    ButtonB,
    ButtonX,
    ButtonY,
    parallelUp,
    parallelDown,
    parallelRight,
    parallelLeft,
    parallelButton,
    var debugDisplayWalkableLayer,
    sfxSmallFootstepDirtA,    sfxSmallFootstepDirtB,    sfxSmallFootstepDirtC,    sfxSmallFootstepDirtD,    sfxSmallFootstepDirtE,
    footSmallDirtA,    footSmallDirtB,    footSmallDirtC,    footSmallDirtD,    footSmallDirtE,
    sfxSmallFootstepStoneA,    sfxSmallFootstepStoneB,    sfxSmallFootstepStoneC,    sfxSmallFootstepStoneD,    sfxSmallFootstepStoneE,
    footSmallStoneA,    footSmallStoneB,    footSmallStoneC,    footSmallStoneD,    footSmallStoneE,
    sfxSmallFootstepGrassA,    sfxSmallFootstepGrassB,    sfxSmallFootstepGrassC,    sfxSmallFootstepGrassD,    sfxSmallFootstepGrassE,
    footSmallGrassA,    footSmallGrassB,    footSmallGrassC,    footSmallGrassD,    footSmallGrassE,
    sfxAmbienceForestHighDay,
    ambienceForestHighDay,
    sfxm1hswordhitplate1a, sfxm1hswordhitplate1b, sfxm1hswordhitplate1c,
    m1hswordhitplate1a, m1hswordhitplate1b, m1hswordhitplate1c,
    sfxlootcoinsmall, sfxlootcoinlarge,
    lootcoinsmall, lootcoinlarge,
    smallOpenChest, smallClosedChest, smallGoldPile, smallBags, goldNecklace, %pickable
    interactableLog, interactableLogpile, interactableStump, interactablePinkflowers, interactableBrownchest, 
    interactableCrystalballtable,interactableBookonshelf,interactableBagshelf, interactableDragonstatuepillar, interactableWallgrate,
    interactablePotatoCrate, interactableTomatoCrate, interactableCornCrate, interactableFishCrate, interactableBottlesShelf,
    interactableTomatoBasket, interactableWaterBucket, interactableChickenDish, interactableFishDish, interactableBottlesOfBeer
    
    
    
    %---------------------------------------------------------------------------

    const cMaxLayerSize : int := 199
    const cMaxSpriteSheets := 28
    const cBlackTile := 32
    const cBaseAttackCooldown := 30
    
    %---------------------------------------------------------------------------
    
    % Directions
    % Aussi utilisee par processInput
    const cSouth := 0
    const cWest := 1
    const cEast := 2
    const cNorth := 3
    
    const DPadUp        : int := 10
    const DPadUpRight   : int := 11
    const DPadRight     : int := 12
    const DPadDownRight : int := 13
    const DPadDown      : int := 14
    const DPadDownLeft  : int := 15
    const DPadLeft      : int := 16
    const DPadUpLeft    : int := 17
    const ButtonA       : int := 18
    const ButtonB       : int := 19
    const ButtonX       : int := 20
    const ButtonY       : int := 21
    
    const parallelUp    :=  104  
    const parallelDown  :=  88
    const parallelRight :=  56
    const parallelLeft  :=  248
    const parallelButton:=  112
    % Plus de input event peuvent etre ajoutee ici, en sequence.
    %Fin du processInput
    
    
    const cTilesize := 32
    
    const cFootstepLeft := 0
    const cFootstepIdle := 1
    const cFootstepRight := 2

    const cWalkable     : int := 0
    const cNotWalkable  : int := 1

    var debugDisplayWalkableLayer : boolean := false
    
    %---------------------------------------------------------------------------
    % Effets sonores
    
    % Les bruits de pas
    const sfxSmallFootstepDirtA : int := 0
    const sfxSmallFootstepDirtB : int := 1    
    const sfxSmallFootstepDirtC : int := 2    
    const sfxSmallFootstepDirtD : int := 3    
    const sfxSmallFootstepDirtE : int := 4    
    
    const sfxSmallFootstepStoneA : int := 5
    const sfxSmallFootstepStoneB : int := 6    
    const sfxSmallFootstepStoneC : int := 7    
    const sfxSmallFootstepStoneD : int := 8    
    const sfxSmallFootstepStoneE : int := 9    
    
    const sfxSmallFootstepGrassA : int := 10
    const sfxSmallFootstepGrassB : int := 11    
    const sfxSmallFootstepGrassC : int := 12    
    const sfxSmallFootstepGrassD : int := 13    
    const sfxSmallFootstepGrassE : int := 14

    const footSmallDirtA: string := "../res/sfx/footsteps/mfootsmalldirta.wav"
    const footSmallDirtB: string := "../res/sfx/footsteps/mfootsmalldirtb.wav"
    const footSmallDirtC: string := "../res/sfx/footsteps/mfootsmalldirtc.wav"
    const footSmallDirtD: string := "../res/sfx/footsteps/mfootsmalldirtd.wav"
    const footSmallDirtE: string := "../res/sfx/footsteps/mfootsmalldirte.wav"

    const footSmallStoneA: string := "../res/sfx/footsteps/mfootsmallstonea.wav"
    const footSmallStoneB: string := "../res/sfx/footsteps/mfootsmallstoneb.wav"
    const footSmallStoneC: string := "../res/sfx/footsteps/mfootsmallstonec.wav"
    const footSmallStoneD: string := "../res/sfx/footsteps/mfootsmallstoned.wav"
    const footSmallStoneE: string := "../res/sfx/footsteps/mfootsmallstonee.wav"
    
    const footSmallGrassA: string := "../res/sfx/footsteps/mfootsmallgrassa.wav"
    const footSmallGrassB: string := "../res/sfx/footsteps/mfootsmallgrassb.wav"
    const footSmallGrassC: string := "../res/sfx/footsteps/mfootsmallgrassc.wav"
    const footSmallGrassD: string := "../res/sfx/footsteps/mfootsmallgrassd.wav"
    const footSmallGrassE: string := "../res/sfx/footsteps/mfootsmallgrasse.wav"
    
    %---------------------------------------------------------------------------
    % Ambiance
    const sfxAmbienceForestHighDay : int := 0
    const ambienceForestHighDay: string := "../res/sfx/ambience/foresthighday.mp3"
    
    %---------------------------------------------------------------------------
    % Coup des armes
    const sfxm1hswordhitplate1a : int := 0
    const sfxm1hswordhitplate1b : int := 1
    const sfxm1hswordhitplate1c : int := 2
    const m1hswordhitplate1a    : string := "../res/sfx/sword1h/m1hswordhitplate1a.wav"
    const m1hswordhitplate1b    : string := "../res/sfx/sword1h/m1hswordhitplate1b.wav"
    const m1hswordhitplate1c    : string := "../res/sfx/sword1h/m1hswordhitplate1c.wav"
    
    %---------------------------------------------------------------------------
    %Objet Obtenu: Tresores
    const sfxlootcoinsmall  : int := 0
    const sfxlootcoinlarge  : int := 1
    const lootcoinsmall     : string := "../res/music/sfx/itempickup/lootcoinsmall.wav"
    const lootcoinlarge     : string := "../res/music/sfx/itempickup/lootcoinlarge.wav"
    %---------------------------------------------------------------------------
    %Objet Obtenu: Autres
    const pickupbag             : string := "../res/music/sfx/itempickup/pickupbag.wav"
    const pickupbook            : string := "../res/music/sfx/itempickup/pickupbook.wav"
    const pickupcloth_leather01 : string := "../res/music/sfx/itempickup/pickupcloth_leather01.wav"
    const pickupfoodgeneric     : string := "../res/music/sfx/itempickup/pickupfoodgeneric.wav"
    const pickupgems            : string := "../res/music/sfx/itempickup/pickupgems.wav"
    const pickupherb            : string := "../res/music/sfx/itempickup/pickupherb.wav"
    const pickuplargechain      : string := "../res/music/sfx/itempickup/pickuplargechain.wav"
    const pickupmeat            : string := "../res/music/sfx/itempickup/pickupmeat.wav"
    const pickupmetallarge      : string := "../res/music/sfx/itempickup/pickupmetallarge.wav"
    const pickupmetalsmall      : string := "../res/music/sfx/itempickup/pickupmetalsmall.wav"
    const pickupparchment_paper : string := "../res/music/sfx/itempickup/pickupparchment_paper.wav"
    const pickupring            : string := "../res/music/sfx/itempickup/pickupring.wav"
    const pickuprocks_ore01     : string := "../res/music/sfx/itempickup/pickuprocks_ore01.wav"
    const pickupsmallchain      : string := "../res/music/sfx/itempickup/pickupsmallchain.wav"
    const pickupwand            : string := "../res/music/sfx/itempickup/pickupwand.wav"
    const pickupwater_liquid01  : string := "../res/music/sfx/itempickup/pickupwater_liquid01.wav"
    const pickupwoodlarge       : string := "../res/music/sfx/itempickup/pickupwoodlarge.wav"
    const pickupwoodsmall       : string := "../res/music/sfx/itempickup/pickupwoodsmall.wav"
    
    %---------------------------------------------------------------------------
    % Identifiants des objects dans le "level" qui peuvent etre actives ou rammasses
    
    % Rammassable GID
    
    const smallOpenChest    := 572
    const smallClosedChest  := 573
    const smallGoldPile     := 605
    const smallBags         := 636
    const goldNecklace      := 637
    
    % Interagissables GID
    
    const interactableLog            := 346
    const interactableLogpile        := 352
    const interactableStump          := 378
    const interactablePinkflowers    := 380
    const interactableBrownchest     := 638
    
    const interactableCrystalballtable   := 40
    const interactableBookonshelf        := 360
    const interactableBagshelf           := 392
    const interactableDragonstatuepillar := 509
    const interactableWallgrate          := 609
    % GID
    const interactablePotatoCrate       := 229
    const interactableTomatoCrate       := 230
    const interactableCornCrate         := 261
    const interactableFishCrate         := 262
    const interactableBottlesShelf      := 424
    const interactableTomatoBasket      := 455
    const interactableWaterBucket       := 487
    const interactableChickenDish       := 556
    const interactableFishDish          := 557
    const interactableBottlesOfBeer     := 558
    
end constants