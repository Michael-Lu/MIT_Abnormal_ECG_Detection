function [Trained_PNN] = Train_PNN(Training_Input, Training_Target, spread)

       if ~isvector(Training_Target)
           throw(MException('Train_PNN:WrongInput', 'Training_Target is not a vector!') );
       end
       
       if size(Training_Input,2) ~= length(Training_Target)
           throw(MException('Train_PNN:WrongInput', 'The number of Training_Input''s columns doesn''t equal length of Training_Target') );
       end
       
       Target = ind2vec(Training_Target);
       
       if nargin == 3
           Trained_PNN = newpnn_test(Training_Input, Target, spread);
       else
           Trained_PNN = newpnn_test(Training_Input, Target);
       end
end