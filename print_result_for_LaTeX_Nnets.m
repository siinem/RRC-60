
function print_result_for_LaTeX_Nnets(param,caption,accuracy)
for n = 1:param.num_nets
    tex = ['   ', char(caption),' N', num2str(n)];
    for i=1:length(param.set)
        tex = [tex ' & ' num2str(round(accuracy(n,i)*100,1))];
    end
    fprintf([tex(3:end) ' \\' '\\' '\n'])
end