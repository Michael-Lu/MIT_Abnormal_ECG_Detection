function [RR segments beat] = chop_ECG(original_signal, Annotation)

    if( size(Annotation,1) < 2)
        throw( MException('chop_ECG:WrongInput', 'The input ECG signal is not long enough for being retrieved at least one R-R interval') );
    end
    
    for n = 2: length( Annotation(:,1) )
        RR(n) = Annotation(n,1) - Annotation(n-1,1);
        segments(n,:) = {original_signal( Annotation(n-1,1):Annotation(n,1)-1 )};
        beat(n) = Annotation(n-1,2);
    end
    
    RR(1) = [];
    segments(1,:) = [];
    beat(1) =[];

end