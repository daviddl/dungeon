%---------------------------------------------------------------------------%
% Dongeon                                                                   %
% Par: David Delisle Lalancette, Richard Lalancette                         %
% Explorer un dongeon rempli de tresores et de perils.                      %
% Tuer les monstres et voler leur tresores                                  %
%                                                                           %
%---------------------------------------------------------------------------%
import Game in "game.t"

%---------------------------------------------------------------------------
% Program Principal

var game : ^ Game
new Game, game

%---------------------------------------------------------------------------
% Constructeur
game->create()

%---------------------------------------------------------------------------
% Fonction principal
game->run()

%---------------------------------------------------------------------------
% Destructeur
game->destroy()
free Game, game

%Fin
%---------------------------------------------------------------------------

