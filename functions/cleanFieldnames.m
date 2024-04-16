function cleanedStrings = cleanFieldnames(inputStrings)
    % Initialize the output cell array with the same dimensions as the input
    cleanedStrings = cell(size(inputStrings));
    
    % Regular expression pattern for characters to remove
    patternRemove = '[^a-zA-Z0-9_]';
    
    % Process each element in the input cell array
    for i = 1:numel(inputStrings)
        % Extract the current string
        currentString = inputStrings{i};
        
        % Check and prepend 'field_' if the string does not start with a letter
        if isempty(regexp(currentString(1), '^[a-zA-Z]', 'once'))
            currentString = ['field_', currentString];
        end
        
        % Remove characters not matching the pattern
        cleanedString = regexprep(currentString, patternRemove, '');
        
        % Assign the cleaned string back to the output cell array
        cleanedStrings{i} = cleanedString;
    end
end
