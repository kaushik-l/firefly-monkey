function SubplotArray(unit_type,unit_id)

switch unit_id
    case num2cell(1:8)
        k = unit_id + 1;
    case num2cell(9:88)
        k = unit_id + 2;
    case num2cell(89:96)
        k = unit_id + 3;
end

switch unit_type
    case 'multiunits'
        subplot(10,10,k);
    case 'singleunits'
end