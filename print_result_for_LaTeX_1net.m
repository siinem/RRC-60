
function print_result_for_LaTeX_1net(param,caption,accuracy)

tex = ['   ', char(caption)];
for i=1:length(param.set)
    tex = [tex ' & ' num2str(round(accuracy(i)*100,1)) ];
end
fprintf([tex(3:end) ' \\' '\\' '\n'])
