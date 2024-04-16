function cleanedStrings= formatForFieldname(listOfStrings)

% Regular expression pattern to match invalid characters
% This pattern matches anything that is NOT a letter, digit, or underscore


% Initialize the output cell array with the same dimensions as the input
cleanedStrings = cell(size(listOfStrings));

% Regular expression pattern for characters to keep (letters, digits, underscores)
patternKeep = '[^a-zA-Z0-9_]';

for i = 1:numel(listOfStrings)
    % Ensure the string starts with a letter by checking and prepending if necessary
    str = listOfStrings{i};
    if isempty(regexp(str(1), '^[a-zA-Z]', 'once'))
        str = ['field_', str];
    end
    
    % Remove characters not matching the pattern
    str = regexprep(str, patternKeep, '');
    
    % Assign the cleaned string back to the corresponding position in the output cell array
    cleanedStrings{i} = str;
end



end
