function stackcylinders(model, facedata, wire_r, newsel)
% function stackcylinders(facedata)
%
% Take facedata structure and insert it as a series of cylinders in the
% current model.

geo = model.component('comp1').geom('geom1');

cylN = 0;

faces = length(facedata);

for i = 1:faces
    csel = ['csel' num2str(i)];
    if newsel
        geo.selection.create(csel, 'CumulativeSelection');
        geo.selection(csel).label(['tubeface' num2str(i)]);
    end
    
    M = facedata{i}{4};
    levels = length(facedata{i}{5});
    for j = 1:levels
        isowires = length(facedata{i}{5}{j});
        for k = 1:isowires
            contourdata = affineRestore(facedata{i}{5}{j}{k}(1,:),facedata{i}{5}{j}{k}(2,:),M);
            cylN = insertCylinders(model,contourdata, cylN, csel, wire_r);
        end
    end
end
geo.run;
geo.run('fin');
end
function cylN = insertCylinders(model,contourdata, cylN, grouping, wire_r)
    geo = model.component('comp1').geom('geom1');
    [~,n] = size(contourdata);
    diffdata = diff(contourdata,[],2);
    cylinderh = sqrt(sum(diffdata.*diffdata));
    for pti = 1:(n-1)
        cylN = cylN + 1;
        cylstring = ['cyl' num2str(cylN)];
        geo.create(cylstring, 'Cylinder');
        geo.feature(cylstring).set('contributeto', grouping);
        geo.feature(cylstring).set('pos', contourdata(:,pti)');
        geo.feature(cylstring).set('axis', diffdata(:,pti)');
        geo.feature(cylstring).set('r', wire_r);
        geo.feature(cylstring).set('h', cylinderh(pti));
    end
end