
function print_mean_std_for_LaTeX(param,caption,mu_net,std_net)

tex = ['   ', char(caption)];
for i=1:length(param.set)
    tex = [tex ' & ' num2str(round(mu_net(i)*100,1)) '$\\pm$' num2str(round(std_net(i)*100,1))];
end
fprintf([tex(3:end) ' \\' '\\' '\n'])
