function plot_3D_surrogate(xaxis, yaxis, zaxis, surrogate_field, title_str)

figure
[no_values_y, no_values_x,no_values_z] = size(surrogate_field);

xscale = 1;
yscale = 1;
zscale = 1;

width1  = 0.7*no_values_x*xscale/(no_values_x*xscale+no_values_z*zscale);
height1 = 0.7*no_values_y*yscale/(no_values_y*yscale+no_values_z*zscale);
left1   = 0.1;
bottom1 = 0.9-height1;

width2  = 0.7*no_values_z*zscale/(no_values_x*xscale+no_values_z*zscale);
height2 = 0.7*no_values_y*yscale/(no_values_y*yscale+no_values_z*zscale);
left2   = 0.1+0.1+width1;
bottom2 = 0.9-height1;

width3  = width1;
height3 = 0.7*no_values_z*zscale/(no_values_y*yscale+no_values_z*zscale);
left3   = 0.1;
bottom3 = 0.1;

% top view
subplot('Position',[left1 bottom1 width1 height1])
imagesc(xaxis, yaxis, sum(surrogate_field,3)) 
set(gca,'YDir','normal')
title(title_str)
axis tight

% side view
subplot('Position',[left2 bottom2 width2 height2])
field_2d = squeeze(sum(surrogate_field,2));
imagesc(zaxis, yaxis, field_2d) 
set(gca,'YAxisLocation','right')
set(gca,'YDir','normal')
axis tight

% front view
subplot('Position',[left3 bottom3 width3 height3])
imagesc(xaxis, zaxis, squeeze(sum(surrogate_field,1))') 
set(gca,'YDir','normal')
axis tight
