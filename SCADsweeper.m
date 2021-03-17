basefile = 'atancoil.scad';

wire_r = 0.005;
wire_sides = 6;

fscad = fopen(basefile,'w');

fprintf(fscad, 'use <list-comprehension/sweep.scad>\n');
fprintf(fscad, 'use <scad-utils/shapes.scad>\n');
fprintf(fscad, '// style and size parameters\n');
fprintf(fscad,'wire_r = %f;\n',wire_r);
fprintf(fscad,'sides = %i;\n',wire_sides);
fprintf(fscad,'function shape() = circle(wire_r, $fn=sides);\n');

wirecount = 0;
facedata = wiredata;
faces = length(facedata);

for i=1:faces
    M = facedata{i}{4};
    levels = length(facedata{i}{5});
    for j = 1:levels
        isowires = length(facedata{i}{5}{j});
        for k = 1:isowires
            contourdata = affineRestore(facedata{i}{5}{j}{k}(1,:),facedata{i}{5}{j}{k}(2,:),M);
            wirecount = wirecount + 1;
            stream(contourdata,fscad,wirecount)
        end
    end
end

fprintf(fscad,'union(){\n');
for i=1:wirecount
    fprintf(fscad,'sweep(shape (), construct_transform_path(path%i),false);\n', i);
end
fprintf(fscad,'};\n');
fclose(fscad);

function stream(contourdata,filehandle,index)
strindex = num2str(index,'%i');
fprintf(filehandle,['wire' strindex ' = [\n']);
[~,n] = size(contourdata);
for i=1:(n-1)
    fprintf(filehandle,'[%f,%f,%f],\n',contourdata(:,i));
end
fprintf(filehandle,'[%f,%f,%f]\n];\n',contourdata(:,n));

fprintf(filehandle,['path' strindex ' = [ for (i=[0:1:' num2str(n,'%i') ']) points' strindex '[i]];\n']);

end