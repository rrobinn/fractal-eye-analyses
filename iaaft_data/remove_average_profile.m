function lwc = remove_average_profile(lwc, mean_pdf_profile)

len=length(mean_pdf_profile);

a=size(lwc);
no_dim = length(a);

if (no_dim == 2)
    for i=1:len
        lwc(i,:)=lwc(i,:)-mean_pdf_profile(i); % indexes are for y, x
    end
end

if no_dim == 3
    for i=1:len
        lwc(:,:,i)=lwc(:,:,i)-mean_pdf_profile(i); % indeces here are x, y, z      
    end
end
