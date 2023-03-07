function imgn = eqbrightness(img)
imgn = double(img);
q = find(imgn>=0);
immax = nanmax(imgn(q)); immin = nanmin(imgn(q)); immean = nanmean(imgn(q));
imgn(q) = imgn(q) - immean + 128; 
imgn(q) = imgn(q)/std(imgn(:)); imgn = 255*imgn/max(imgn(:)); 
scale = 1;
while(nanmax(imgn(q))>255 | nanmin(imgn(q))<0)
    imgn = 0.99*imgn;
    scale  = 0.99*scale;
    imgn(q) = imgn(q) - nanmean(imgn(q)) + 128;
end
imgn = round(imgn);
imgn = uint8(imgn);
end