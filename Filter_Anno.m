function AccepAnno = Filter_Anno(origAnnotation, TypeAccep)
    
    if(nargin ~=2)
        throw( MException('Filter_Anno:WrongInputNum', 'There should be 2 inputs') );
    end

    cond  = zeros(size(origAnnotation,1), 1 );
    for n = 1:length(TypeAccep)
        cond = cond | (origAnnotation(:,2) == TypeAccep(n));
    end
    AccepAnno = origAnnotation(cond,:);

end