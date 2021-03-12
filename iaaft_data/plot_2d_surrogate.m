function plot_2d_surrogate(x, y, surrogate_field, title_str)
   
figure
imagesc(x, y, surrogate_field) 
set(gca, 'YDir', 'normal')
ylabel('y')
title([title_str ' field'])
axis tight
colorbar
