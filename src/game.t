unit

%---------------------------------------------------------------------------
% Par Richard Lalancette
% Cette class principal initialise, met a jour et met le jeu en arret.
class Game
    import  Level in "level.t", 
            GameControlInput in "gamecontrolinput.t",
            ErrorHelper in "errorhelper.t",
            SpriteSheetManager in "spritesheetmanager.t",
            UIManager in "uimanager.t",
            constants in "constants.t"
        
    export create, run, destroy, gameOver
    
    var gamecontrolinput : ^ GameControlInput
    var currentLevel : ^ Level
    var font1, font2, font3 : int % standard font
    var levelSequence : int := 0
    var levelNames : array 0 .. 6 of string
    var ui : ^ UIManager
    var readyToLeave : boolean := false
    var avatarScore : int := 0
    var avatarHealth : int := 0
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    % Prepare la sequence des niveaux ("level")
    procedure prepareLevelNames()
        for i : 0 .. upper(levelNames)
            if i < 9 then
                levelNames(i) := "lvl0" + intstr(i + 1) + "s"
            elsif i >= 9 then
                levelNames(i) := "lvl" + intstr(i + 1) + "s"
            else
                %Le nom du niveau sera pas storer.
            end if
        end for
    end prepareLevelNames
    
    %---------------------------------------------------------------------------
    % Constructeur
    % Cette procedure cree les instance et appelle toutes les methodes responsables de cree
    % des objects en plus de reserver des espaces pour tout les images utilisee.
    procedure create()
        
        View.Set ("graphics:960;580;nobuttonbar;offscreenonly") %Autres resolutions : Max, max et 640, 480
        colorback (black)
        cls
        % Initialise l'interface d'utilisateur
        new UIManager, ui
        ui->create()
        
        prepareLevelNames()
        
        SpriteSheetManager.create()
        
        new Level, currentLevel
        currentLevel->create()
        currentLevel->setUIManager(ui)
        
        new GameControlInput, gamecontrolinput
        gamecontrolinput -> initJoystick()
        
        font1 := Font.New ("porky's:12")
        assert font1 > 0

        font2 := Font.New ("sans serif:18:bold")
        assert font2 > 0
        
        font3 := Font.New ("mono:9")
        assert font3 > 0
        
    end create
    
    %---------------------------------------------------------------------------
    % Destructeur
    % Termine les operations et mets fin au programme
    procedure destroy()

        SpriteSheetManager.destroy()
        
        Font.Free (font1)
        Font.Free (font2)
        Font.Free (font3)
    
        gamecontrolinput->destroy()
        free GameControlInput, gamecontrolinput
        
        currentLevel->destroy()
        free Level, currentLevel
        
        ui->destroy()
        free UIManager, ui
    end destroy
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    procedure gameOver(avatarState : string)
        var finalScore : int := 0
        var state : string := avatarState
        if state not= "dead" then
        state := "alive"
        end if
        loop
            cls
            drawfillbox ( 0, 0, maxx, maxy, black )
            finalScore := currentLevel -> getAvatarScore()
            ui -> drawFinalScore(finalScore, state)
            View.Update
        end loop
    end gameOver
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    % Charge le niveau
    function loadLevel ( tilesheet : string, levelToLoad : string ) : boolean
            result currentLevel -> loadLevel(tilesheet, levelToLoad)
    end loadLevel
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette
    % Charge le prochain niveau
    function goToNextLevel() : boolean
        var levelToLoad : string := ""
        var tilesheet : string := "t01s"
        
        % Changer de niveau
            
            levelToLoad := levelNames(levelSequence)
            levelSequence += 1
        
        % Verifie si le joueur a atteint le dernier niveau
        if levelSequence = 7 then
            gameOver("alive")
        else
            % Conserver les points de vie et le pointage du joueur en changeant de niveau
            avatarScore := currentLevel -> getAvatarScore()
            avatarHealth := currentLevel -> getAvatarHealth()
    
            currentLevel -> destroy()
    
            currentLevel->create()
            var success : boolean := currentLevel -> loadLevel(tilesheet, levelToLoad)
        
            currentLevel -> setAvatarScore (avatarScore)
            currentLevel -> setAvatarHealth (avatarHealth)
            result success
        end if
    end goToNextLevel
    
    %---------------------------------------------------------------------------
    % David Delisle Lalancette, Richard Lalancette
    % Fonction principal du jeu
    procedure run()
        var success : boolean := true
        var now : int := 0
        var elapsed : int := 0
        var inputProcessed : boolean := false;
        var avatarState : string := ""
        
        %Initialisation du niveau menu principal
        success := loadLevel("tTitle", "lvlTitle")
        %success := loadLevel("t01s", "lvl06s")
        
        if( success ) then 
            loop
                inputProcessed := gamecontrolinput -> processInput( currentLevel )
                exit when currentLevel -> gameMessage = "quit"
                
                if currentLevel -> gameMessage = "go to next level" then
                    currentLevel -> gameMessage := ""
                    success := goToNextLevel()
                end if
                
                cls
                % Mise a jour du niveau
                currentLevel -> update()
                currentLevel -> drawLevel()
                ui->update( currentLevel -> getAvatarScore(), currentLevel -> getAvatarHealth() )
                ui->drawUI(currentLevel->getCameraPosition())
                
                %Est-ce que le joueur est mort, si oui, afficher le pointage du joueur
                var currentAvatarHealth  : int := 0
                currentAvatarHealth := currentLevel -> getAvatarHealth()
                if currentAvatarHealth <= 0 then
                    avatarState := "dead"
                    gameOver(avatarState)
                end if
                
                View.Update
            end loop
        else
            ErrorHelper.displayError("Problem creating new level")
        end if
    end run
    
end Game
