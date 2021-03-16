t = linspace(0,8*pi,400);
pts = [t.*cos(t); t.*sin(t); 0*t+10];

scadfile = 'spiraltest.scad';

cliche('openSCAD-template-top.txt',scadfile,'wt')

stream_pts(pts, scadfile)

cliche('openSCAD-template-bottom.txt',scadfile,'a')

% status = copyfile('openSCAD-template-top.txt',scadfile);

function stream_pts(orderedpoints, destination)

[r,c] = size(orderedpoints);

if c==3
    streampts = orderedpoints';
    [r,c]=size(streampts);
else
    streampts = orderedpoints;
end

fdest = fopen(destination,'a');

for i=1:(c-1)
fprintf(fdest, '[%f,%f,%f],\n', streampts(:,i));    
end
fprintf(fdest, '[%f,%f,%f]\n', streampts(:,c));    

fclose(fdest);
end

function cliche(source,destination,code)
fd = fopen(destination, code);
fi = fopen(source, 'r');
tline = fgetl(fi);
while ischar(tline)
    fprintf(fd,[tline '\n']);
    tline = fgetl(fi);
end
fclose(fi);
fclose(fd);
end