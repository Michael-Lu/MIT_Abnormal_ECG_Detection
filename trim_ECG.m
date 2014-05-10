function varargout = trim_ECG(original_signal, Annotation)
    % [trimmed_signal, newAnnotation, (truncated_samples_in_the_front,
    % trucated_samples_on_the_back)] = trim_ECG(original_signal,
    % Annotation), where Annotation = [AnnoIdx, AnnoType]; both 'AnnoIdx' and
    % 'AnnoType' are column vectors. 'AnnoIdx' indicates the time index of the
    % annotations with respect to the original input signal, whereas
    % 'AnnoType' indicates the annotation type by a numeric scalar.
    if(nargout < 2)
        throw( MException('trim_ECG:WrongOutputNum', 'There should be at least two outputs') );
    end
    
    AnnoIdx = Annotation(:,1);
    AnnoType = Annotation(:,2);

    
    trim_head = AnnoIdx(1);
    trim_tail = AnnoIdx(end);

    trimmed_signal = original_signal( trim_head : trim_tail);
    NewAnnotation = [AnnoIdx-(trim_head-1), AnnoType];
    
    varargout = {trimmed_signal, NewAnnotation, trim_head-1, length(original_signal)-trim_tail};
    return
end